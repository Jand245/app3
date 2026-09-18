import 'package:flutter/material.dart';

import '../models/assignment_item.dart';
import 'assignment_create_screen.dart';

enum AssignmentDetailAction { updated, finished, deleted }

class AssignmentDetailResult {
  const AssignmentDetailResult(this.action, {this.assignment});

  final AssignmentDetailAction action;
  final AssignmentItem? assignment;
}

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
      Navigator.pop(
        context,
        AssignmentDetailResult(
          AssignmentDetailAction.updated,
          assignment: updatedAssignment,
        ),
      );
    }
  }

  Future<void> _removeAssignment(
    BuildContext context,
    AssignmentDetailAction action,
  ) async {
    final isFinished = action == AssignmentDetailAction.finished;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isFinished ? 'Finish assignment?' : 'Delete assignment?'),
        content: Text(
          isFinished
              ? 'This will remove the assignment from your active assignments.'
              : 'This assignment will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: Key(
              isFinished
                  ? 'confirm-finish-assignment'
                  : 'confirm-delete-assignment',
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isFinished ? 'Finish' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pop(
        context,
        AssignmentDetailResult(
          action,
          assignment: isFinished
              ? assignment.copyWith(completedAt: DateTime.now())
              : null,
        ),
      );
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
          if (assignment.completedAt case final completedAt?) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Completed'),
              subtitle: Text(
                '${completedAt.month}/${completedAt.day}/${completedAt.year} at '
                '${TimeOfDay.fromDateTime(completedAt).format(context)}',
              ),
            ),
          ],
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
          const SizedBox(height: 32),
          if (!assignment.isCompleted) ...[
            FilledButton.icon(
              key: const Key('finish-assignment-button'),
              onPressed: () =>
                  _removeAssignment(context, AssignmentDetailAction.finished),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Finish assignment'),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            key: const Key('delete-assignment-button'),
            onPressed: () =>
                _removeAssignment(context, AssignmentDetailAction.deleted),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete assignment'),
          ),
        ],
      ),
    );
  }
}
