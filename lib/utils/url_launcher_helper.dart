import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the device's default browser (external application).
/// Shows a snackbar if the link can't be opened.
Future<void> openExternalUrl(String url) async {
  try {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      showCustomSnackBar(content: 'Could not open the link');
    }
  } catch (e, stack) {
    ErrorHandler.handleError(
      e,
      stackTrace: stack,
      context: 'openExternalUrl',
    );
    showCustomSnackBar(content: 'Could not open the link');
  }
}
