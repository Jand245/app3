import 'package:flutter/material.dart';

import '../models/app_data_store.dart';
import '../models/assignment_item.dart';
import '../models/folder.dart';
import '../models/note_item.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({
    required this.store,
    required this.query,
    required this.onOpenAssignment,
    required this.onOpenFolder,
    required this.onOpenNote,
    super.key,
  });

  final AppDataStore store;
  final String query;
  final ValueChanged<AssignmentItem> onOpenAssignment;
  final ValueChanged<Folder> onOpenFolder;
  final ValueChanged<NoteItem> onOpenNote;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const Center(
        child: Text('Search assignments, folders, and notes.'),
      );
    }

    final assignments = store.assignments.where(
      (assignment) =>
          assignment.title.toLowerCase().contains(normalizedQuery) ||
          assignment.course.toLowerCase().contains(normalizedQuery),
    );
    final folders = store.folders.where(
      (folder) => folder.name.toLowerCase().contains(normalizedQuery),
    );
    final notes = store.notes.where(
      (note) =>
          note.title.toLowerCase().contains(normalizedQuery) ||
          note.body.toLowerCase().contains(normalizedQuery),
    );

    if (assignments.isEmpty && folders.isEmpty && notes.isEmpty) {
      return const Center(child: Text('No matching results.'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        ...assignments.map(
          (assignment) => ListTile(
            leading: Icon(
              Icons.assignment_outlined,
              color: Color(assignment.colorValue),
            ),
            title: Text(assignment.title),
            subtitle: Text(assignment.course),
            onTap: () => onOpenAssignment(assignment),
          ),
        ),
        ...folders.map(
          (folder) => ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(folder.name),
            subtitle: Text(store.folderPath(folder.id)),
            onTap: () => onOpenFolder(folder),
          ),
        ),
        ...notes.map(
          (note) => ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(note.title),
            subtitle: Text(store.folderPath(note.folderId)),
            onTap: () => onOpenNote(note),
          ),
        ),
      ],
    );
  }
}
