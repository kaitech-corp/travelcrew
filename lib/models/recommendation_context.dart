/// Navigation-only metadata. Never serialize this into a trip document.
class RecommendationContext {
  const RecommendationContext({
    required this.sessionId,
    required this.position,
    required this.viewerUid,
  });

  final String sessionId;
  final int position;
  final String viewerUid;

  Map<String, dynamic> toMap() => {
    'sessionId': sessionId,
    'position': position,
  };
}
