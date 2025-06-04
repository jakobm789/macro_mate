import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:macro_mate/pages/login_page.dart';

void main() {
  testWidgets('Login page displays title and login button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    expect(find.text('MacroMate Login'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
