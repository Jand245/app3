import 'package:flutter/material.dart';

import '../models/app_data_store.dart';
import '../models/folder.dart';
import '../models/note_item.dart';
import 'note_editor_screen.dart';

enum _FolderAction { rename, delete }

enum _NoteAction { edit, move, delete }

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({required this.store, super.key});

  final AppDataStore store;

  @override
  State<FoldersScreen> createState() => FoldersScreenState();
}

class FoldersScreenState extends State<FoldersScreen> {
  final List<String> _folderPath = [];

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_handleStoreChanged);
  }

  @override
  void dispose() {
    widget.store.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void _handleStoreChanged() {
    if (mounted) setState(() {});
  }

  String? get _currentFolderId => _folderPath.isEmpty ? null : _folderPath.last;

  Folder? get _currentFolder {
    final currentId = _currentFolderId;
    if (currentId == null) return null;
    for (final folder in widget.store.folders) {
      if (folder.id == currentId) return folder;
    }
    return null;
  }

  List<Folder> get _visibleFolders => widget.store.folders
      .where((folder) => folder.parentId == _currentFolderId)
      .toList();

  List<NoteItem> get _visibleNotes {
    final folderId = _currentFolderId;
    if (folderId == null) return [];
    return widget.store.notes
        .where((note) => note.folderId == folderId)
        .toList();
  }

  Future<String?> _askForFolderName({String initialName = ''}) {
    return showDialog<String>(
      context: context,
      builder: (context) => _FolderNameDialog(initialName: initialName),
    );
  }

  Future<void> _createFolder() async {
    final name = await _askForFolderName();
    if (name == null || !mounted) return;
    widget.store.addFolder(name, _currentFolderId);
  }

  Future<void> _renameFolder(Folder folder) async {
    final name = await _askForFolderName(initialName: folder.name);
    if (name == null || !mounted) return;
    widget.store.updateFolder(
      Folder(id: folder.id, name: name, parentId: folder.parentId),
    );
  }

  Future<void> _deleteFolder(Folder folder) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          'Delete “${folder.name}”? Its subfolders and notes will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    widget.store.deleteFolderTree(folder.id);
  }

  Future<void> _createNote() async {
    final folderId = _currentFolderId;
    if (folderId == null) return;
    final result = await Navigator.push<NoteEditorResult>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );
    if (result == null || !mounted) return;

    widget.store.addNote(folderId, result.title, result.body);
  }

  Future<void> _editNote(NoteItem note) async {
    widget.store.markNoteAccessed(note.id);
    final result = await Navigator.push<NoteEditorResult>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    if (result == null || !mounted) return;
    widget.store.updateNote(
      NoteItem(
        id: note.id,
        folderId: note.folderId,
        title: result.title,
        body: result.body,
      ),
    );
  }

  Future<void> _deleteNote(NoteItem note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('Delete “${note.title}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      widget.store.deleteNote(note.id);
    }
  }

  Future<void> _moveNote(NoteItem note) async {
    final destinations = widget.store.folders
        .where((folder) => folder.id != note.folderId)
        .toList();
    final destination = await showDialog<Folder>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move to folder'),
        children: [
          if (destinations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Create another folder before moving this note.'),
            )
          else
            for (final folder in destinations)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, folder),
                child: Text(widget.store.folderPath(folder.id)),
              ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (destination == null || !mounted) return;

    widget.store.updateNote(
      NoteItem(
        id: note.id,
        folderId: destination.id,
        title: note.title,
        body: note.body,
      ),
    );
  }

  Future<void> _handleFolderAction(_FolderAction action, Folder folder) async {
    switch (action) {
      case _FolderAction.rename:
        await _renameFolder(folder);
      case _FolderAction.delete:
        await _deleteFolder(folder);
    }
  }

  Future<void> _handleNoteAction(_NoteAction action, NoteItem note) async {
    switch (action) {
      case _NoteAction.edit:
        await _editNote(note);
      case _NoteAction.move:
        await _moveNote(note);
      case _NoteAction.delete:
        await _deleteNote(note);
    }
  }

  void _openFolder(Folder folder) {
    setState(() => _folderPath.add(folder.id));
  }

  void openFolder(Folder folder) {
    final path = <String>[];
    Folder? current = folder;
    while (current != null) {
      path.insert(0, current.id);
      final parentId = current.parentId;
      current = parentId == null
          ? null
          : widget.store.folders
                .where((item) => item.id == parentId)
                .firstOrNull;
    }
    setState(() {
      _folderPath
        ..clear()
        ..addAll(path);
    });
  }

  void _goBack() {
    if (_folderPath.isEmpty) return;
    setState(() => _folderPath.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final folders = _visibleFolders;
    final notes = _visibleNotes;
    final currentFolder = _currentFolder;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, currentFolder),
          Expanded(
            child: folders.isEmpty && notes.isEmpty
                ? _buildEmptyState(currentFolder)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [
                      if (folders.isNotEmpty) ...[
                        if (currentFolder != null)
                          const _SectionHeading('Subfolders'),
                        ...folders.map(_buildFolderTile),
                      ],
                      if (notes.isNotEmpty) ...[
                        const _SectionHeading('Notes'),
                        ...notes.map(_buildNoteTile),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: currentFolder == null
          ? FloatingActionButton.extended(
              heroTag: 'new-root-folder',
              onPressed: _createFolder,
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('New folder'),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'new-subfolder',
                  onPressed: _createFolder,
                  tooltip: 'New subfolder',
                  child: const Icon(Icons.create_new_folder_outlined),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'new-note',
                  onPressed: _createNote,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('New note'),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, Folder? currentFolder) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 24, 12),
      child: Row(
        children: [
          if (currentFolder != null)
            IconButton(
              onPressed: _goBack,
              tooltip: 'Back to parent folder',
              icon: const Icon(Icons.arrow_back),
            )
          else
            const SizedBox(width: 12),
          Expanded(
            child: Text(
              currentFolder?.name ?? 'Folders',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Folder? currentFolder) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          currentFolder == null
              ? 'No folders yet. Create one to organize your notes.'
              : 'This folder is empty. Add a note or subfolder.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFolderTile(Folder folder) {
    return ListTile(
      key: ValueKey(folder.id),
      onTap: () => _openFolder(folder),
      leading: Icon(
        folder.parentId == null && folder.name == 'Unfiled'
            ? Icons.inbox_outlined
            : Icons.folder_outlined,
      ),
      title: Text(folder.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chevron_right),
          PopupMenuButton<_FolderAction>(
            tooltip: 'Folder options',
            onSelected: (action) => _handleFolderAction(action, folder),
            itemBuilder: (_) => const [
              PopupMenuItem(value: _FolderAction.rename, child: Text('Rename')),
              PopupMenuItem(value: _FolderAction.delete, child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteTile(NoteItem note) {
    final preview = note.body.trim().isEmpty ? 'Empty note' : note.body.trim();
    return ListTile(
      key: ValueKey(note.id),
      onTap: () => _editNote(note),
      leading: const Icon(Icons.description_outlined),
      title: Text(note.title),
      subtitle: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: PopupMenuButton<_NoteAction>(
        tooltip: 'Note options',
        onSelected: (action) => _handleNoteAction(action, note),
        itemBuilder: (_) => const [
          PopupMenuItem(value: _NoteAction.edit, child: Text('Edit')),
          PopupMenuItem(value: _NoteAction.move, child: Text('Move to folder')),
          PopupMenuItem(value: _NoteAction.delete, child: Text('Delete')),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _FolderNameDialog extends StatefulWidget {
  const _FolderNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName.isEmpty ? 'New folder' : 'Rename folder'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Folder name',
          hintText: 'Example: CSC 4103',
        ),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
