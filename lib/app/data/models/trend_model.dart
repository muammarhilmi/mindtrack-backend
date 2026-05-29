class TrendModel {
  final String date;
  final int burnout;
  final int depression;
  final int anxiety;

  TrendModel({
    required this.date,
    required this.burnout,
    required this.depression,
    required this.anxiety,
  });

  factory TrendModel.fromJson(Map<String, dynamic> json) {
    return TrendModel(
      date: json['date'].toString(),
      burnout: json['burnout'] ?? 0,
      depression: json['depression'] ?? 0,
      anxiety: json['anxiety'] ?? 0,
    );
  }
}