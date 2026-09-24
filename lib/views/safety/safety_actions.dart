import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/services/safety_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';

String safetyError(BuildContext context, Object error) {
  final l = AppLocalizations.of(context)!;
  if (error is FirebaseFunctionsException) {
    if (error.code == 'resource-exhausted') return l.safetyRateLimit;
    if (error.code == 'not-found') return l.safetyUnavailable;
    if (error.code == 'permission-denied' || error.code == 'unauthenticated') {
      return l.safetyAccessError;
    }
  }
  return l.safetyTryAgain;
}

Future<void> confirmBlock(BuildContext context, String userId) async {
  final l = AppLocalizations.of(context)!;
  final blocked = SafetyService.isBlocked(userId);
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          title: Text(
            blocked ? l.safetyUnblock : l.safetyBlock,
            style: AppStyles.labelTextStyle().copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            blocked ? l.safetyUnblockExplanation : l.safetyBlockExplanation,
            style: AppStyles.labelTextStyle(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.safetyCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(blocked ? l.safetyUnblock : l.safetyBlock),
            ),
          ],
        ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await SafetyService.setBlocked(userId, !blocked);
    if (context.mounted) {
      showCustomSnackBar(
        content: blocked ? l.safetyUnblocked : l.safetyBlocked,
      );
    }
  } catch (error) {
    if (context.mounted) {
      showCustomSnackBar(content: safetyError(context, error));
    }
  }
}

Future<void> showReportSheet(
  BuildContext context, {
  required String targetType,
  required String targetId,
  required String authorId,
  String? roomId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: AppColors.kWhiteColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
  ),
  builder:
      (_) => ReportSheet(
        targetType: targetType,
        targetId: targetId,
        authorId: authorId,
        roomId: roomId,
      ),
);

class SafetyMenu extends StatelessWidget {
  const SafetyMenu({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.authorId,
    this.roomId,
    this.color,
  });
  final String targetType, targetId, authorId;
  final String? roomId;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (authorId.isEmpty || authorId == GlobalVariables.currentUid) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context)!;
    final reportLabel =
        targetType == 'user'
            ? l.safetyReportUser
            : targetType == 'trip'
            ? l.safetyReportTrip
            : l.safetyReportMessage;
    return Obx(
      () => PopupMenuButton<String>(
        tooltip: l.safetyActions,
        enabled: !SafetyService.busyIds.contains(authorId),
        icon: Icon(Icons.more_horiz, color: color ?? AppColors.kPrimaryColor),
        color: AppColors.kWhiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        onSelected: (action) async {
          if (action == 'block') {
            await confirmBlock(context, authorId);
          } else {
            await showReportSheet(
              context,
              targetType: targetType,
              targetId: targetId,
              authorId: authorId,
              roomId: roomId,
            );
          }
        },
        itemBuilder:
            (_) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      color: AppColors.kPrimaryColor,
                    ),
                    const SizedBox(width: 12),
                    Flexible(child: Text(reportLabel)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(
                      Icons.block_outlined,
                      color: AppColors.kPrimaryColor,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        SafetyService.isBlocked(authorId)
                            ? l.safetyUnblock
                            : l.safetyBlock,
                      ),
                    ),
                  ],
                ),
              ),
            ],
      ),
    );
  }
}

class ReportSheet extends StatefulWidget {
  const ReportSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.authorId,
    this.roomId,
  });
  final String targetType, targetId, authorId;
  final String? roomId;
  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  final _details = TextEditingController();
  String _requestId = const Uuid().v4();
  String? _reason;
  String? _error;
  bool _busy = false;
  bool _sent = false;
  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _reason == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SafetyService.report(
        targetType: widget.targetType,
        targetId: widget.targetId,
        roomId: widget.roomId,
        reason: _reason!,
        details: _details.text.trim(),
        requestId: _requestId,
      );
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (mounted) setState(() => _error = safetyError(context, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final reasons = {
      'harassment': l.safetyHarassment,
      'hate': l.safetyHate,
      'sexual': l.safetySexual,
      'violence': l.safetyViolence,
      'spam': l.safetySpam,
      'other': l.safetyOther,
    };
    return PopScope(
      canPop: !_busy,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .85,
            maxWidth: 600,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.kLightGreyColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  _sent ? l.safetyReportSent : l.safetyReportContent,
                  style: AppStyles.labelTextStyle().copyWith(
                    fontSize: AppStyles.fontSize22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  _sent ? l.safetyReportThanks : l.safetyReportExplanation,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: AppColors.kGreyTextColor,
                  ),
                ),
                SizedBox(height: 20.h),
                if (!_sent) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _reason,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l.safetyReason,
                      filled: true,
                      fillColor: AppColors.kLightGreyColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items:
                        reasons.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                    onChanged:
                        _busy
                            ? null
                            : (value) => setState(() {
                              _reason = value;
                              _requestId = const Uuid().v4();
                            }),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _details,
                    enabled: !_busy,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 1000,
                    onChanged: (_) => _requestId = const Uuid().v4(),
                    style: AppStyles.labelTextStyle(),
                    decoration: InputDecoration(
                      labelText: l.safetyDetails,
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: AppColors.kLightGreyColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.kRedColor),
                        semanticsLabel: _error,
                      ),
                    ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  CustomElevatedButton(
                    width: double.infinity,
                    title: l.safetySubmit,
                    backgroundColor: AppColors.kPrimaryColor,
                    isDisabled: _busy || _reason == null,
                    onPressed: _submit,
                  ),
                ] else ...[
                  Obx(
                    () => CustomElevatedButton(
                      width: double.infinity,
                      title:
                          SafetyService.isBlocked(widget.authorId)
                              ? l.safetyUnblock
                              : l.safetyBlock,
                      backgroundColor: AppColors.kPrimaryColor,
                      isDisabled: SafetyService.busyIds.contains(
                        widget.authorId,
                      ),
                      onPressed: () => confirmBlock(context, widget.authorId),
                    ),
                  ),
                ],
                TextButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  child: Text(_sent ? l.safetyDone : l.safetyCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SafetyBlockedView extends StatelessWidget {
  const SafetyBlockedView({super.key, required this.userId});
  final String userId;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.block_outlined,
              size: 48,
              color: AppColors.kPrimaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              l.safetyBlocked,
              style: AppStyles.labelTextStyle().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.safetyBlockExplanation,
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle(),
            ),
            const SizedBox(height: 16),
            SafetyMenu(targetType: 'user', targetId: userId, authorId: userId),
          ],
        ),
      ),
    );
  }
}

class SafetyLoadingView extends StatelessWidget {
  const SafetyLoadingView({super.key});
  @override
  Widget build(BuildContext context) => Obx(
    () => Center(
      child:
          SafetyService.failed.value
              ? TextButton(
                onPressed: SafetyService.retry,
                child: Text(AppLocalizations.of(context)!.safetyRetry),
              )
              : const CircularProgressIndicator(),
    ),
  );
}
