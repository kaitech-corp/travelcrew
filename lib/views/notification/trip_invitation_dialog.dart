import 'package:flutter/material.dart';
import 'package:travel_crew/services/trip_invitation_service.dart';

class TripInvitationDialog extends StatefulWidget {
  const TripInvitationDialog({
    super.key,
    required this.preview,
    required this.respond,
  });
  final Map<String, dynamic> preview;
  final Future<void> Function(bool accept) respond;

  @override
  State<TripInvitationDialog> createState() => _TripInvitationDialogState();
}

class _TripInvitationDialogState extends State<TripInvitationDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _respond(bool accept) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.respond(accept);
      if (mounted) Navigator.of(context).pop(accept);
    } catch (error) {
      if (mounted) {
        setState(() => _error = TripInvitationService.errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.preview;
    final pending = data['status'] == 'pending';
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: const Text('Trip invitation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title'] as String),
              const SizedBox(height: 8),
              Text('Invited by ${data['inviterName']}'),
              if ((data['destination'] as String).isNotEmpty)
                Text(data['destination'] as String),
              const SizedBox(height: 16),
              Text(
                pending
                    ? 'Accept to join the crew and view the trip itinerary, expenses, and chat.'
                    : 'You have ${data['status']} this invitation.',
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Close'),
          ),
          if (pending)
            TextButton(
              onPressed: _busy ? null : () => _respond(false),
              child: const Text('Decline'),
            ),
          if (pending)
            FilledButton(
              onPressed: _busy ? null : () => _respond(true),
              child: const Text('Accept invitation'),
            ),
          if (data['status'] == 'accepted')
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open trip'),
            ),
        ],
      ),
    );
  }
}
