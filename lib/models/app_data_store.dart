import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'assignment_item.dart';
import 'folder.dart';
import 'local_data_storage.dart';
import 'note_item.dart';

class AppDataStore extends ChangeNotifier {
  AppDataStore({LocalDataStorage? storage}) : this._withStorage(storage);

  AppDataStore._withStorage(this._storage);

  final LocalDataStorage? _storage;
  final List<Folder> folders = [];
  final List<NoteItem> notes = [];
  final List<AssignmentItem> assignments = [];
  final List<String> _recentNoteIds = [];
  int _nextFolderId = 1;
  int _nextNoteId = 1;
  Future<void> _lastWrite = Future.value();
  Object? saveError;

  static Future<AppDataStore> load(LocalDataStorage storage) async {
    final store = AppDataStore(storage: storage);
    final contents = await storage.read();
    if (contents == null || contents.trim().isEmpty) {
      await storage.write(jsonEncode(store._toJson()));
      return store;
    }

    final data = jsonDecode(contents) as Map<String, dynamic>;
    if (data['version'] != 1) {
      throw const FormatException('Unsupported saved data version');
    }

    store.folders.addAll(
      (data['folders'] as List? ?? const []).map((value) {
        final folder = value as Map<String, dynamic>;
        return Folder(
          id: folder['id'] as String,
          name: folder['name'] as String,
          parentId: folder['parentId'] as String?,
        );
      }),
    );
    store.notes.addAll(
      (data['notes'] as List? ?? const []).map((value) {
        final note = value as Map<String, dynamic>;
        return NoteItem(
          id: note['id'] as String,
          folderId: note['folderId'] as String,
          title: note['title'] as String,
          body: note['body'] as String,
        );
      }),
    );
    store.assignments.addAll(
      (data['assignments'] as List? ?? const []).map((value) {
        final assignment = value as Map<String, dynamic>;
        return AssignmentItem(
          id: assignment['id'] as String,
          title: assignment['title'] as String,
          course: assignment['course'] as String,
          requirements: assignment['requirements'] as String? ?? '',
          dueDate: DateTime.parse(assignment['dueDate'] as String),
          colorValue: assignment['colorValue'] as int? ?? 0xff3f51b5,
          attachments: (assignment['attachments'] as List? ?? const []).map((
            value,
          ) {
            final attachment = value as Map<String, dynamic>;
            return AssignmentAttachment(
              name: attachment['name'] as String,
              path: attachment['path'] as String?,
            );
          }).toList(),
        );
      }),
    );
    store._recentNoteIds.addAll(
      (data['recentNoteIds'] as List? ?? const []).cast<String>().where(
        (id) => store.notes.any((note) => note.id == id),
      ),
    );
    store._nextFolderId =
        data['nextFolderId'] as int? ??
        _nextNumericId(store.folders.map((folder) => folder.id), 'folder-');
    store._nextNoteId =
        data['nextNoteId'] as int? ??
        _nextNumericId(store.notes.map((note) => note.id), 'note-');
    return store;
  }

  static int _nextNumericId(Iterable<String> ids, String prefix) {
    var largestId = 0;
    for (final id in ids) {
      if (!id.startsWith(prefix)) continue;
      final number = int.tryParse(id.substring(prefix.length));
      if (number != null && number > largestId) largestId = number;
    }
    return largestId + 1;
  }

  Future<void> flush() => _lastWrite;

  void retrySave() => notifyListeners();

  @override
  void notifyListeners() {
    super.notifyListeners();
    final storage = _storage;
    if (storage == null) return;
    final snapshot = jsonEncode(_toJson());
    _lastWrite = _lastWrite
        .then((_) => storage.write(snapshot))
        .then((_) {
          saveError = null;
        })
        .catchError((Object error) {
          saveError = error;
          super.notifyListeners();
        });
  }

  Map<String, Object?> _toJson() => {
    'version': 1,
    'nextFolderId': _nextFolderId,
    'nextNoteId': _nextNoteId,
    'recentNoteIds': _recentNoteIds,
    'folders': [
      for (final folder in folders)
        {'id': folder.id, 'name': folder.name, 'parentId': folder.parentId},
    ],
    'notes': [
      for (final note in notes)
        {
          'id': note.id,
          'folderId': note.folderId,
          'title': note.title,
          'body': note.body,
        },
    ],
    'assignments': [
      for (final assignment in assignments)
        {
          'id': assignment.id,
          'title': assignment.title,
          'course': assignment.course,
          'requirements': assignment.requirements,
          'dueDate': assignment.dueDate.toIso8601String(),
          'colorValue': assignment.colorValue,
          'attachments': [
            for (final attachment in assignment.attachments)
              {'name': attachment.name, 'path': attachment.path},
          ],
        },
    ],
  };

  List<NoteItem> get recentNotes => _recentNoteIds
      .map((id) => notes.where((note) => note.id == id).firstOrNull)
      .whereType<NoteItem>()
      .take(3)
      .toList();

  Folder addFolder(String name, String? parentId) {
    final folder = Folder(
      id: 'folder-${_nextFolderId++}',
      name: name,
      parentId: parentId,
    );
    folders.add(folder);
    notifyListeners();
    return folder;
  }

  void updateFolder(Folder folder) {
    final index = folders.indexWhere((item) => item.id == folder.id);
    if (index == -1) return;
    folders[index] = folder;
    notifyListeners();
  }

  void deleteFolderTree(String folderId) {
    final ids = <String>{folderId};
    var addedChild = true;
    while (addedChild) {
      addedChild = false;
      for (final folder in folders) {
        if (folder.parentId != null &&
            ids.contains(folder.parentId) &&
            ids.add(folder.id)) {
          addedChild = true;
        }
      }
    }
    folders.removeWhere((folder) => ids.contains(folder.id));
    notes.removeWhere((note) => ids.contains(note.folderId));
    _recentNoteIds.removeWhere((id) => !notes.any((note) => note.id == id));
    notifyListeners();
  }

  void addNote(String folderId, String title, String body) {
    final note = NoteItem(
      id: 'note-${_nextNoteId++}',
      folderId: folderId,
      title: title,
      body: body,
    );
    notes.add(note);
    markNoteAccessed(note.id);
  }

  void updateNote(NoteItem note) {
    final index = notes.indexWhere((item) => item.id == note.id);
    if (index == -1) return;
    notes[index] = note;
    markNoteAccessed(note.id);
  }

  void deleteNote(String noteId) {
    notes.removeWhere((note) => note.id == noteId);
    _recentNoteIds.remove(noteId);
    notifyListeners();
  }

  void markNoteAccessed(String noteId) {
    _recentNoteIds.remove(noteId);
    _recentNoteIds.insert(0, noteId);
    notifyListeners();
  }

  void addAssignment(AssignmentItem assignment) {
    assignments.add(assignment);
    notifyListeners();
  }

  void updateAssignment(AssignmentItem assignment) {
    final index = assignments.indexWhere((item) => item.id == assignment.id);
    if (index == -1) return;
    assignments[index] = assignment;
    notifyListeners();
  }

  String folderPath(String folderId) {
    final names = <String>[];
    String? currentId = folderId;
    while (currentId != null) {
      final folder = folders.where((item) => item.id == currentId).firstOrNull;
      if (folder == null) break;
      names.insert(0, folder.name);
      currentId = folder.parentId;
    }
    return names.join(' / ');
  }
}
