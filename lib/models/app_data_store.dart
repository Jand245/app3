import 'package:flutter/foundation.dart';

import 'assignment_item.dart';
import 'folder.dart';
import 'note_item.dart';

class AppDataStore extends ChangeNotifier {
  final List<Folder> folders = [];
  final List<NoteItem> notes = [];
  final List<AssignmentItem> assignments = [];
  final List<String> _recentNoteIds = [];
  int _nextFolderId = 1;
  int _nextNoteId = 1;

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
