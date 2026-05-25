import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/logger.dart';

class EmailVerificationDialog extends StatefulWidget {
  const EmailVerificationDialog({super.key});

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  String? _statusMessage;
  Color _statusColor = Colors.black87;
  bool _busy = false;

  Future<void> _handleResend() async {
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    final result = await AuthService.resendVerificationEmail();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final max = AuthService.maxVerificationResendsPerEmail;
    setState(() {
      _busy = false;
      switch (result) {
        case ResendVerificationResult.sent:
          _statusMessage = l10n.emailVerificationStatusSent;
          _statusColor = AppColors.kPrimaryColor;
        case ResendVerificationResult.limitReached:
          _statusMessage = l10n.emailVerificationStatusLimitReached(max);
          _statusColor = Colors.red;
        case ResendVerificationResult.alreadyVerified:
          _statusMessage = l10n.emailVerificationStatusAlreadyVerified;
          _statusColor = AppColors.kPrimaryColor;
        case ResendVerificationResult.notSignedIn:
          _statusMessage = l10n.emailVerificationStatusSessionExpired;
          _statusColor = Colors.red;
        case ResendVerificationResult.failed:
          _statusMessage = l10n.emailVerificationStatusFailed;
          _statusColor = Colors.red;
      }
    });
  }

  Future<void> _handleRetry() async {
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    final verified = await AuthService.confirmEmailVerificationAndUpdate();
    if (!mounted) return;
    if (verified) {
      Get.back();
      Get.offAllNamed(kMainViewScreenRoute);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = false;
      _statusMessage = l10n.emailVerificationStatusStillUnverified;
      _statusColor = Colors.red;
    });
  }

  Future<void> _handleCancel() async {
    setState(() {
      _busy = true;
    });
    try {
      await AuthService.cancelEmailVerification();
    } catch (e) {
      AppLogger.error('EmailVerificationDialog cancel failed: $e');
    }
    if (!mounted) return;
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remaining = AuthService.verificationResendsRemaining();
    final max = AuthService.maxVerificationResendsPerEmail;
    final canResend = !_busy && remaining > 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleCancel();
      },
      child: AlertDialog(
        title: Text(l10n.emailVerificationTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.emailVerificationBody),
            const SizedBox(height: 8),
            Text(
              l10n.emailVerificationSpamHint,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.emailVerificationResendsRemaining(max, remaining),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              Text(_statusMessage!, style: TextStyle(color: _statusColor)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : _handleCancel,
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: canResend ? _handleResend : null,
            child: Text(l10n.emailVerificationActionResend),
          ),
          ElevatedButton(
            onPressed: _busy ? null : _handleRetry,
            child: Text(l10n.emailVerificationActionRetry),
          ),
        ],
      ),
    );
  }
}
