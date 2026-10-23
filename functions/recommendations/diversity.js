const {createHash} = require("node:crypto");

const tie = (seed, id) => createHash("sha256").update(`${seed}:${id}`).digest("hex");

function diversify(candidates, {seed, pageSize = 20, explore = true} = {}) {
  const remaining = candidates.map((item) => ({...item, tie: tie(seed, item.id)}))
      .sort((a, b) => b.score - a.score || a.tie.localeCompare(b.tie));
  const result = [];
  while (remaining.length) {
    const creators = new Map(); const destinations = new Map();
    for (let slot = 0; slot < pageSize && remaining.length; slot++) {
      const allowed = (item) => (creators.get(item.createdBy) || 0) < 2 && (destinations.get(item.destinationKey) || 0) < 4;
      let eligible = remaining.filter(allowed);
      if (!eligible.length) eligible = remaining; // Only diversity limits relax.
      const exploration = explore && pageSize >= 10 && slot === pageSize - 1;
      const picked = exploration ? [...eligible].sort((a, b) => a.tie.localeCompare(b.tie))[0] : eligible[0];
      remaining.splice(remaining.indexOf(picked), 1);
      creators.set(picked.createdBy, (creators.get(picked.createdBy) || 0) + 1);
      destinations.set(picked.destinationKey, (destinations.get(picked.destinationKey) || 0) + 1);
      const {tie: ignored, ...item} = picked; void ignored;
      result.push({...item, selection: exploration ? "seeded_exploration_v1" : "ranked_v1"});
    }
  }
  return result;
}

module.exports = {diversify};
