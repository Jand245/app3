import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/assignment_item.dart';

class AssignmentCreateScreen extends StatefulWidget {
  const AssignmentCreateScreen({this.assignment, super.key});

  final AssignmentItem? assignment;

  @override
  State<AssignmentCreateScreen> createState() => _AssignmentCreateScreenState();
}

class _AssignmentCreateScreenState extends State<AssignmentCreateScreen> {
  static const _colorChoices = [
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.amber,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.purple,
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _requirementsController = TextEditingController();
  final List<AssignmentAttachment> _attachments = [];
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    final assignment = widget.assignment;
    final initialDueDate = assignment?.dueDate ?? DateTime.now();
    _dueDate = DateTime(
      initialDueDate.year,
      initialDueDate.month,
      initialDueDate.day,
    );
    _dueTime = assignment == null
        ? const TimeOfDay(hour: 23, minute: 59)
        : TimeOfDay.fromDateTime(assignment.dueDate);

    _selectedColor = assignment == null
        ? Colors.indigo
        : Color(assignment.colorValue);

    if (assignment != null) {
      _titleController.text = assignment.title;
      _courseController.text = assignment.course;
      _requirementsController.text = assignment.requirements;
      _attachments.addAll(assignment.attachments);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _chooseDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null && mounted) setState(() => _dueDate = date);
  }

  Future<void> _chooseDueTime() async {
    final time = await showTimePicker(context: context, initialTime: _dueTime);
    if (time != null && mounted) setState(() => _dueTime = time);
  }

  Future<void> _addAttachments() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'png',
        'jpg',
        'jpeg',
        'gif',
        'heic',
        'doc',
        'docx',
        'txt',
        'rtf',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'zip',
      ],
    );

    if (files.isEmpty || !mounted) return;
    setState(() {
      _attachments.addAll(
        files.map(
          (file) => AssignmentAttachment(name: file.name, path: file.path),
        ),
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final dueDate = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );
    Navigator.pop(
      context,
      AssignmentItem(
        id:
            widget.assignment?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        course: _courseController.text.trim(),
        requirements: _requirementsController.text.trim(),
        dueDate: dueDate,
        colorValue: _selectedColor.toARGB32(),
        attachments: List.unmodifiable(_attachments),
        completedAt: widget.assignment?.completedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.assignment == null ? 'Create assignment' : 'Edit assignment',
        ),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              key: const Key('assignment-title-field'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Assignment title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter an assignment title'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('assignment-course-field'),
              controller: _courseController,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a course'
                  : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Due date'),
              subtitle: Text(
                '${_dueDate.month}/${_dueDate.day}/${_dueDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _chooseDueDate,
            ),
            ListTile(
              key: const Key('assignment-due-time'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Due time'),
              subtitle: Text(_dueTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _chooseDueTime,
            ),

            Text(
              'Assignment color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorChoices.map((color) {
                final isSelected = color == _selectedColor;

                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 8),
            TextFormField(
              key: const Key('assignment-requirements-field'),
              controller: _requirementsController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Requirements',
                hintText: 'Describe what needs to be completed',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _addAttachments,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add files, photos, or PDFs'),
            ),
            ..._attachments.asMap().entries.map(
              (entry) => ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(entry.value.name),
                trailing: IconButton(
                  tooltip: 'Remove attachment',
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      setState(() => _attachments.removeAt(entry.key)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
