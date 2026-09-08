import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/features/gym/presentation/widgets/activity_heatmap_widget.dart';

void main() {
  testWidgets('Heatmap fits a narrow phone at large text scale',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: ActivityHeatmapWidget(
            now: DateTime(2026, 9, 8),
            activityStartTimes: const [
              '2026-09-08T10:00:00',
              '2026-09-08T18:00:00',
              '2026-09-07T10:00:00',
              'invalid',
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Serie: 2 Tage'), findsOneWidget);
    expect(find.text('3 Workouts in der Historie erfasst'), findsOneWidget);
    expect(find.byTooltip('2026-09-08: 2 Aktivität(en)'), findsOneWidget);
  });
}
