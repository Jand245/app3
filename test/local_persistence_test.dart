import 'dart:io';

import 'package:app3/models/app_data_store.dart';
import 'package:app3/models/assignment_item.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/json_file_storage.dart';

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

  test('first launch creates a valid empty data file', () async {
    expect(await storage.read(), isNull);

    final store = await AppDataStore.load(storage);

    expect(store.folders, isEmpty);
    expect(store.notes, isEmpty);
    expect(store.assignments, isEmpty);
    expect(await storage.read(), contains('"version":1'));
    store.dispose();
  });

  test('older version-one data receives defaults for newer fields', () async {
    await storage.write('''
      {
        "version": 1,
        "folders": [],
        "notes": [],
        "assignments": [
          {
            "id": "assignment-1",
            "title": "Older assignment",
            "course": "History",
            "dueDate": "2026-09-20T17:00:00.000"
          }
        ]
      }
    ''');

    final store = await AppDataStore.load(storage);

    expect(store.assignments.single.requirements, isEmpty);
    expect(store.assignments.single.attachments, isEmpty);
    expect(store.assignments.single.colorValue, 0xff3f51b5);
    expect(store.addFolder('First folder', null).id, 'folder-1');
    await store.flush();
    store.dispose();
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
}
