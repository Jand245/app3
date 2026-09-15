class NoteItem {
  const NoteItem({
    required this.id,
    required this.folderId,
    required this.title,
    required this.body,
  });

  final String id;
  final String folderId;
  final String title;
  final String body;
}
