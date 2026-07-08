import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/network_config.dart';
import '../../../core/controllers/global_auth_controller.dart';
import '../../../data/models/article_model.dart';
import '../../../data/providers/assessment_provider.dart';

class BerandaController extends GetxController {
  // =====================================================
  // USER
  // =====================================================

  final auth = Get.find<GlobalAuthController>();

  String get userName =>
      auth.currentUser.value?.name ?? "User";

  RxDouble weeklyProgress = 0.8.obs;

  // Tambahkan ini di dalam class Controller kamu
var selectedChartIndex = (-1).obs; // -1 berarti belum ada titik yang disentuh
var chartFilterIndex = 0.obs;      // 0: Semua, 1: 7 Terakhir

  // =====================================================
  // ARTICLE
  // =====================================================

  var articles = <ArticleModel>[].obs;
  var searchResult = <ArticleModel>[].obs;
  var isLoadingArticles = false.obs;

  final showAllArticles = false.obs;

  // =====================================================
  // WEEKLY TREND
  // =====================================================

  var burnoutTrend = 0.obs;
  var anxietyTrend = 0.obs;
  var depressionTrend = 0.obs;

  var burnoutChange = 0.obs;
  var anxietyChange = 0.obs;
  var depressionChange = 0.obs;

  var isLoadingTrend = false.obs;

    // 1. Taruh variabel ini di bagian atas BerandaController (di bawah trendRangeFilter)
  var trendRangeFilter = 7.obs; 
  var burnoutHistory = <double>[].obs;
  var anxietyHistory = <double>[].obs;
  var depressionHistory = <double>[].obs;

  // =====================================================
  // MENTAL HISTORY CHART
  // =====================================================

  final AssessmentProvider assessmentProvider =
      AssessmentProvider();

  final mentalHistory =
      <Map<String, dynamic>>[].obs;

  final isLoadingMentalChart = false.obs;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void onInit() {
    super.onInit();

    fetchArticles();
    fetchWeeklyTrend();
    fetchMentalHistory();
  }

  // =====================================================
  // ARTICLE
  // =====================================================

  Future<void> fetchArticles() async {
    try {
      isLoadingArticles.value = true;

      final response = await http.get(
        Uri.parse(
          '${NetworkConfig.baseUrl}/articles',
        ),
      );

      if (response.statusCode == 200) {
        final List data =
            jsonDecode(response.body);

        articles.value = data
            .map(
              (e) => ArticleModel.fromJson(e),
            )
            .toList();
      }
    } catch (e) {
      print("ERROR ARTICLE: $e");
    } finally {
      isLoadingArticles.value = false;
    }
  }

  Future<void> searchArticle(
    String keyword,
  ) async {
    try {
      isLoadingArticles.value = true;

      final response = await http.get(
        Uri.parse(
          '${NetworkConfig.baseUrl}/search-realtime/$keyword',
        ),
      );

      if (response.statusCode == 200) {
        final List data =
            jsonDecode(response.body);

        searchResult.value = data
            .map(
              (e) => ArticleModel.fromJson(e),
            )
            .toList();
      }
    } catch (e) {
      print(e);
    } finally {
      isLoadingArticles.value = false;
    }
  }

  void toggleShowAllArticles() {
    showAllArticles.value =
        !showAllArticles.value;
  }

  // =====================================================
  // WEEKLY TREND
  // =====================================================

  // 2. Ganti fungsi fetchWeeklyTrend() kamu dengan ini:
  Future<void> fetchWeeklyTrend() async {
    try {
      isLoadingTrend.value = true;

      final response = await http.get(
        Uri.parse('${NetworkConfig.baseUrl}/weekly-trend'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update skor saat ini
        burnoutTrend.value = data['burnout']['score'] ?? 0;
        burnoutChange.value = data['burnout']['change'] ?? 0;
        anxietyTrend.value = data['anxiety']['score'] ?? 0;
        anxietyChange.value = data['anxiety']['change'] ?? 0;
        depressionTrend.value = data['depression']['score'] ?? 0;
        depressionChange.value = data['depression']['change'] ?? 0;

        // Ambil data history dari API dan konversi ke List<double> secara aman
        burnoutHistory.assignAll((data['burnout']['history'] as List).map((e) => (e as num).toDouble()).toList());
        anxietyHistory.assignAll((data['anxiety']['history'] as List).map((e) => (e as num).toDouble()).toList());
        depressionHistory.assignAll((data['depression']['history'] as List).map((e) => (e as num).toDouble()).toList());
      }
    } catch (e) {
      print("ERROR FETCH WEEKLY TREND: $e");
    } finally {
      isLoadingTrend.value = false;
    }
  }

  // 3. Tambahkan fungsi filter ini di dalam BerandaController kamu
  List<double> getTrendData(String type, int days) {
    List<double> source = [];
    if (type == "Burnout") source = burnoutHistory;
    else if (type == "Anxiety") source = anxietyHistory;
    else if (type == "Depression") source = depressionHistory;

    if (source.isEmpty) return [];
    
    // Mengambil N data terakhir berdasarkan filter hari yang dipilih
    int start = source.length > days ? source.length - days : 0;
    return source.sublist(start);
  }

  // =====================================================
  // MENTAL HISTORY
  // =====================================================

  Future<void> fetchMentalHistory() async {
    try {
      isLoadingMentalChart.value = true;

      final result =
          await assessmentProvider
              .getHistory();

      mentalHistory.value =
          List<Map<String, dynamic>>.from(
        result,
      );

      // urutkan dari yang paling lama ke terbaru
      mentalHistory.sort(
        (a, b) => a["created_at"]
            .toString()
            .compareTo(
              b["created_at"].toString(),
            ),
      );
    } catch (e) {
      print(
        "ERROR MENTAL HISTORY: $e",
      );
    } finally {
      isLoadingMentalChart.value = false;
    }
  }
}