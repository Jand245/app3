import 'package:flutter/material.dart';

import '../models/note_item.dart';

class NoteEditorResult {
  const NoteEditorResult({
    required this.title,
    required this.body,
    required this.hasContent,
  });

  final String title;
  final String body;
  final bool hasContent;
}

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({this.note, this.saveOnExit = false, super.key});

  final NoteItem? note;
  final bool saveOnExit;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final String _initialTitle;
  late final String _initialBody;
  bool _allowPop = false;

  bool get _hasUnsavedChanges =>
      _titleController.text != _initialTitle ||
      _bodyController.text != _initialBody;

  bool get _hasContent =>
      _titleController.text.trim().isNotEmpty ||
      _bodyController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.note?.title ?? '';
    _initialBody = widget.note?.body ?? '';
    _titleController = TextEditingController(text: _initialTitle)
      ..addListener(_handleTextChanged);
    _bodyController = TextEditingController(text: _initialBody)
      ..addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleTextChanged);
    _bodyController.removeListener(_handleTextChanged);
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handlePop(bool didPop, NoteEditorResult? result) async {
    if (didPop) return;
    if (widget.saveOnExit) {
      if (_hasContent) _save();
      return;
    }
    if (!_hasUnsavedChanges) return;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave without saving?'),
        content: const Text('Your unsaved note changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (shouldLeave == true && mounted) {
      setState(() => _allowPop = true);
      Navigator.pop(context);
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    _allowPop = true;
    Navigator.pop(
      context,
      NoteEditorResult(
        title: title.isEmpty ? 'Untitled note' : title,
        body: _bodyController.text,
        hasContent: _hasContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<NoteEditorResult>(
      canPop:
          _allowPop || (widget.saveOnExit ? !_hasContent : !_hasUnsavedChanges),
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'New note' : 'Edit note'),
          actions: [
            TextButton(onPressed: _save, child: const Text('Save')),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: const [
                    _UpcomingFormatButton(
                      icon: Icons.title,
                      label: 'Headings coming next',
                    ),
                    _UpcomingFormatButton(
                      icon: Icons.format_color_text,
                      label: 'Text color coming next',
                    ),
                    _UpcomingFormatButton(
                      icon: Icons.format_color_fill,
                      label: 'Highlight coming next',
                    ),
                    _UpcomingFormatButton(
                      icon: Icons.draw_outlined,
                      label: 'Pen tool coming next',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                key: const Key('note-title-field'),
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Note title',
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  key: const Key('note-body-field'),
                  controller: _bodyController,
                  autofocus: widget.note == null,
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                  ),
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingFormatButton extends StatelessWidget {
  const _UpcomingFormatButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: null, tooltip: label, icon: Icon(icon));
  }
}
