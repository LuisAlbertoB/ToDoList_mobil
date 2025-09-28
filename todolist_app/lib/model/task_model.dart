class Task {
  final int id;
  final int userId;
  final String title;
  final String content;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.isCompleted,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        userId: json['user_id'],
        title: json['title'],
        content: json['content'],
        isCompleted: json['is_completed'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'user_id': userId,
        'title': title,
        'content': content,
        'is_completed': isCompleted,
        // createdAt no se envía, ya que es gestionado por el servidor.
      };
}
