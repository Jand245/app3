import 'package:app3/main.dart';
import 'package:app3/models/app_data_store.dart';
import 'package:app3/models/assignment_item.dart';
import 'package:app3/screens/assignments_screen.dart';
import 'package:app3/screens/folders_screen.dart';
import 'package:app3/screens/note_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the home page when the app starts', (tester) async {
    await tester.pumpWidget(const NotesApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Due Soon'), findsOneWidget);
    expect(find.text('Recent notes'), findsOneWidget);
    expect(find.text('Search assignments, folders, and notes'), findsOneWidget);
  });

  testWidgets('moves between the main pages', (tester) async {
    await tester.pumpWidget(const NotesApp());

    await tester.tap(find.text('Folders').last);
    await tester.pumpAndSettle();

    expect(find.text('Folders'), findsNWidgets(2));
    expect(find.text('Subfolders'), findsNothing);
    expect(find.textContaining('No folders yet'), findsOneWidget);
  });

  testWidgets('creates, renames, and deletes a folder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FoldersScreen(store: AppDataStore())),
    );

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
    await tester.pumpWidget(
      MaterialApp(home: FoldersScreen(store: AppDataStore())),
    );

    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'CSC 4103');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CSC 4103'));
    await tester.pumpAndSettle();
    expect(find.textContaining('This folder is empty'), findsOneWidget);

    await tester.tap(find.byTooltip('New subfolder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Project');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Project'), findsOneWidget);
    expect(find.text('Subfolders'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to parent folder'));
    await tester.pumpAndSettle();

    expect(find.text('CSC 4103'), findsOneWidget);
    expect(find.text('Project'), findsNothing);
  });

  testWidgets('creates, edits, and deletes a note inside a folder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: FoldersScreen(store: AppDataStore())),
    );

    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'CSC 4103');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CSC 4103'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title-field')),
      'Project ideas',
    );
    await tester.enterText(
      find.byKey(const Key('note-body-field')),
      'Build the folder screen first.',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Project ideas'), findsOneWidget);
    expect(find.text('Build the folder screen first.'), findsOneWidget);

    await tester.tap(find.text('Project ideas'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title-field')),
      'Updated project ideas',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Updated project ideas'), findsOneWidget);

    await tester.tap(find.byTooltip('Note options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.textContaining('This folder is empty'), findsOneWidget);
  });

  testWidgets('creates an assignment and opens its details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AssignmentsScreen(store: AppDataStore())),
    );

    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('No assignments due this week.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-assignment-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('assignment-title-field')),
      'Lab report',
    );
    await tester.enterText(
      find.byKey(const Key('assignment-course-field')),
      'Biology',
    );
    await tester.enterText(
      find.byKey(const Key('assignment-requirements-field')),
      'Include the results and conclusion.',
    );
    expect(find.text('Due time'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Lab report'), findsOneWidget);
    await tester.tap(find.text('Lab report'));
    await tester.pumpAndSettle();

    expect(find.text('Assignment details'), findsOneWidget);
    expect(find.text('Include the results and conclusion.'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit assignment'), findsOneWidget);
    expect(find.text('Lab report'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('assignment-title-field')),
      'Updated lab report',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Updated lab report'), findsOneWidget);
    expect(find.text('Lab report'), findsNothing);
  });

  testWidgets('opens the monthly calendar from the week card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AssignmentsScreen(store: AppDataStore())),
    );

    await tester.tap(find.byKey(const Key('open-month-calendar')));
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.byKey(const Key('monthly-calendar')), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('finishes and deletes assignments from their details', (
    tester,
  ) async {
    final store = AppDataStore();
    final dueDate = DateTime.now().add(const Duration(hours: 1));
    store.addAssignment(
      AssignmentItem(
        id: 'finish-me',
        title: 'Finish me',
        course: 'Biology',
        requirements: '',
        dueDate: dueDate,
        colorValue: 0xff183b66,
      ),
    );
    store.addAssignment(
      AssignmentItem(
        id: 'delete-me',
        title: 'Delete me',
        course: 'History',
        requirements: '',
        dueDate: dueDate,
        colorValue: 0xff183b66,
      ),
    );

    await tester.pumpWidget(MaterialApp(home: AssignmentsScreen(store: store)));

    await tester.tap(find.text('Finish me'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('finish-assignment-button')), findsOneWidget);
    expect(find.byKey(const Key('delete-assignment-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('finish-assignment-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-finish-assignment')));
    await tester.pumpAndSettle();
    expect(find.text('Previous assignments'), findsOneWidget);
    expect(find.text('Finish me'), findsOneWidget);
    expect(
      store.assignments
          .singleWhere((item) => item.id == 'finish-me')
          .isCompleted,
      isTrue,
    );

    await tester.tap(find.text('Delete me'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-assignment-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-assignment')));
    await tester.pumpAndSettle();
    expect(find.text('Delete me'), findsNothing);
    expect(store.assignments, hasLength(1));
    expect(store.assignments.single.id, 'finish-me');
  });

  testWidgets('warns before leaving an unsaved note', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
              ),
              child: const Text('Open editor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('note-body-field')),
      'Unsaved work',
    );
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Leave without saving?'), findsOneWidget);
    expect(find.text('Keep editing'), findsOneWidget);
    expect(find.text('Leave'), findsOneWidget);
  });
}
