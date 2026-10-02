import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/custom_bottom_bar.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in [
    const Size(375, 812),
    const Size(820, 1180),
    const Size(1180, 820),
    const Size(540, 820),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('navigation fits $size at text scale $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var selected = -1;
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            enableScaleWH: () => ScreenUtil().screenWidth < 600,
            enableScaleText: () => ScreenUtil().screenWidth < 600,
            builder:
                (context, child) => MaterialApp(
                  home: MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
                    child: Scaffold(
                      body: Align(
                        alignment: Alignment.bottomCenter,
                        child: CustomBottomBar(
                          selectedIndex: 0,
                          onTap: (index) => selected = index,
                          navItems: const [
                            BottomNavigationBarItem(
                              icon: Icon(Icons.home),
                              label: 'Explore',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.luggage),
                              label: 'My Trips',
                            ),
                            BottomNavigationBarItem(
                              icon: SizedBox.shrink(),
                              label: '',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.chat),
                              label: 'Inbox',
                            ),
                            BottomNavigationBarItem(
                              icon: Icon(Icons.person),
                              label: 'Profile',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('My Trips'));
        expect(selected, 1);
        if (size.width >= 600) expect(AppStyles.fontSize28, 28);
      });
    }
  }
}
