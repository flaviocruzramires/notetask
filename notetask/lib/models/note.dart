class Note {
  String id;
  String content;
  bool isTask;
  bool isCompleted;
  String? categoryId;

  Note({
    required this.id,
    required this.content,
    this.isTask = false,
    this.isCompleted = false,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isTask': isTask ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      content: json['content'],
      isTask: json['isTask'] == 1,
      isCompleted: json['isCompleted'] == 1,
      categoryId: json['categoryId'] as String?,
    );
  }
}
