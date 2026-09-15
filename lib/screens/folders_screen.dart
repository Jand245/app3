import 'package:flutter/material.dart';

import '../models/folder.dart';

enum _FolderAction { rename, delete }

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final List<Folder> _folders = [];
  final List<String> _folderPath = [];
  int _nextFolderId = 1;

  String? get _currentFolderId => _folderPath.isEmpty ? null : _folderPath.last;

  Folder? get _currentFolder {
    final currentId = _currentFolderId;
    if (currentId == null) return null;

    for (final folder in _folders) {
      if (folder.id == currentId) return folder;
    }
    return null;
  }

  List<Folder> get _visibleFolders =>
      _folders.where((folder) => folder.parentId == _currentFolderId).toList();

  Future<String?> _askForFolderName({String initialName = ''}) {
    return showDialog<String>(
      context: context,
      builder: (context) => _FolderNameDialog(initialName: initialName),
    );
  }

  Future<void> _createFolder() async {
    final name = await _askForFolderName();
    if (name == null || !mounted) return;

    setState(() {
      _folders.add(
        Folder(
          id: 'folder-${_nextFolderId++}',
          name: name,
          parentId: _currentFolderId,
        ),
      );
    });
  }

  Future<void> _renameFolder(Folder folder) async {
    final name = await _askForFolderName(initialName: folder.name);
    if (name == null || !mounted) return;

    final index = _folders.indexWhere((item) => item.id == folder.id);
    if (index == -1) return;

    setState(() {
      _folders[index] = Folder(
        id: folder.id,
        name: name,
        parentId: folder.parentId,
      );
    });
  }

  Future<void> _deleteFolder(Folder folder) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          'Delete “${folder.name}”? Any subfolders inside it will also be deleted.',
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
    setState(() {
      final idsToDelete = <String>{folder.id};
      var foundChild = true;

      while (foundChild) {
        foundChild = false;
        for (final item in _folders) {
          if (item.parentId != null &&
              idsToDelete.contains(item.parentId) &&
              idsToDelete.add(item.id)) {
            foundChild = true;
          }
        }
      }

      _folders.removeWhere((item) => idsToDelete.contains(item.id));
    });
  }

  Future<void> _handleAction(_FolderAction action, Folder folder) async {
    switch (action) {
      case _FolderAction.rename:
        await _renameFolder(folder);
      case _FolderAction.delete:
        await _deleteFolder(folder);
    }
  }

  void _openFolder(Folder folder) {
    setState(() => _folderPath.add(folder.id));
  }

  void _goBack() {
    if (_folderPath.isEmpty) return;
    setState(() => _folderPath.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final visibleFolders = _visibleFolders;
    final currentFolder = _currentFolder;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
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
          ),
          Expanded(
            child: visibleFolders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        currentFolder == null
                            ? 'No folders yet. Create one to organize your notes.'
                            : 'No subfolders yet. Create one inside this folder.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: visibleFolders.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final folder = visibleFolders[index];
                      return ListTile(
                        key: ValueKey(folder.id),
                        onTap: () => _openFolder(folder),
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(folder.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chevron_right),
                            PopupMenuButton<_FolderAction>(
                              tooltip: 'Folder options',
                              onSelected: (action) =>
                                  _handleAction(action, folder),
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: _FolderAction.rename,
                                  child: Text('Rename'),
                                ),
                                PopupMenuItem(
                                  value: _FolderAction.delete,
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFolder,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New folder'),
      ),
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
