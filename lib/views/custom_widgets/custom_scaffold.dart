import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/notification/controller/notification_controller.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../main_view/controller/main_view_controller.dart';
import 'custom_app_bar_widget.dart';
import 'custom_screen_loader.dart';

// ignore: must_be_immutable
class CustomScaffold extends StatefulWidget {
  CustomScaffold({
    super.key,
    required this.className,
    this.isBackIcon = true,
    this.resizeToAvoidBottomInset = true,
    required this.screenName,
    this.subScreenName,
    this.onWillPop,
    this.appBarSize,
    this.centerTitle,
    this.onBackButtonPressed,
    this.gestureDetectorOnPanDown,
    this.gestureDetectorOnTap,
    this.onNotificationListener,
    required this.scaffoldKey,
    required this.body,
    this.padding = const EdgeInsets.only(left: 18, right: 18),
    this.gridview,
    this.bottomBarIndex = 0,
    this.showAppBarProfile = false,
    this.showAppBarBackButton = false,
    this.showActionButton = false,
    this.isFullBody = false,
    this.bottomNavigationBar,
    this.title,
    this.floatingActionButton,
    this.leadingWidth = 70,
    this.listOfPopupMenuItems = const [],
    this.actions = const [],
    this.leadingWidget,
    this.drawer,
    this.backIconColor,
    this.openDrawerCallback,
    this.backgroundColor,
    this.showNotificationBell = false,
  });
  final Widget body;
  final String className;
  final String screenName;
  final int bottomBarIndex;
  final String? subScreenName;
  final Function? onWillPop,
      gestureDetectorOnTap,
      gestureDetectorOnPanDown,
      onNotificationListener;
  final VoidCallback? onBackButtonPressed;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? gridview;
  final bool isBackIcon;
  bool showAppBarProfile = false;
  bool showAppBarBackButton = false;
  bool showActionButton = false;
  bool isFullBody = false;
  bool? centerTitle;
  double? appBarSize;
  Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;
  Widget? title;
  Widget? leadingWidget;
  List<PopupMenuItem<int>> listOfPopupMenuItems = [];
  List<Widget>? actions = [];
  Widget? floatingActionButton;
  double leadingWidth = 70;
  Color? backIconColor;
  EdgeInsets padding = const EdgeInsets.only(left: 15, right: 15);
  Widget? drawer;
  final Function? openDrawerCallback;
  final Color? backgroundColor;
  final bool showNotificationBell;
  @override
  CustomScaffoldState createState() => CustomScaffoldState();
}

class CustomScaffoldState extends State<CustomScaffold> {
  Widget _buildNotificationBell() {
    if (!Get.isRegistered<NotificationController>()) {
      return GestureDetector(
        onTap: () {
          if (Get.isRegistered<MainViewController>()) {
            Get.find<MainViewController>().changeIndex(3);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Image.asset(AppImages.kNotificationIcon, scale: 4),
        ),
      );
    }
    final notifController = Get.find<NotificationController>();
    return Obx(() {
      final unread = notifController.notifications.fold<int>(
        0,
        (sum, group) => sum + group.notifications.length,
      );
      return GestureDetector(
        onTap: () {
          if (Get.isRegistered<MainViewController>()) {
            Get.find<MainViewController>().changeIndex(3);
          } else {
            Get.toNamed('/NotificationScreen');
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(AppImages.kNotificationIcon, scale: 4),
              if (unread > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppStyles.fontSize12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    //   statusBarColor: Colors.transparent,
    // ));
    final effectiveActions = [
      if (widget.showNotificationBell) _buildNotificationBell(),
      ...?widget.actions,
    ];
    return PopScope(
      canPop: widget.onWillPop == null,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && widget.onWillPop != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onWillPop?.call();
          });
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.gestureDetectorOnTap != null) {
                widget.gestureDetectorOnTap!();
              }
            },
            onPanDown: (panDetails) {
              if (widget.gestureDetectorOnPanDown != null) {
                widget.gestureDetectorOnPanDown!(panDetails);
              }
            },
            child: NotificationListener(
              onNotification: (notificationInfo) {
                if (widget.onNotificationListener != null) {
                  return widget.onNotificationListener!(notificationInfo);
                } else {
                  return false;
                }
              },
              child: Scaffold(
                resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                backgroundColor:
                    widget.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                key: widget.scaffoldKey,
                drawer: widget.drawer,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(widget.appBarSize ?? 60),
                  child: CustomAppBar(
                    onBackButtonTap: widget.onBackButtonPressed,
                    title: widget.title,
                    leadingWidth: widget.leadingWidth,
                    backIcon: widget.isBackIcon,
                    actions: effectiveActions,
                    backIconColor: widget.backIconColor,
                    scaffoldKey: widget.scaffoldKey,
                    centerTitle: widget.centerTitle ?? false,
                    leadingWidget: widget.leadingWidget,
                    screenTitleColor:
                        Theme.of(context).textTheme.bodyLarge!.color,
                    screenTitle: widget.screenName,
                    className: widget.className,
                  ),
                ),
                body:
                    widget.isFullBody
                        ? Container(child: widget.body)
                        : Container(
                          // width: Get.width,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          padding: widget.padding,
                          decoration: BoxDecoration(
                            color:
                                widget.backgroundColor ??
                                Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: SafeArea(
                            child: Column(
                              children: [
                                Flexible(child: Container(child: widget.body)),
                              ],
                            ),
                          ),
                        ),
                extendBodyBehindAppBar: true,
                bottomNavigationBar:
                    widget.bottomNavigationBar ??
                    const SizedBox(width: 0, height: 0),
                floatingActionButton: widget.floatingActionButton,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
              ),
            ),
          ),
          const LoaderView(),
        ],
      ),
    );
  }
}

Future<bool?> showExitConfirmationDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: () => exit(0), child: const Text('Exit')),
        ],
      );
    },
  );
}
