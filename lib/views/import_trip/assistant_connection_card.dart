import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

const assistantBaseUrl = String.fromEnvironment(
  'ASSISTANT_BASE_URL',
  defaultValue: 'https://universal-code-135522.web.app/assistant',
);

class AssistantConnectionCard extends StatelessWidget {
  const AssistantConnectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send trips directly from your assistant',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add TravelCrew as a custom MCP connection in a compatible AI '
              'assistant, then sign in and allow trip creation. Ask it to save '
              'your itinerary to TravelCrew. Your trip arrives privately in My Trips.',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy connection URL'),
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: '$assistantBaseUrl/mcp'),
                    );
                    showCustomSnackBar(content: 'Connection URL copied');
                  },
                ),
                TextButton(
                  child: const Text('Manage connections'),
                  onPressed: () async {
                    try {
                      if (!await launchUrl(
                        Uri.parse('$assistantBaseUrl/connect'),
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw StateError('Browser unavailable');
                      }
                    } catch (_) {
                      showCustomSnackBar(content: 'Could not open connections');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
