import 'package:flutter/material.dart';

class ChatRoomLoadError extends StatelessWidget {
  const ChatRoomLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(message)),
          // Keep the touch target at least 44 px at every text scale.
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
