import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HasilController extends GetxController {
  // Skor mentah per instrumen
  final phqScore = 0.obs;
  final gadScore = 0.obs;
  final stressScore = 0.obs;

  // Level resmi per instrumen
  final phqLevel = ''.obs;
  final gadLevel = ''.obs;
  final stressLevel = ''.obs;

  // Skor gabungan
  final mentalPercentage = 0.obs;
  final lifestyleScore = 0.obs;
  final finalScore = 0.obs;
  final level = ''.obs;

  // Aktivitas harian
  final sleepHours = 0.0.obs;
  final socialInteraction = 0.obs;
  final productivity = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final data = (Get.arguments as Map<String, dynamic>?) ?? {};

    phqScore.value       = data["phq_score"] ?? 0;
    gadScore.value       = data["gad_score"] ?? 0;
    stressScore.value    = data["stress_score"] ?? 0;

    phqLevel.value       = data["phq_level"] ?? "-";
    gadLevel.value       = data["gad_level"] ?? "-";
    stressLevel.value    = data["stress_level"] ?? "-";

    mentalPercentage.value = data["mental_percentage"] ?? 0;
    lifestyleScore.value   = data["lifestyle_score"] ?? 0;
    finalScore.value       = data["final_score"] ?? 0;
    level.value            = data["level"] ?? "-";

    sleepHours.value       = (data["sleep_hours"] ?? 0).toDouble();
    socialInteraction.value = data["social_interaction"] ?? 0;
    productivity.value     = data["productivity"] ?? 0;
  }

  // ===== Warna dinamis berdasarkan level skor gabungan =====
  Color get levelColor {
    switch (level.value) {
      case "Sangat Baik": return const Color(0xFF1B5E20);
      case "Baik":        return const Color(0xFF2E7D32);
      case "Sedang":      return const Color(0xFFF57F17);
      case "Kurang":      return const Color(0xFFE65100);
      case "Buruk":       return const Color(0xFFB71C1C);
      default:            return const Color(0xFF1565C0);
    }
  }

  Color get levelAccentColor {
    switch (level.value) {
      case "Sangat Baik": return const Color(0xFF4CAF50);
      case "Baik":        return const Color(0xFF66BB6A);
      case "Sedang":      return const Color(0xFFFFCA28);
      case "Kurang":      return const Color(0xFFFFA726);
      case "Buruk":       return const Color(0xFFEF5350);
      default:            return const Color(0xFF42A5F5);
    }
  }

  Color get levelColorLight {
    switch (level.value) {
      case "Sangat Baik": return const Color(0xFFE8F5E9);
      case "Baik":        return const Color(0xFFF1F8E9);
      case "Sedang":      return const Color(0xFFFFF8E1);
      case "Kurang":      return const Color(0xFFFFF3E0);
      case "Buruk":       return const Color(0xFFFFEBEE);
      default:            return const Color(0xFFE3F2FD);
    }
  }

  String get levelEmoji {
    switch (level.value) {
      case "Sangat Baik": return "🌟";
      case "Baik":        return "😊";
      case "Sedang":      return "😐";
      case "Kurang":      return "😟";
      case "Buruk":       return "😢";
      default:            return "📊";
    }
  }

  // Warna berdasarkan tingkat keparahan level klinis
  Color clinicalLevelColor(String clinicalLevel) {
    switch (clinicalLevel) {
      case "Minimal":
      case "Normal":       return const Color(0xFF4CAF50);
      case "Ringan":       return const Color(0xFF8BC34A);
      case "Sedang":       return const Color(0xFFFFC107);
      case "Sedang Berat": return const Color(0xFFFF9800);
      case "Berat":        return const Color(0xFFF44336);
      case "Sangat Berat": return const Color(0xFFB71C1C);
      default:             return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get recommendations {
    List<Map<String, dynamic>> items = [];

    if (stressScore.value >= 10) {
      items.add({
        "title":     "Latihan Pernapasan",
        "subtitle":  "Membantu menenangkan pikiran dan mengurangi stres.",
        "icon":      Icons.air,
        "route":     "/breathing",
        "color":     Colors.green.shade50,
        "iconColor": const Color(0xFF43A047),
      });
    }

    if (phqScore.value >= 8) {
      items.add({
        "title":     "Jurnal Harian",
        "subtitle":  "Tuliskan pikiran dan perasaan Anda hari ini.",
        "icon":      Icons.menu_book,
        "route":     "/journal",
        "color":     Colors.orange.shade50,
        "iconColor": const Color(0xFFE65100),
      });
    }

    if (sleepHours.value < 6) {
      items.add({
        "title":     "Musik Relaksasi",
        "subtitle":  "Bantu tubuh dan pikiran lebih rileks sebelum beristirahat.",
        "icon":      Icons.music_note,
        "route":     "/relaxation_music",
        "color":     Colors.blue.shade50,
        "iconColor": const Color(0xFF1565C0),
      });
    }

    if (socialInteraction.value <= 1) {
      items.add({
        "title":     "Daily Affirmation",
        "subtitle":  "Bangun kembali rasa percaya diri dan energi positif.",
        "icon":      Icons.favorite,
        "route":     "/affirmation",
        "color":     Colors.pink.shade50,
        "iconColor": const Color(0xFFAD1457),
      });
    }

    if (productivity.value <= 1) {
      items.add({
        "title":     "Tingkatkan Produktivitas",
        "subtitle":  "Buat target kecil yang realistis untuk hari ini.",
        "icon":      Icons.bolt,
        "route":     "/affirmation",
        "color":     Colors.purple.shade50,
        "iconColor": const Color(0xFF6A1B9A),
      });
    }

    if (items.isEmpty) {
      items.addAll([
        {
          "title":     "Jurnal Syukur",
          "subtitle":  "Catat hal-hal positif yang Anda alami hari ini.",
          "icon":      Icons.auto_stories,
          "route":     "/journal",
          "color":     Colors.lightBlue.shade50,
          "iconColor": const Color(0xFF0277BD),
        },
        {
          "title":     "Daily Affirmation",
          "subtitle":  "Pertahankan energi positif dan mindset yang sehat.",
          "icon":      Icons.favorite,
          "route":     "/affirmation",
          "color":     Colors.pink.shade50,
          "iconColor": const Color(0xFFAD1457),
        },
      ]);
    }

    return items.take(3).toList();
  }
}