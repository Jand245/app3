import 'package:flutter/material.dart';

import '../models/assignment_item.dart';
import 'assignment_create_screen.dart';

class AssignmentDetailScreen extends StatelessWidget {
  const AssignmentDetailScreen({required this.assignment, super.key});

  final AssignmentItem assignment;

  Future<void> _editAssignment(BuildContext context) async {
    final updatedAssignment = await Navigator.push<AssignmentItem>(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentCreateScreen(assignment: assignment),
      ),
    );
    if (updatedAssignment != null && context.mounted) {
      Navigator.pop(context, updatedAssignment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = assignment.dueDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment details'),
        actions: [
          TextButton(
            onPressed: () => _editAssignment(context),
            child: const Text('Edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            assignment.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            assignment.course,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: const Text('Due date'),
            subtitle: Text(
              '${dueDate.month}/${dueDate.day}/${dueDate.year} at '
              '${TimeOfDay.fromDateTime(dueDate).format(context)}',
            ),
          ),
          const SizedBox(height: 12),
          Text('Requirements', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            assignment.requirements.trim().isEmpty
                ? 'No requirements added.'
                : assignment.requirements,
          ),
          const SizedBox(height: 24),
          Text('Attachments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (assignment.attachments.isEmpty)
            const Text('No files attached.')
          else
            ...assignment.attachments.map(
              (attachment) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.attach_file),
                title: Text(attachment.name),
                subtitle: attachment.path == null
                    ? null
                    : Text(attachment.path!),
              ),
            ),
        ],
      ),
    );
  }
}
