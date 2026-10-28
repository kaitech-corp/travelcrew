class ActivityVoteState {
  ActivityVoteState._(this.likedBy, this.likesCount, this.changed);

  final List<String> likedBy;
  final int likesCount;
  final bool changed;

  /// Applies a requested state, not a blind +/-1. This also repairs old
  /// duplicate voters or a count that drifted from the actual voter list.
  factory ActivityVoteState.apply(
    Iterable<String> current,
    int currentCount, {
    required String userId,
    required bool shouldLike,
  }) {
    if (userId.isEmpty) throw const FormatException('Sign in to vote.');
    final original = current.toList();
    final voters = original.where((id) => id.isNotEmpty).toSet();
    if (shouldLike) {
      voters.add(userId);
    } else {
      voters.remove(userId);
    }
    final updated = voters.toList();
    return ActivityVoteState._(
      updated,
      updated.length,
      currentCount != updated.length ||
          original.length != updated.length ||
          !original.toSet().containsAll(updated) ||
          !updated.toSet().containsAll(original),
    );
  }
}
