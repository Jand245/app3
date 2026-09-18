import 'package:app3/main.dart';
import 'package:app3/models/app_data_store.dart';
import 'package:app3/screens/assignments_screen.dart';
import 'package:app3/screens/folders_screen.dart';
import 'package:app3/screens/note_editor_screen.dart';
import 'package:app3/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses the purple and gold app palette', (tester) async {
    await tester.pumpWidget(const NotesApp());

    final theme = Theme.of(tester.element(find.text('Home').first));
    expect(theme.colorScheme.primary, AppTheme.purple);
    expect(theme.colorScheme.secondary, AppTheme.gold);
    expect(theme.scaffoldBackgroundColor, AppTheme.background);
  });

  testWidgets('shows the home page when the app starts', (tester) async {
    await tester.pumpWidget(const NotesApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Due Soon'), findsOneWidget);
    expect(find.text('Recent notes'), findsOneWidget);
    expect(find.text('Search assignments, folders, and notes'), findsOneWidget);
  });

  testWidgets('home quick note opens blank and does not create on exit', (
    tester,
  ) async {
    final store = AppDataStore();
    await tester.pumpWidget(NotesApp(store: store));

    final button = tester.widget<FloatingActionButton>(
      find.byKey(const Key('home-new-note-button')),
    );
    expect(button.backgroundColor, AppTheme.gold);
    await tester.tap(find.byKey(const Key('home-new-note-button')));
    await tester.pumpAndSettle();
    expect(find.text('New note'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('note-title-field')))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('note-body-field')))
          .controller!
          .text,
      isEmpty,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(store.notes, isEmpty);
    expect(store.folders, isEmpty);
  });

  testWidgets('home quick note saves into one Unfiled folder', (tester) async {
    final store = AppDataStore();
    await tester.pumpWidget(NotesApp(store: store));

    for (final body in ['First idea', 'Second idea']) {
      await tester.tap(find.byKey(const Key('home-new-note-button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('note-body-field')), body);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    expect(store.folders, hasLength(1));
    expect(store.folders.single.name, 'Unfiled');
    expect(store.notes, hasLength(2));
    expect(
      store.notes.every((note) => note.folderId == store.folders.single.id),
      isTrue,
    );
    expect(store.notes.first.title, 'Untitled note');
  });

  testWidgets('home quick note saves typed content when leaving editor', (
    tester,
  ) async {
    final store = AppDataStore();
    await tester.pumpWidget(NotesApp(store: store));

    await tester.tap(find.byKey(const Key('home-new-note-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('note-title-field')),
      'Quick thought',
    );
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(store.notes.single.title, 'Quick thought');
    expect(store.folders.single.name, 'Unfiled');
  });

  testWidgets('saving a blank Home note leaves no Unfiled folder', (
    tester,
  ) async {
    final store = AppDataStore();
    await tester.pumpWidget(NotesApp(store: store));

    await tester.tap(find.byKey(const Key('home-new-note-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(store.notes, isEmpty);
    expect(store.folders, isEmpty);
  });

  testWidgets('Unfiled note can move into a nested folder without a copy', (
    tester,
  ) async {
    final store = AppDataStore();
    store.addUnfiledNote('Quick idea', 'Remember this');
    final originalId = store.notes.single.id;
    final course = store.addFolder('CSC 4103', null);
    final project = store.addFolder('Project', course.id);
    await tester.pumpWidget(MaterialApp(home: FoldersScreen(store: store)));

    expect(find.text('Unfiled'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    await tester.tap(find.text('Unfiled'));
    await tester.pumpAndSettle();
    expect(find.text('Quick idea'), findsOneWidget);

    await tester.tap(find.byTooltip('Note options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CSC 4103 / Project'));
    await tester.pumpAndSettle();

    expect(find.text('Quick idea'), findsNothing);
    expect(store.notes, hasLength(1));
    expect(store.notes.single.id, originalId);
    expect(store.notes.single.folderId, project.id);

    await tester.tap(find.byTooltip('Back to parent folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CSC 4103'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();
    expect(find.text('Quick idea'), findsOneWidget);
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
