class Note {
  String id;
  String content;
  bool isTask;
  bool isCompleted;
  String? categoryId;
  final DateTime? scheduledDate;
  final bool addToCalendar;
  final bool setAlarm;
  final bool isArchived;
  Note({
    required this.id,
    required this.content,
    this.isTask = false,
    this.isCompleted = false,
    this.categoryId,
    this.scheduledDate,
    this.addToCalendar = false,
    this.setAlarm = false,
    this.isArchived = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isTask': isTask ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'addToCalendar': addToCalendar ? 1 : 0,
      'setAlarm': setAlarm ? 1 : 0,
      'isArchived': isArchived ? 1 : 0,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      content: json['content'],
      isTask: json['isTask'] == 1,
      isCompleted: json['isCompleted'] == 1,
      categoryId: json['categoryId'] as String?,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      addToCalendar: json['addToCalendar'] == 1,
      setAlarm: json['setAlarm'] == 1,
      isArchived: json['isArchived'] == 1,
    );
  }

  copyWith({bool? isCompleted}) {}
}
