import 'package:flutter/material.dart';

import '../models/app_data_store.dart';
import '../models/assignment_item.dart';
import '../models/note_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.store,
    required this.onOpenAssignment,
    required this.onOpenNote,
    required this.onCreateNote,
    super.key,
  });

  final AppDataStore store;
  final ValueChanged<AssignmentItem> onOpenAssignment;
  final ValueChanged<NoteItem> onOpenNote;
  final VoidCallback onCreateNote;

  List<AssignmentItem> get _dueSoon {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day + 6);
    final assignments = store.assignments.where(
      (assignment) =>
          !assignment.dueDate.isBefore(now) && assignment.dueDate.isBefore(end),
    );
    return assignments.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Widget build(BuildContext context) {
    final dueSoon = _dueSoon;
    final recentNotes = store.recentNotes;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
        children: [
          Text('Home', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Assignments',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 10),
              const Chip(
                avatar: Icon(Icons.schedule, size: 16),
                label: Text('Due Soon'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (dueSoon.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nothing is due in the next five days.'),
              ),
            )
          else
            ...dueSoon.map(
              (assignment) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 7,
                    backgroundColor: Color(assignment.colorValue),
                  ),
                  title: Text(assignment.title),
                  subtitle: Text(assignment.course),
                  trailing: Text(
                    '${assignment.dueDate.month}/${assignment.dueDate.day}',
                  ),
                  onTap: () => onOpenAssignment(assignment),
                ),
              ),
            ),
          const SizedBox(height: 28),
          Text('Recent notes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (recentNotes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Open a note and it will appear here.'),
              ),
            )
          else
            ...recentNotes.map(
              (note) => Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(note.title),
                  subtitle: Text(
                    store.folderPath(note.folderId),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onOpenNote(note),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('home-new-note-button'),
        heroTag: 'home-new-note',
        onPressed: onCreateNote,
        tooltip: 'New note',
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
