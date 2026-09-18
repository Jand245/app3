class AssignmentAttachment {
  const AssignmentAttachment({required this.name, this.path});

  final String name;
  final String? path;
}

class AssignmentItem {
  const AssignmentItem({
    required this.id,
    required this.title,
    required this.course,
    required this.requirements,
    required this.dueDate,
    required this.colorValue,
    this.attachments = const [],
    this.completedAt,
  });

  final String id;
  final String title;
  final String course;
  final String requirements;
  final DateTime dueDate;
  final int colorValue;
  final List<AssignmentAttachment> attachments;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  AssignmentItem copyWith({DateTime? completedAt}) {
    return AssignmentItem(
      id: id,
      title: title,
      course: course,
      requirements: requirements,
      dueDate: dueDate,
      colorValue: colorValue,
      attachments: attachments,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
