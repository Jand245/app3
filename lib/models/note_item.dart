class NoteItem {
  const NoteItem({
    required this.id,
    required this.folderId,
    required this.title,
    required this.body,
    this.imagePaths = const [],
  });

  final String id;
  final String folderId;
  final String title;
  final String body;
  final List<String> imagePaths;
}
