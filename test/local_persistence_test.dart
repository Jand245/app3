import 'dart:io';

import 'package:app3/models/app_data_store.dart';
import 'package:app3/models/assignment_item.dart';
import 'package:app3/models/local_data_storage.dart';
import 'package:app3/models/note_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JsonFileStorage storage;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('app3-data-test-');
    storage = JsonFileStorage(File('${directory.path}/data.json'));
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('folders, notes, assignments, and IDs survive reload', () async {
    final store = await AppDataStore.load(storage);
    final root = store.addFolder('CSC 4103', null);
    final child = store.addFolder('Project', root.id);
    store.addNote(child.id, 'Idea', 'Build a notes app');
    store.addAssignment(
      AssignmentItem(
        id: 'assignment-1',
        title: 'Project proposal',
        course: 'CSC 4103',
        requirements: 'One page',
        dueDate: DateTime(2026, 10, 1, 17, 30),
        colorValue: 0xff123456,
        attachments: const [
          AssignmentAttachment(name: 'outline.pdf', path: '/tmp/outline.pdf'),
        ],
      ),
    );
    await store.flush();
    store.dispose();

    final restored = await AppDataStore.load(storage);
    expect(restored.folders, hasLength(2));
    expect(restored.folders.last.parentId, root.id);
    expect(restored.notes.single.body, 'Build a notes app');
    expect(restored.recentNotes.single.title, 'Idea');
    expect(restored.assignments.single.dueDate, DateTime(2026, 10, 1, 17, 30));
    expect(restored.assignments.single.attachments.single.name, 'outline.pdf');
    expect(restored.addFolder('Math', null).id, 'folder-3');
    await restored.flush();
    restored.dispose();
  });

  test('deleting a folder also removes saved descendants and notes', () async {
    final store = await AppDataStore.load(storage);
    final root = store.addFolder('Root', null);
    final child = store.addFolder('Child', root.id);
    store.addNote(child.id, 'Draft', 'Text');
    store.deleteFolderTree(root.id);
    await store.flush();
    store.dispose();

    final restored = await AppDataStore.load(storage);
    expect(restored.folders, isEmpty);
    expect(restored.notes, isEmpty);
    restored.dispose();
  });

  test('invalid saved data is not silently replaced', () async {
    await storage.write('not json');
    await expectLater(AppDataStore.load(storage), throwsFormatException);
    expect(await storage.read(), 'not json');
  });

  test('quick notes and their Unfiled folder survive reload', () async {
    final store = await AppDataStore.load(storage);
    store.addUnfiledNote('  ', '  ');
    expect(store.folders, isEmpty);
    store.addUnfiledNote('Idea', 'Remember this');
    await store.flush();
    store.dispose();

    final restored = await AppDataStore.load(storage);
    expect(restored.folders.single.name, 'Unfiled');
    expect(restored.notes.single.title, 'Idea');
    expect(restored.notes.single.folderId, restored.folders.single.id);
    restored.dispose();
  });

  test(
    'moving an Unfiled note persists its new folder without duplication',
    () async {
      final store = await AppDataStore.load(storage);
      store.addUnfiledNote('Quick idea', 'Remember this');
      final original = store.notes.single;
      final course = store.addFolder('CSC 4103', null);
      final project = store.addFolder('Project', course.id);
      store.updateNote(
        NoteItem(
          id: original.id,
          folderId: project.id,
          title: original.title,
          body: original.body,
        ),
      );
      await store.flush();
      store.dispose();

      final restored = await AppDataStore.load(storage);
      expect(restored.notes, hasLength(1));
      expect(restored.notes.single.id, original.id);
      expect(restored.notes.single.folderId, project.id);
      expect(restored.folderPath(project.id), 'CSC 4103 / Project');
      restored.dispose();
    },
  );
}
