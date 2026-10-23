const {DAY, millis} = require("./features");

const ALGORITHM_VERSION = "weighted-v1";

function affinity(feature, profile) {
  const choices = new Set(profile.destinations || []);
  if (feature.destinationKeys.some((key) => choices.has(key))) return 1;
  let best = 0;
  for (const item of profile.history || []) {
    const similarity = item.destinationKey === feature.destinationKey && item.countryKey === feature.countryKey ? 0.85 :
      item.countryKey === feature.countryKey ? 0.55 : item.continentKey && item.continentKey === feature.continentKey ? 0.15 : 0;
    // Unknown timestamps remain weak positive evidence, without fabricated age.
    best = Math.max(best, similarity * (item.confidence ?? 1));
  }
  return best;
}

function score(feature, profile, now) {
  const destination = affinity(feature, profile);
  const follows = (profile.following || []).includes(feature.createdBy) ? 1 : 0;
  const popularity = Math.log1p(feature.popularity) / Math.log1p(1000);
  const published = millis(feature.publishedAt);
  const freshness = published == null ? 0.5 : Math.exp(-Math.max(0, now - published) / (30 * DAY));
  const hasAffinity = !!(profile.destinations?.length || profile.history?.length);
  const hasSocial = !!profile.following?.length;
  // Weight availability depends on the user, never on a candidate's missing
  // match. This keeps scores comparable across every page of one session.
  const weights = [hasAffinity ? 0.55 : 0, hasSocial ? 0.25 : 0, 0.15, 0.05];
  const value = [destination, follows, popularity, freshness].reduce((sum, v, i) => sum + v * weights[i], 0) / weights.reduce((a, b) => a + b, 0);
  const reason = follows ? "followed_creator" : destination > 0 ? "preferred_destination" : "popular_upcoming";
  return {id: feature.id, score: value, reason, destinationKey: feature.destinationKey,
    createdBy: feature.createdBy, components: {destination, follows, popularity, freshness}, feature};
}

module.exports = {ALGORITHM_VERSION, affinity, score};
