import 'package:app3/main.dart';
import 'package:app3/screens/folders_screen.dart';
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

    expect(find.textContaining('No folders yet'), findsOneWidget);
  });

  testWidgets('creates, renames, and deletes a folder', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FoldersScreen()));

    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  CSC 4103  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('CSC 4103'), findsOneWidget);

    await tester.tap(find.byTooltip('Folder options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Software Engineering');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Software Engineering'), findsOneWidget);
    expect(find.text('CSC 4103'), findsNothing);

    await tester.tap(find.byTooltip('Folder options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No folders yet'), findsOneWidget);
  });

  testWidgets('opens a folder and creates a subfolder', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FoldersScreen()));

    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'CSC 4103');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CSC 4103'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No subfolders yet'), findsOneWidget);

    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Project');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Project'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to parent folder'));
    await tester.pumpAndSettle();

    expect(find.text('CSC 4103'), findsOneWidget);
    expect(find.text('Project'), findsNothing);
  });
}
