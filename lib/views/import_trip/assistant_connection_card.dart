import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

const assistantBaseUrl = String.fromEnvironment(
  'ASSISTANT_BASE_URL',
  defaultValue: 'https://travelcrew.app/assistant',
);
const assistantMcpUrl = String.fromEnvironment(
  'ASSISTANT_MCP_URL',
  defaultValue: 'https://travelcrew.app/mcp',
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
            const Text(
              'Ask for No image or a Suggested destination photo. Suggestions use verified Public domain or CC0 Wikimedia Commons photos; the trip still saves if a photo is unavailable. You can also upload your own cover in the app.',
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
                      const ClipboardData(text: assistantMcpUrl),
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
