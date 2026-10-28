const { before, beforeEach, after, test } = require("node:test");
const fs = require("node:fs");
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const {
  doc,
  setDoc,
  getDoc,
  updateDoc,
  deleteDoc,
  writeBatch,
  arrayUnion,
  serverTimestamp,
  Timestamp,
} = require("firebase/firestore");
let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-travelcrew-safety",
    firestore: {
      rules: fs.readFileSync("../firestore.rules", "utf8"),
    },
  });
});
after(async () => {
  if (env) await env.cleanup();
});
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const data = {
      "users/alice": {uid: "alice"},
      "users/bob": {uid: "bob"},
      "users/carol": {uid: "carol"},
      "users/dave": {uid: "dave"},
      "publicProfile/alice": {
        uid: "alice",
        displayName: "Alice",
        following: [],
        followers: [],
      },
      "publicProfile/bob": {
        uid: "bob",
        displayName: "Bob",
        following: [],
        followers: [],
      },
      "users/alice/blockedUsers/bob": { schemaVersion: 1 },
      "reports/report": { reporterId: "alice", status: "open" },
      "trips/trip": {
        id: "trip",
        createdBy: "bob",
        joinedUsers: ["alice", "carol"],
        isShared: true,
      },
      "trips/trip/members/alice": {
        userId: "alice",
        status: "active",
        role: "member",
      },
      "trips/trip/members/carol": {
        userId: "carol",
        status: "active",
        role: "member",
      },
      "chat/trip": { roomId: "trip", usersIds: ["alice", "bob", "carol"] },
      "chat/trip/messages/message": {
        createdBy: "bob",
        data: "",
        moderationRemoved: true,
      },
    };
    for (const [key, value] of Object.entries(data))
      await setDoc(doc(db, key), value);
  });
});
const dbFor = (uid) => env.authenticatedContext(uid).firestore();
const sentMessage = (id, uid, data = "Group update") => ({
  chateId: id, messageStatus: "Sent", createdAt: serverTimestamp(),
  createdBy: uid, sentTo: "trip", messageType: "Text", data,
});

test("invitations and attempt receipts are server-owned and do not grant private trip access", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "trips/private-invite"), {
      id: "private-invite",
      createdBy: "bob",
      joinedUsers: [],
      isShared: false,
    });
    await setDoc(doc(db, "trips/private-invite/invitations/alice"), {
      userId: "alice",
      invitationId: "invite",
      status: "pending",
    });
    await setDoc(doc(db, "invitationAttempts/receipt"), { userId: "alice" });
  });
  const db = dbFor("alice");
  await assertFails(getDoc(doc(db, "trips/private-invite")));
  await assertFails(getDoc(doc(db, "trips/private-invite/invitations/alice")));
  await assertFails(
    setDoc(doc(db, "trips/private-invite/invitations/alice"), {
      status: "accepted",
    }),
  );
  await assertFails(getDoc(doc(db, "invitationAttempts/receipt")));
  await assertFails(
    setDoc(doc(dbFor("bob"), "trips/private-invite/invitations/alice"), {
      status: "pending",
    }),
  );
});

test("assistant credentials and idempotency receipts are inaccessible to ordinary clients", async () => {
  for (const collection of [
    "assistantOAuthRequests",
    "assistantOAuthCodes",
    "assistantOAuthTokens",
    "assistantOAuthGrants",
    "assistantOAuthClients",
    "assistantRequests",
    "assistantQuotas",
    "tripPhotoAssets",
    "tripPhotoQuotas",
  ]) {
    const path = `${collection}/test`;
    await env.withSecurityRulesDisabled((context) =>
      setDoc(doc(context.firestore(), path), { uid: "alice" }),
    );
    await assertFails(getDoc(doc(dbFor("alice"), path)));
    await assertFails(
      setDoc(doc(dbFor("alice"), path), { uid: "alice", revoked: false }),
    );
  }
});

test("reports and block relationships stay private and cannot be forged directly", async () => {
  const alice = dbFor("alice");
  const bob = dbFor("bob");
  await assertSucceeds(getDoc(doc(alice, "users/alice/blockedUsers/bob")));
  await assertFails(getDoc(doc(bob, "users/alice/blockedUsers/bob")));
  await assertFails(setDoc(doc(alice, "users/alice/blockedUsers/carol"), {}));
  await assertFails(deleteDoc(doc(alice, "users/alice/blockedUsers/bob")));
  await assertFails(
    setDoc(doc(alice, "reports/forged"), {
      reporterId: "bob",
      status: "resolved",
    }),
  );
  await assertFails(getDoc(doc(alice, "reports/report")));
  await assertFails(getDoc(doc(bob, "reports/report")));
  const moderator = env
    .authenticatedContext("moderator", { admin: true })
    .firestore();
  await assertSucceeds(getDoc(doc(moderator, "reports/report")));
  await assertFails(
    updateDoc(doc(moderator, "reports/report"), { status: "resolved" }),
  );
  await assertFails(
    setDoc(doc(moderator, "reports/report/audit/forged"), { action: "remove" }),
  );
});
test("blocked users cannot add follows or send join requests in either direction", async () => {
  const alice = dbFor("alice");
  const bob = dbFor("bob");
  await assertFails(
    updateDoc(doc(alice, "publicProfile/alice"), { following: ["bob"] }),
  );
  await assertFails(
    updateDoc(doc(bob, "publicProfile/alice"), { followers: ["bob"] }),
  );
  await assertFails(
    setDoc(doc(alice, "trips/trip/joinRequests/alice"), {
      tripId: "trip",
      userId: "alice",
      status: "pending",
    }),
  );
  await env.withSecurityRulesDisabled((context) =>
    setDoc(doc(context.firestore(), "trips/other"), {
      createdBy: "alice",
      joinedUsers: [],
      isShared: true,
    }),
  );
  await assertFails(
    setDoc(doc(bob, "trips/other/joinRequests/bob"), {
      tripId: "other",
      userId: "bob",
      status: "pending",
    }),
  );
  await assertFails(
    setDoc(doc(dbFor("dave"), "trips/trip/joinRequests/dave"), {
      tripId: "trip",
      userId: "dave",
      status: "pending",
    }),
  );
});
test("legacy, member, trip-array and chat paths cannot bypass server admission", async () => {
  const bob = dbFor("bob");
  const dave = dbFor("dave");
  await assertFails(
    updateDoc(doc(bob, "trips/trip"), { joinedUsers: arrayUnion("dave") }),
  );
  await assertFails(
    setDoc(doc(bob, "trips/trip/members/dave"), {
      userId: "dave",
      role: "member",
      status: "active",
    }),
  );
  await assertFails(
    setDoc(doc(dave, "trips/trip/members/dave"), {
      userId: "dave",
      role: "creator",
      status: "active",
    }),
  );
  await assertFails(
    setDoc(doc(dave, "trips/trip/Members/dave"), { userId: "dave" }),
  );
  await assertFails(
    updateDoc(doc(bob, "chat/trip"), { usersIds: ["alice", "bob", "dave"] }),
  );
});
test("chat roster is server-owned and room time requires a new message", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "chat/trip"), {
      roomId: "trip", usersIds: ["alice", "bob"], users: [], updatedAt: Timestamp.now(),
    });
  });
  const alice = dbFor("alice");
  const carol = dbFor("carol");
  await assertFails(updateDoc(doc(alice, "chat/trip"), {usersIds: ["alice"]}));
  await assertFails(updateDoc(doc(alice, "chat/trip"), {usersIds: ["alice", "bob", "dave"]}));
  await assertFails(updateDoc(doc(alice, "chat/trip"), {roomId: "other"}));
  await assertFails(updateDoc(doc(carol, "chat/trip"), {
    usersIds: ["alice", "bob", "carol"], updatedAt: serverTimestamp(),
  }));
  await assertFails(updateDoc(doc(alice, "chat/trip"), {updatedAt: serverTimestamp()}));
  await assertFails(updateDoc(doc(alice, "chat/trip"), {users: [{id: "bob", name: "Forged"}]}));
  await assertFails(updateDoc(doc(alice, "chat/trip"), {usersIds: ["alice", "bob"]}));
  await assertFails(setDoc(doc(alice, "chat/new-room"), {
    roomId: "new-room", usersIds: ["alice"], users: [], updatedAt: serverTimestamp(),
  }));
  const batch = writeBatch(alice);
  batch.set(doc(alice, "chat/trip/messages/room-linked"), sentMessage("room-linked", "alice"));
  batch.update(doc(alice, "chat/trip"), {
    updatedAt: serverTimestamp(), lastMessageId: "room-linked",
  });
  await assertSucceeds(batch.commit());
  await assertFails(updateDoc(doc(alice, "chat/trip"), {
    updatedAt: serverTimestamp(), lastMessageId: "room-linked",
  }));
});

test("existing shared trips, group messages and expense settlement remain available", async () => {
  const alice = dbFor("alice");
  const carol = dbFor("carol");
  await assertSucceeds(getDoc(doc(alice, "trips/trip")));
  for (const [db, uid] of [
    [alice, "alice"],
    [carol, "carol"],
  ]) {
    await assertSucceeds(
      setDoc(doc(db, `chat/trip/messages/${uid}`), sentMessage(uid, uid)),
    );
  }
  await assertSucceeds(
    setDoc(doc(alice, "trips/trip/expenses/expense"), {
      createdBy: "alice",
      tripId: "trip",
      amount: 10,
    }),
  );
  await assertSucceeds(
    updateDoc(doc(alice, "trips/trip/expenses/expense"), { amount: 0 }),
  );
  await assertSucceeds(
    updateDoc(doc(alice, "trips/trip/members/alice"), {
      status: "left",
      removedAt: new Date(),
    }),
  );
});

test("sent chat messages have immutable identity, content and server time", async () => {
  const alice = dbFor("alice");
  const ref = doc(alice, "chat/trip/messages/new-message");
  await assertSucceeds(setDoc(ref, sentMessage("new-message", "alice")));
  await assertFails(setDoc(ref, sentMessage("new-message", "alice", "Replaced")));
  await assertFails(updateDoc(ref, {data: "Edited"}));
  await assertFails(deleteDoc(ref));
  const invalid = [
    {...sentMessage("bad", "alice"), chateId: "other"},
    {...sentMessage("bad", "alice"), createdBy: "bob"},
    {...sentMessage("bad", "alice"), sentTo: "other"},
    {...sentMessage("bad", "alice"), messageType: "Image"},
    {...sentMessage("bad", "alice"), messageStatus: "Pending"},
    {...sentMessage("bad", "alice"), createdAt: Timestamp.now()},
    {...sentMessage("bad", "alice"), data: ""},
    {...sentMessage("bad", "alice"), data: "x".repeat(4001)},
    {...sentMessage("bad", "alice"), moderationRemoved: false},
    {...sentMessage("bad", "alice"), callTimeTaken: 1},
  ];
  for (const forged of invalid) {
    await assertFails(setDoc(doc(alice, "chat/trip/messages/bad"), forged));
  }
});
test("removed content cannot be restored and restrictions affect existing sessions", async () => {
  const bob = dbFor("bob");
  await assertFails(
    updateDoc(doc(bob, "chat/trip/messages/message"), { data: "restore" }),
  );
  await assertFails(deleteDoc(doc(bob, "chat/trip/messages/message")));
  await env.withSecurityRulesDisabled((context) =>
    setDoc(doc(context.firestore(), "safetyAccounts/bob"), {
      restricted: true,
    }),
  );
  await assertFails(
    setDoc(doc(bob, "chat/trip/messages/new"), {
      createdBy: "bob",
      data: "new",
    }),
  );
  await assertFails(
    updateDoc(doc(bob, "publicProfile/bob"), { displayName: "new" }),
  );
  await assertFails(
    setDoc(doc(bob, "safetyAccounts/bob"), { restricted: false }),
  );
});
test("new trip creation still supports the creator membership batch", async () => {
  const alice = dbFor("alice");
  const batch = writeBatch(alice);
  batch.set(doc(alice, "trips/new"), {
    id: "new",
    createdBy: "alice",
    joinedUsers: null,
    isShared: false,
  });
  batch.set(doc(alice, "trips/new/members/alice"), {
    userId: "alice",
    role: "creator",
    status: "active",
  });
  batch.set(doc(alice, "users/alice/tripMemberships/new"), {
    role: "creator",
    status: "active",
  });
  await assertSucceeds(batch.commit());
});

test("inbox content is server-owned; only the recipient can read, mark read or dismiss", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), "notifications/alice/notification/n"),
      {
        createdBy: "bob",
        notificationStatus: "unread",
        isActive: true,
        sentTo: ["alice"],
        notificationMessage: "Hello",
      },
    );
    await setDoc(doc(context.firestore(), "trips/trip/joinRequests/alice"), {
      status: "accepted",
      attemptId: "one",
    });
  });
  const alice = dbFor("alice");
  const bob = dbFor("bob");
  const note = doc(alice, "notifications/alice/notification/n");
  await assertSucceeds(getDoc(note));
  await assertFails(getDoc(doc(bob, note.path)));
  await assertSucceeds(updateDoc(note, { notificationStatus: "read" }));
  await assertSucceeds(updateDoc(note, { isActive: false }));
  for (const data of [
    { notificationMessage: "forged" },
    { createdBy: "alice" },
    { sentTo: ["bob"] },
    { pushEnabled: true },
    { notificationStatus: "accepted" },
  ]) {
    await assertFails(updateDoc(note, data));
  }
  await assertFails(
    setDoc(doc(alice, "notifications/alice/notification/fake"), {
      createdBy: "alice",
    }),
  );
  await assertFails(
    setDoc(doc(alice, "notifications/bob/notification/fake"), {
      createdBy: "alice",
    }),
  );
  await assertFails(deleteDoc(note));
  await assertFails(
    updateDoc(doc(alice, "trips/trip/joinRequests/alice"), {
      status: "cancelled",
    }),
  );
  await assertFails(
    updateDoc(doc(bob, "trips/trip/joinRequests/alice"), {
      status: "rejected",
    }),
  );
  await assertFails(setDoc(doc(alice, "joinAttempts/fake"), {}));
  await assertFails(setDoc(doc(alice, "pushDeliveries/fake"), { done: true }));
});
test("chat read cursor is private, bounded and cannot forge unread activity", async () => {
  const alice = dbFor("alice");
  const ref = doc(alice, "users/alice/chatActivity/trip");
  const observed = Timestamp.fromMillis(Date.now() - 60000);
  await assertSucceeds(setDoc(ref, { readAt: observed }));
  await assertSucceeds(updateDoc(ref, { readAt: Timestamp.fromMillis(Date.now() - 30000) }));
  await assertSucceeds(updateDoc(ref, { readAt: serverTimestamp() }));
  await assertFails(updateDoc(ref, { readAt: new Date(0) }));
  await assertFails(updateDoc(ref, { readAt: Timestamp.fromMillis(Date.now() + 60000) }));
  await assertFails(updateDoc(ref, { readAt: "tomorrow" }));
  await assertFails(
    updateDoc(ref, { lastMessageAt: 123, lastSenderId: "bob" }),
  );
  await assertFails(updateDoc(ref, {lastMessageAtTime: Timestamp.now()}));
  await assertFails(getDoc(doc(dbFor("bob"), ref.path)));
  await assertFails(
    setDoc(doc(dbFor("dave"), "users/dave/chatActivity/trip"), {
      readAt: serverTimestamp(),
    }),
  );
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), ref.path), {lastMessageAt: 123});
  });
  await assertSucceeds(updateDoc(ref, {readAt: observed}));
});

test("lodging options preserve authorship and allow only owners or contributors to edit", async () => {
  const option = {
    createdBy: "alice",
    hotelName: "Hotel One",
    hotelAddress: "",
    lodgingType: "Hotel",
    checkInDate: null,
    checkOutDate: null,
    expensePerNight: 80,
    currencyCode: "USD",
    revision: 1,
    isDeleted: false,
  };
  const path = "trips/trip/lodgings/one";
  await assertSucceeds(setDoc(doc(dbFor("alice"), path), option));
  await assertFails(setDoc(doc(dbFor("alice"), "trips/trip/lodgings/no-currency"), {
    ...option, currencyCode: null,
  }));
  await assertSucceeds(
    setDoc(doc(dbFor("alice"), "trips/trip/lodgings/two"), {
      ...option,
      hotelName: "Hotel Two",
    }),
  );
  await assertSucceeds(
    updateDoc(doc(dbFor("alice"), path), { hotelName: "Updated", revision: 2 }),
  );
  await assertSucceeds(
    updateDoc(doc(dbFor("bob"), path), { hotelAddress: "Owner correction", revision: 3 }),
  );
  await assertFails(
    updateDoc(doc(dbFor("carol"), path), { hotelName: "Wrong editor" }),
  );
  await assertFails(
    updateDoc(doc(dbFor("alice"), path), { createdBy: "carol" }),
  );
  await assertFails(
    setDoc(doc(dbFor("dave"), "trips/trip/lodgings/outsider"), {
      ...option,
      createdBy: "dave",
    }),
  );
  await assertFails(
    setDoc(doc(dbFor("alice"), "trips/trip/lodgings/legacy"), option),
  );
  await assertFails(
    updateDoc(doc(dbFor("alice"), path), { expensePerNight: -1 }),
  );
  await assertFails(updateDoc(doc(dbFor("alice"), path), {
    hotelName: "Stale edit", revision: 2,
  }));
  await assertFails(setDoc(doc(dbFor("alice"), "trips/trip/lodgings/invalid-date"), {
    ...option, checkInDate: "2027-02-30T15:00:00+09:00",
    checkOutDate: "2027-03-02T11:00:00+09:00",
  }));
  await assertFails(setDoc(doc(dbFor("alice"), "trips/trip/lodgings/backwards"), {
    ...option, checkInDate: "2027-04-10T15:00:00+09:00",
    checkOutDate: "2027-04-10T11:00:00+09:00",
  }));
  await assertFails(setDoc(doc(dbFor("alice"), "trips/trip/lodgings/no-checkout"), {
    ...option, checkInDate: "2027-04-10T15:00:00+09:00",
  }));
  await assertFails(setDoc(doc(dbFor("alice"), "trips/trip/lodgings/huge-cost"), {
    ...option, expensePerNight: 1000000000,
  }));
  await assertSucceeds(setDoc(doc(dbFor("alice"), "trips/trip/lodgings/dates"), {
    ...option, checkInDate: "2027-04-10T15:00:00.000+09:00",
    checkOutDate: "2027-04-12T11:00:00.000+09:00",
  }));
  await env.withSecurityRulesDisabled(async (context) => {
    const oldOption = {...option, hotelName: "Old option"};
    delete oldOption.currencyCode;
    delete oldOption.revision;
    delete oldOption.isDeleted;
    await setDoc(doc(context.firestore(), "trips/trip/lodgings/old"), oldOption);
  });
  await assertSucceeds(updateDoc(doc(dbFor("alice"), "trips/trip/lodgings/old"), {
    hotelName: "Edited old option", revision: 1, isDeleted: false,
  }));
  await assertFails(deleteDoc(doc(dbFor("alice"), path)));
  await assertFails(updateDoc(doc(dbFor("carol"), path), {
    lodgingType: "", hotelName: "", hotelAddress: "", checkInDate: null,
    checkOutDate: null, expensePerNight: null, revision: 4,
    currencyCode: null,
    isDeleted: true, deletedBy: "carol", deletedAt: serverTimestamp(),
  }));
  await assertSucceeds(updateDoc(doc(dbFor("alice"), path), {
    lodgingType: "", hotelName: "", hotelAddress: "", checkInDate: null,
    checkOutDate: null, expensePerNight: null, revision: 4,
    currencyCode: null,
    isDeleted: true, deletedBy: "alice", deletedAt: serverTimestamp(),
  }));
  const tombstone = (await getDoc(doc(dbFor("alice"), path))).data();
  if (tombstone.hotelName !== "" || tombstone.hotelAddress !== "" ||
      tombstone.expensePerNight !== null) {
    throw new Error("Lodging tombstone retained private content");
  }
  await assertFails(updateDoc(doc(dbFor("alice"), path), {
    hotelName: "Resurrected", revision: 5,
  }));
  await assertFails(setDoc(doc(dbFor("alice"), path), option));
  await assertFails(setDoc(doc(dbFor("alice"), `${path}/likes/alice`), {
    userId: "alice",
  }));
});

test("trip-level lodging requires valid fields and a monotonic revision", async () => {
  const trip = doc(dbFor("bob"), "trips/trip");
  await assertFails(updateDoc(trip, {hotelName: "Hotel"}));
  await assertSucceeds(updateDoc(trip, {hotelName: "Hotel", lodgingRevision: 1}));
  await assertSucceeds(updateDoc(trip, {title: "Unrelated trip edit"}));
  await assertFails(updateDoc(trip, {hotelName: "Stale", lodgingRevision: 1}));
  await assertFails(updateDoc(trip, {
    hotelName: "Invalid date", checkInDate: "2027-02-30T15:00:00+09:00",
    lodgingRevision: 2,
  }));
  await assertFails(updateDoc(trip, {
    checkInDate: "2027-04-12T15:00:00+09:00",
    checkOutDate: "2027-04-10T11:00:00+09:00", lodgingRevision: 2,
  }));
  await assertFails(updateDoc(trip, {expensePerNight: 1000000000, lodgingRevision: 2}));
  await assertFails(updateDoc(trip, {expensePerNight: 125, lodgingRevision: 2}));
  await assertSucceeds(updateDoc(trip, {
    expensePerNight: 125, lodgingCurrencyCode: "JPY", lodgingRevision: 2,
  }));
  await assertSucceeds(updateDoc(trip, {
    checkInDate: "2027-04-10T15:00:00+09:00",
    checkOutDate: "2027-04-12T11:00:00+09:00", lodgingRevision: 3,
  }));
  await assertFails(updateDoc(doc(dbFor("alice"), "trips/trip"), {
    hotelName: "Non-owner", lodgingRevision: 4,
  }));
  await assertSucceeds(updateDoc(trip, {
    lodgingType: null, hotelName: null, hotelAddress: null,
    checkInDate: null, checkOutDate: null, expensePerNight: null,
    lodgingCurrencyCode: null, lodgingRevision: 4,
  }));
  await assertFails(updateDoc(trip, {hotelName: "Stale restoration", lodgingRevision: 3}));
  await assertFails(setDoc(doc(dbFor("bob"), "trips/new-invalid-lodging"), {
    id: "new-invalid-lodging", createdBy: "bob", joinedUsers: [],
    checkInDate: "2027-02-30T15:00:00+09:00",
  }));
});

test("lodging likes are per traveler, cannot impersonate others, and reject departed or restricted members", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "trips/trip/lodgings/one"), {
      createdBy: "bob",
      hotelName: "Hotel",
    });
  });
  for (const id of ["one", "legacy"]) {
    const path = `trips/trip/lodgings/${id}/likes/alice`;
    await assertSucceeds(
      setDoc(doc(dbFor("alice"), path), { userId: "alice" }),
    );
    await assertSucceeds(
      setDoc(doc(dbFor("alice"), path), { userId: "alice" }),
    );
    await assertFails(setDoc(doc(dbFor("carol"), path), { userId: "alice" }));
    await assertFails(deleteDoc(doc(dbFor("carol"), path)));
    await assertSucceeds(deleteDoc(doc(dbFor("alice"), path)));
  }
  await assertFails(
    setDoc(doc(dbFor("alice"), "trips/trip/lodgings/missing/likes/alice"), {
      userId: "alice",
    }),
  );
  await env.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), "trips/trip/members/alice"), {
      status: "left",
    });
    await setDoc(doc(context.firestore(), "safetyAccounts/carol"), {
      restricted: true,
    });
  });
  for (const user of ["alice", "carol", "dave"]) {
    await assertFails(
      setDoc(doc(dbFor(user), `trips/trip/lodgings/one/likes/${user}`), {
        userId: user,
      }),
    );
  }
});
