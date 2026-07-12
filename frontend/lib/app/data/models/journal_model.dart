class JournalModel {
  final String? id;
  final String userId;
  final String title;
  final String content;
  final String mood;
  final DateTime createdAt;

  JournalModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json["id"],
      userId: json["user_id"],
      title: json["title"],
      content: json["content"],
      mood: json["mood"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "title": title,
      "content": content,
      "mood": mood,
    };
  }
}