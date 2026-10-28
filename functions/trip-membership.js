// A recorded departure overrides a stale legacy roster. Older trips with no
// membership record may still rely on joinedUsers until the first transition.
function isTripMember(trip, uid, member) {
  if (!trip || !uid) return false;
  if (trip.createdBy === uid) return true;
  if (member !== undefined && member !== null) return member.status === "active";
  return Array.isArray(trip.joinedUsers) && trip.joinedUsers.includes(uid);
}

module.exports = {isTripMember};
