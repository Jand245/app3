import 'package:flutter/material.dart';

import '../models/app_data_store.dart';
import '../models/assignment_item.dart';
import '../models/folder.dart';
import '../models/note_item.dart';
import 'assignment_detail_screen.dart';
import 'assignments_screen.dart';
import 'folders_screen.dart';
import 'home_screen.dart';
import 'note_editor_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final _store = AppDataStore();
  final _searchController = TextEditingController();
  final _foldersKey = GlobalKey<FoldersScreenState>();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _store.addListener(_handleStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    _store.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleStoreChanged() {
    if (mounted) setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _openAssignment(AssignmentItem assignment) async {
    _clearSearch();
    final updated = await Navigator.push<AssignmentItem>(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentDetailScreen(assignment: assignment),
      ),
    );
    if (updated != null) _store.updateAssignment(updated);
  }

  Future<void> _openNote(NoteItem note) async {
    _clearSearch();
    _store.markNoteAccessed(note.id);
    final result = await Navigator.push<NoteEditorResult>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
    if (result == null) return;
    _store.updateNote(
      NoteItem(
        id: note.id,
        folderId: note.folderId,
        title: result.title,
        body: result.body,
      ),
    );
  }

  void _openFolder(Folder folder) {
    _clearSearch();
    setState(() => _selectedIndex = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _foldersKey.currentState?.openFolder(folder);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(
        store: _store,
        onOpenAssignment: _openAssignment,
        onOpenNote: _openNote,
      ),
      FoldersScreen(key: _foldersKey, store: _store),
      AssignmentsScreen(store: _store),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search assignments, folders, and notes',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close),
                    ),
                ],
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: _query.trim().isEmpty
                  ? IndexedStack(index: _selectedIndex, children: screens)
                  : SearchScreen(
                      store: _store,
                      query: _query,
                      onOpenAssignment: _openAssignment,
                      onOpenFolder: _openFolder,
                      onOpenNote: _openNote,
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            label: 'Folders',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            label: 'Assignments',
          ),
        ],
      ),
    );
  }
}
