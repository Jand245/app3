import 'package:app3/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the home page when the app starts', (tester) async {
    await tester.pumpWidget(const NotesApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.textContaining('Upcoming assignments'), findsOneWidget);
  });

  testWidgets('moves between the main pages', (tester) async {
    await tester.pumpWidget(const NotesApp());

    await tester.tap(find.text('Folders').last);
    await tester.pumpAndSettle();

    expect(find.text('Your note folders will appear here.'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_outlined), findsOneWidget);
  });
}
