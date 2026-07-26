import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/import_trip/import_trip_controller.dart';

class ImportTripScreen extends StatefulWidget {
  const ImportTripScreen({super.key});

  @override
  State<ImportTripScreen> createState() => _ImportTripScreenState();
}

class _ImportTripScreenState extends State<ImportTripScreen> {
  final ImportTripController controller = Get.find<ImportTripController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _pasteFocusNode = FocusNode();
  bool _showJumpToPaste = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pasteFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // Hide the button once the user is near the paste field at the bottom.
    final nearBottom =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 120;
    if (nearBottom == _showJumpToPaste) {
      setState(() => _showJumpToPaste = !nearBottom);
    }
  }

  Future<void> _jumpToPaste() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
    _pasteFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: 'Import from AI',
      centerTitle: true,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
      floatingActionButton:
          _showJumpToPaste
              ? FloatingActionButton.extended(
                onPressed: _jumpToPaste,
                backgroundColor: AppColors.kPrimaryColor,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                label: Text(
                  'Jump to paste',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppStyles.fontSize13,
                  ),
                ),
              )
              : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            _buildStep(
              number: '1',
              title: 'Copy this prompt',
              child: _PromptCard(controller: controller),
            ),
            SizedBox(height: 24.h),
            _buildStep(
              number: '2',
              title: 'Ask your AI to plan your trip',
              child: _buildHint(),
            ),
            SizedBox(height: 24.h),
            _buildStep(
              number: '3',
              title: 'Paste the response below',
              child: _PasteField(
                controller: controller,
                focusNode: _pasteFocusNode,
              ),
            ),
            SizedBox(height: 32.h),
            Obx(
              () => CustomElevatedButton(
                width: Get.width,
                title:
                    controller.isParsing.value ? 'Importing...' : 'Import Trip',
                onPressed:
                    controller.isParsing.value ? () {} : controller.importTrip,
                height: 52.h,
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.kPrimaryColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppStyles.fontSize13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        child,
      ],
    );
  }

  Widget _buildHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Paste the prompt into ChatGPT, Claude, Gemini, or any AI assistant. Describe your trip in the chat, then ask it to format the output using the prompt.',
        style: AppStyles.labelTextStyle().copyWith(
          fontSize: AppStyles.fontSize13,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.controller});
  final ImportTripController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _CopyPromptButton(controller: controller),
          ),
          SizedBox(height: 8.h),
          Text(
            ImportTripController.aiPrompt,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: AppStyles.fontSize14,
              color: Color(0xFF333333),
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: _CopyPromptButton(controller: controller),
          ),
        ],
      ),
    );
  }
}

class _CopyPromptButton extends StatelessWidget {
  const _CopyPromptButton({required this.controller});
  final ImportTripController controller;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: controller.copyPrompt,
      icon: const Icon(Icons.copy_rounded, size: 16),
      label: const Text('Copy Prompt'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.kPrimaryColor,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppStyles.fontSize13,
        ),
      ),
    );
  }
}

class _PasteField extends StatelessWidget {
  const _PasteField({required this.controller, this.focusNode});
  final ImportTripController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.pasteController,
      focusNode: focusNode,
      maxLines: 12,
      style: AppStyles.labelTextStyle().copyWith(
        fontSize: AppStyles.fontSize13,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Paste the JSON output from your AI here...',
        hintStyle: AppStyles.labelTextStyle().copyWith(
          fontSize: AppStyles.fontSize13,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.kPrimaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
