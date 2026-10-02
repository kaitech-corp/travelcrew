import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/services/safety_service.dart';
import 'package:travel_crew/views/safety/safety_actions.dart';

Widget app(Widget child, {Locale locale = const Locale('en')}) =>
    ScreenUtilInit(
      designSize: const Size(375, 812),
      enableScaleWH: () => ScreenUtil().screenWidth < 600,
      enableScaleText: () => ScreenUtil().screenWidth < 600,
      builder:
          (_, _) => MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: child),
          ),
    );

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SafetyService.blockedIds.clear();
    SafetyService.ready.value = true;
  });
  tearDown(() {
    SafetyService.blockedIds.clear();
    SafetyService.ready.value = false;
  });

  for (final width in [375.0, 1024.0]) {
    testWidgets(
      'report form requires a reason and remains usable at width $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(
            const ReportSheet(
              targetType: 'trip',
              targetId: 'trip',
              authorId: 'bob',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Harassment or bullying').last);
        await tester.pumpAndSettle();
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNotNull,
        );
        expect(
          tester.widget<TextField>(find.byType(TextField)).maxLength,
          1000,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'message safety menu exposes reporting and reflects a newly blocked sender',
    (tester) async {
      await tester.pumpWidget(
        app(
          const SafetyMenu(
            targetType: 'message',
            targetId: 'message',
            authorId: 'bob',
            roomId: 'trip',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Safety options'));
      await tester.pumpAndSettle();
      expect(find.text('Report message'), findsOneWidget);
      expect(find.text('Block user'), findsOneWidget);
      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();
      SafetyService.blockedIds.add('bob');
      await tester.pump();
      await tester.tap(find.byTooltip('Safety options'));
      await tester.pumpAndSettle();
      expect(find.text('Unblock user'), findsOneWidget);
    },
  );

  for (final locale in [const Locale('es'), const Locale('zh')]) {
    testWidgets('report form loads localized content for $locale', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          const ReportSheet(
            targetType: 'user',
            targetId: 'bob',
            authorId: 'bob',
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Report content'), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
