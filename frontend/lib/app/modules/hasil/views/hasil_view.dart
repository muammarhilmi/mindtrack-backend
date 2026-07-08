import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hasil_controller.dart';

/// Prinsip desain versi ini:
/// 1. Layar pertama (collapsed) memenuhi seluruh tinggi layar: hanya skor
///    besar, label level, dan deskripsi singkat — tidak ada scroll,
///    fokus penuh pengguna ada di sini.
/// 2. Di bagian bawah ada panah ke bawah. Setelah ditekan, tampilan
///    berpindah ke halaman detail lengkap (scrollable) seperti versi
///    sebelumnya — rincian skor, skor klinis, insight, rekomendasi.
/// 3. Tidak ada emoji/emoticon di mana pun.
class HasilView extends GetView<HasilController> {
  const HasilView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: _HasilBody(controller: controller),
    );
  }
}

class _HasilBody extends StatefulWidget {
  final HasilController controller;
  const _HasilBody({required this.controller});

  @override
  State<_HasilBody> createState() => _HasilBodyState();
}

class _HasilBodyState extends State<_HasilBody> {
  bool _expanded = false;

  HasilController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lc = controller.levelColor;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _expanded
            ? _detailView(lc, key: const ValueKey("detail"))
            : _summaryFullScreen(context, lc, key: const ValueKey("summary")),
      );
    });
  }

  // ===========================
  // LAYAR AWAL — memenuhi 1 layar penuh
  // ===========================
  Widget _summaryFullScreen(BuildContext context, Color lc, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lc, lc.withOpacity(0.85)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Lingkaran skor — dibesarkan
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: controller.finalScore.value / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withOpacity(0.20),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${controller.finalScore.value}",
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "dari 100",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),
            // Label level
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Text(
                controller.level.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    _getTitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getDescription(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 3),
            // Panah ke bawah untuk membuka detail
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => setState(() => _expanded = true),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Lihat Detail Selengkapnya",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _BouncingArrow(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  // ===========================
  // TAMPILAN DETAIL — normal, bisa discroll
  // ===========================
  Widget _detailView(Color lc, {Key? key}) {
    return CustomScrollView(
      key: key,
      slivers: [
        SliverAppBar(
          expandedHeight: 230,
          pinned: true,
          elevation: 0,
          backgroundColor: lc,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => setState(() => _expanded = false),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: lc,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 170,
                      height: 170,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: CircularProgressIndicator(
                              value: controller.finalScore.value / 100,
                              strokeWidth: 11,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.white.withOpacity(0.20),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${controller.finalScore.value}",
                                style: const TextStyle(
                                  fontSize: 46,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                "dari 100",
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.level.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _statusCard(lc),
              const SizedBox(height: 16),
              _scoreBreakdownCard(),
              const SizedBox(height: 16),
              _clinicalScoresRow(),
              const SizedBox(height: 28),

              _sectionHeader("Insight Hari Ini"),
              const SizedBox(height: 12),
              _insightCard(
                Icons.psychology_outlined,
                "Kondisi Mental",
                controller.mentalPercentage.value >= 80
                    ? "Kondisi emosional Anda sangat stabil dan terkendali hari ini."
                    : controller.mentalPercentage.value >= 60
                        ? "Secara umum kondisi mental Anda cukup baik. Tetap jaga keseimbangan."
                        : controller.mentalPercentage.value >= 40
                            ? "Terdapat beberapa tanda tekanan psikologis yang perlu diperhatikan."
                            : "Kondisi mental menunjukkan tekanan cukup berat. Istirahat dan cari dukungan.",
                lc,
              ),
              _insightCard(
                Icons.hotel_outlined,
                "Pola Tidur",
                controller.sleepHours.value >= 8
                    ? "Durasi tidur Anda sangat baik dan mendukung pemulihan fisik maupun mental."
                    : controller.sleepHours.value >= 6
                        ? "Waktu tidur Anda cukup, namun bisa ditingkatkan lagi."
                        : "Durasi tidur masih kurang. Coba atur jam tidur lebih konsisten.",
                const Color(0xFF5C6BC0),
              ),
              _insightCard(
                Icons.people_outline,
                "Interaksi Sosial",
                controller.socialInteraction.value >= 3
                    ? "Hubungan sosial Anda aktif dan positif hari ini."
                    : controller.socialInteraction.value >= 2
                        ? "Interaksi sosial cukup baik dan membantu kesehatan emosional."
                        : "Luangkan waktu untuk berbicara dengan keluarga atau teman terdekat.",
                const Color(0xFF00897B),
              ),
              _insightCard(
                Icons.trending_up_rounded,
                "Produktivitas",
                controller.productivity.value >= 3
                    ? "Produktivitas Anda berada pada tingkat yang sangat baik hari ini."
                    : controller.productivity.value >= 2
                        ? "Aktivitas harian berjalan cukup baik dan produktif."
                        : "Produktivitas masih rendah. Coba buat target kecil yang realistis.",
                const Color(0xFFE65100),
                isLast: true,
              ),

              const SizedBox(height: 24),
              _sectionHeader("Rekomendasi untuk Hari Ini"),
              const SizedBox(height: 12),
              ...controller.recommendations
                  .map((item) => _recommendationCard(item))
                  .toList(),

              const SizedBox(height: 28),
              _tombolKembali(lc),
            ]),
          ),
        ),
      ],
    );
  }

  // ===========================
  // STATUS CARD
  // ===========================
  Widget _statusCard(Color lc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTitle(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: lc),
          ),
          const SizedBox(height: 8),
          Text(
            _getDescription(),
            style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.55),
          ),
        ],
      ),
    );
  }

  // ===========================
  // SCORE BREAKDOWN CARD
  // ===========================
  Widget _scoreBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rincian Skor",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B434D)),
          ),
          const SizedBox(height: 16),
          _scoreBar("Kesehatan Mental", controller.mentalPercentage.value,
              const Color(0xFF2E66E7), "bobot 70%"),
          const SizedBox(height: 14),
          _scoreBar("Gaya Hidup", controller.lifestyleScore.value,
              const Color(0xFF00897B), "bobot 30%"),
        ],
      ),
    );
  }

  Widget _scoreBar(String label, int value, Color color, String weight) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
            Row(
              children: [
                Text("$value%",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                Text("  ·  $weight", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 9,
            backgroundColor: color.withOpacity(0.10),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  // ===========================
  // CLINICAL SCORES ROW
  // ===========================
  Widget _clinicalScoresRow() {
    return Row(
      children: [
        Expanded(
          child: _clinicalCard("PHQ-9", controller.phqScore.value, 27, controller.phqLevel.value),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _clinicalCard("GAD-7", controller.gadScore.value, 21, controller.gadLevel.value),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _clinicalCard(
              "DASS-S", controller.stressScore.value, 42, controller.stressLevel.value),
        ),
      ],
    );
  }

  Widget _clinicalCard(String label, int score, int max, String level) {
    final color = controller.clinicalLevelColor(level);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("$score",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B434D))),
          Text("/ $max", style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / max,
              minHeight: 4,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(level,
                style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ===========================
  // INSIGHT CARD
  // ===========================
  Widget _insightCard(
    IconData icon,
    String title,
    String description,
    Color color, {
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 3),
                Text(description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // RECOMMENDATION CARD
  // ===========================
  Widget _recommendationCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => Get.toNamed(item["route"]),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item["color"],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item["icon"], color: item["iconColor"], size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(item["subtitle"], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ===========================
  // TOMBOL KEMBALI
  // ===========================
  Widget _tombolKembali(Color lc) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Get.offAllNamed('/beranda'),
        style: ElevatedButton.styleFrom(
          backgroundColor: lc,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: const Text(
          "Kembali ke Beranda",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  // ===========================
  // HELPERS
  // ===========================
  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF2E66E7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (controller.level.value) {
      case "Sangat Baik": return "Kondisi Mental Sangat Baik";
      case "Baik":        return "Kondisi Mental Baik";
      case "Sedang":      return "Perlu Sedikit Perhatian";
      case "Kurang":      return "Perlu Menjaga Keseimbangan";
      case "Buruk":       return "Perlu Dukungan dan Perhatian";
      default:            return "Hasil Assessment";
    }
  }

  String _getDescription() {
    switch (controller.level.value) {
      case "Sangat Baik":
        return "Kesehatan mental dan aktivitas harian Anda berada pada kondisi yang sangat baik. Pertahankan pola hidup positif yang sudah berjalan.";
      case "Baik":
        return "Kondisi kesehatan mental Anda cukup baik. Tetap jaga kualitas tidur, aktivitas fisik, dan hubungan sosial.";
      case "Sedang":
        return "Terdapat beberapa indikator yang perlu diperhatikan. Cobalah meningkatkan aktivitas positif dan kelola stres dengan baik.";
      case "Kurang":
        return "Beberapa aspek kesehatan mental menunjukkan penurunan. Luangkan waktu untuk istirahat dan pemulihan.";
      case "Buruk":
        return "Hasil assessment menunjukkan kondisi yang memerlukan perhatian lebih. Pertimbangkan untuk berkonsultasi dengan tenaga profesional.";
      default:
        return "Terima kasih telah menyelesaikan assessment hari ini.";
    }
  }
}

/// Panah kecil dengan animasi naik-turun halus, menandakan "geser/tekan untuk lihat lebih".
class _BouncingArrow extends StatefulWidget {
  @override
  State<_BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<_BouncingArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _offset =
      Tween<double>(begin: 0, end: 6).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _offset.value),
        child: child,
      ),
      child: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}