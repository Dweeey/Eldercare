import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eldercareapp/app_routes.dart';

void main() {
  testWidgets('login route renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.login,
      ),
    );
    await tester.pump();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('alerts route renders alerts page', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.alerts,
      ),
    );
    await tester.pump();

    expect(find.text('Alerts'), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
  });
}
