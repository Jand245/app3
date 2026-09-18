import 'package:flutter/material.dart';

import '../models/note_item.dart';
import 'camera_screen.dart';

class NoteEditorResult {
  cconst NoteEditorResult({
    required this.title,
    required this.body,
    this.imagePaths = const [],
  });
  final String title;
  final String body;
  final List<String> imagePaths;
}

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({this.note, super.key});

  final NoteItem? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final List<String> _imagePaths; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
    _imagePaths = List<String>.from(widget.note?.imagePaths ?? const []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    Navigator.pop(
      context,
      NoteEditorResult(
        title: title.isEmpty ? 'Untitled note' : title,
        body: _bodyController.text,
        imagePaths: _imagePaths,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(widget.note == null ? 'New note' : 'Edit note'),
  actions: [
    IconButton(   
      icon: const Icon(Icons.camera_alt),
      onPressed: () async {
        final path = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
        if (path != null) {
          setState(() {
            _imagePaths.add(path);
          });
        }
      },
    ),
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
