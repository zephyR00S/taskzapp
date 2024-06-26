import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskzapp/main.dart';

import 'package:taskzapp/util/dialog_box.dart'; // Import your HomePage

void main() {
  testWidgets('Todo app smoke test', (WidgetTester tester) async {
    // Create a mock database

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the welcome text is present
    expect(find.text('Welcome'), findsOneWidget);

    // Verify that the "What are your plans ?" text is present
    expect(find.text('What are your plans ?'), findsOneWidget);

    // Verify that the add button is present
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Tap the add button and trigger a frame
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that the dialog box appears
    expect(find.byType(DialogBox), findsOneWidget);

    // You can add more specific tests here, such as adding a todo item,
    // checking if it appears in the list, marking it as complete, etc.
  });
}
