const {FieldValue, FieldPath, Timestamp} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {validId} = require("./validation");
const {isTripMember} = require("./trip-membership");

function createChatRoomHandler(db, log = () => {}) {
  return async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
    const input = request.data;
    if (!input || typeof input !== "object" || Array.isArray(input) ||
        Object.keys(input).length !== 1 || !validId(input.tripId)) {
      throw new HttpsError("invalid-argument", "Trip ID required.");
    }
    const tripId = input.tripId;
    const tripRef = db.collection("trips").doc(tripId);
    const roomRef = db.collection("chat").doc(tripId);
    const result = await db.runTransaction(async (tx) => {
      const [tripDoc, memberDoc, accountDoc, safetyDoc, roomDoc, members] = await Promise.all([
        tx.get(tripRef), tx.get(tripRef.collection("members").doc(uid)),
        tx.get(db.collection("users").doc(uid)),
        tx.get(db.collection("safetyAccounts").doc(uid)), tx.get(roomRef),
        tx.get(tripRef.collection("members").limit(101)),
      ]);
      const trip = tripDoc.data();
      if (!trip || trip.tripStatus === "deleted" || trip.moderationRemoved ||
          !isTripMember(trip, uid, memberDoc.data()) ||
          !accountDoc.exists || accountDoc.data()?.isDeleted || safetyDoc.data()?.restricted) {
        throw new HttpsError("permission-denied", "Trip unavailable.");
      }
      if (members.size > 100) throw new HttpsError("resource-exhausted", "Trip roster exceeds chat limit.");
      const known = new Map(members.docs.map((doc) => [doc.id, doc.data()]));
      const ids = new Set([trip.createdBy]);
      for (const member of members.docs) {
        if (member.data().status === "active") ids.add(member.id);
      }
      for (const legacyId of Array.isArray(trip.joinedUsers) ? trip.joinedUsers : []) {
        if (!known.has(legacyId)) ids.add(legacyId);
      }
      ids.add(uid);
      if (ids.size > 100 || [...ids].some((id) => !validId(id))) {
        throw new HttpsError("resource-exhausted", "Trip roster exceeds chat limit.");
      }
      const sortedIds = [...ids].sort();
      const states = await Promise.all(sortedIds.map(async (id) => {
        const [account, safety, profile] = await Promise.all([
          id === uid ? accountDoc : tx.get(db.collection("users").doc(id)),
          id === uid ? safetyDoc : tx.get(db.collection("safetyAccounts").doc(id)),
          tx.get(db.collection("publicProfile").doc(id)),
        ]);
        return {id, active: account.exists && account.data()?.isDeleted !== true &&
          safety.data()?.restricted !== true, profile: profile.data()};
      }));
      if (!states.some((state) => state.id === trip.createdBy && state.active)) {
        throw new HttpsError("permission-denied", "Trip unavailable.");
      }
      const active = states.filter((state) => state.active);
      const activeIds = active.map((state) => state.id);
      const users = active.map(({id, profile}) => {
        const visible = profile && !profile.moderationRemoved;
        return {id, unreadedMessages: 0,
          name: visible && typeof profile.displayName === "string" ? profile.displayName.slice(0, 120) : "Traveler",
          profileImage: visible && typeof profile.profileImage === "string" ? profile.profileImage.slice(0, 2048) : "",
          isOnline: false, isTyping: false};
      });
      const previous = roomDoc.data();
      if (previous && previous.roomId === tripId &&
          JSON.stringify(previous.usersIds) === JSON.stringify(activeIds) &&
          JSON.stringify(previous.users) === JSON.stringify(users)) {
        return {created: false, changed: false};
      }
      const room = {roomId: tripId, usersIds: activeIds, users,
        updatedAt: previous?.updatedAt || FieldValue.serverTimestamp()};
      if (previous?.lastMessageId) room.lastMessageId = previous.lastMessageId;
      if (roomDoc.exists) tx.set(roomRef, room);
      else tx.create(roomRef, room);
      return {created: !roomDoc.exists, changed: true};
    });
    if (result.changed) log("chat_room_roster_refreshed", {tripId, created: result.created});
    return {ok: true};
  };
}

module.exports = {createChatRoomHandler};

function createChatRoomListHandler(db) {
  return async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
    const input = request.data;
    const cursor = input?.cursor;
    if (!input || typeof input !== "object" || Array.isArray(input) ||
        Object.keys(input).some((key) => key !== "cursor") ||
        (cursor !== undefined && (!cursor || typeof cursor !== "object" || Array.isArray(cursor) ||
          Object.keys(cursor).sort().join(",") !== "id,nanoseconds,seconds" ||
          !validId(cursor.id) || !Number.isInteger(cursor.seconds) ||
          cursor.seconds < 0 || !Number.isInteger(cursor.nanoseconds) ||
          cursor.nanoseconds < 0 || cursor.nanoseconds >= 1e9))) {
      throw new HttpsError("invalid-argument", "Invalid chat page request.");
    }
    const [account, safety] = await Promise.all([
      db.collection("users").doc(uid).get(), db.collection("safetyAccounts").doc(uid).get(),
    ]);
    if (!account.exists || account.data()?.isDeleted || safety.data()?.restricted) {
      throw new HttpsError("permission-denied", "Account unavailable.");
    }
    let query = db.collection("chat").where("usersIds", "array-contains", uid)
        .orderBy("updatedAt", "desc").orderBy(FieldPath.documentId()).limit(51);
    if (cursor !== undefined) {
      query = query.startAfter(new Timestamp(cursor.seconds, cursor.nanoseconds),
          db.collection("chat").doc(cursor.id));
    }
    const snapshot = await query.get();
    const page = snapshot.docs.slice(0, 50);
    const ownerStates = new Map();
    const ownerActive = (ownerId) => {
      if (!validId(ownerId)) return Promise.resolve(false);
      if (ownerId === uid) return Promise.resolve(true);
      if (!ownerStates.has(ownerId)) {
        ownerStates.set(ownerId, Promise.all([
          db.collection("users").doc(ownerId).get(),
          db.collection("safetyAccounts").doc(ownerId).get(),
        ]).then(([owner, status]) => owner.exists &&
          owner.data()?.isDeleted !== true && status.data()?.restricted !== true));
      }
      return ownerStates.get(ownerId);
    };
    const rooms = await Promise.all(page.map(async (room) => {
      const tripRef = db.collection("trips").doc(room.id);
      const [tripDoc, memberDoc] = await Promise.all([
        tripRef.get(), tripRef.collection("members").doc(uid).get(),
      ]);
      const trip = tripDoc.data();
      return trip && trip.tripStatus !== "deleted" && !trip.moderationRemoved &&
        isTripMember(trip, uid, memberDoc.data()) &&
        await ownerActive(trip.createdBy) ? room.id : null;
    }));
    const last = page.at(-1);
    const nextCursor = snapshot.docs.length > 50 ? {
      id: last.id, seconds: last.data().updatedAt.seconds,
      nanoseconds: last.data().updatedAt.nanoseconds,
    } : null;
    return {roomIds: rooms.filter(Boolean), nextCursor};
  };
}

module.exports.createChatRoomListHandler = createChatRoomListHandler;

async function removeInactiveChatUser(db, uid, log = () => {}) {
  if (!validId(uid)) throw new Error("Invalid chat user ID");
  let cursor;
  let examined = 0;
  let changed = 0;
  while (true) {
    let query = db.collection("chat").where("usersIds", "array-contains", uid).limit(100);
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    for (const room of page.docs) {
      examined++;
      const updated = await db.runTransaction(async (tx) => {
        const tripRef = db.collection("trips").doc(room.id);
        const [currentRoom, account, safety, trip] = await Promise.all([
          tx.get(room.ref), tx.get(db.collection("users").doc(uid)),
          tx.get(db.collection("safetyAccounts").doc(uid)), tx.get(tripRef),
        ]);
        const data = currentRoom.data();
        if (!data || !Array.isArray(data.usersIds) || !data.usersIds.includes(uid) ||
            (account.exists && account.data()?.isDeleted !== true &&
             safety.data()?.restricted !== true)) return false;
        const tripData = trip.data();
        const clearRoom = !tripData || tripData.createdBy === uid ||
          tripData.tripStatus === "deleted" || tripData.moderationRemoved;
        tx.update(room.ref, {
          usersIds: clearRoom ? [] : data.usersIds.filter((id) => id !== uid),
          users: clearRoom ? [] : (Array.isArray(data.users) ? data.users : [])
              .filter((user) => user?.id !== uid),
        });
        return true;
      });
      if (updated) changed++;
    }
    if (page.size < 100) break;
    cursor = page.docs.at(-1);
  }
  log("inactive_chat_rosters_cleaned", {examined, changed});
  return {examined, changed};
}

module.exports.removeInactiveChatUser = removeInactiveChatUser;
