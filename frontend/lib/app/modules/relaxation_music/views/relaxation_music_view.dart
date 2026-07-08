import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class RelaxationMusicView extends StatefulWidget {
  const RelaxationMusicView({super.key});

  @override
  State<RelaxationMusicView> createState() => _RelaxationMusicViewState();
}

class _RelaxationMusicViewState extends State<RelaxationMusicView>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  int? playingIndex;
  late AnimationController _pulseController;

  // Data musik dengan tambahan aksen warna khusus tema alam
  final List<Map<String, dynamic>> musics = [
  {"title": "Suara Angin", "file": "assets/music/angin.mp3", "icon": Icons.air_rounded, "color": Colors.lightBlue},
  {"title": "Suara Perapian", "file": "assets/music/api.mp3", "icon": Icons.local_fire_department_rounded, "color": Colors.orange},
  {"title": "Suasana Pedesaan", "file": "assets/music/desa.mp3", "icon": Icons.park_rounded, "color": Colors.amber},
  {"title": "Suasana Pegunungan", "file": "assets/music/gunung.mp3", "icon": Icons.terrain_rounded, "color": Colors.blueGrey},
  {"title": "Suara Hujan", "file": "assets/music/hujan.mp3", "icon": Icons.cloud_rounded, "color": Colors.indigo},
  
  // 🛠️ PERBAIKAN DI SINI: Colors.emerald diganti ke Colors.green atau Colors.teal
  {"title": "Suasana Hutan", "file": "assets/music/hutan.mp3", "icon": Icons.forest_rounded, "color": Colors.green},
  
  {"title": "Suara Jangkrik", "file": "assets/music/jangkrik.mp3", "icon": Icons.nightlight_round, "color": Colors.deepPurple},
  {"title": "Suasana Laut", "file": "assets/music/laut.mp3", "icon": Icons.waves_rounded, "color": Colors.cyan},
  {"title": "Suara Petir", "file": "assets/music/petir.mp3", "icon": Icons.thunderstorm_rounded, "color": Colors.purple},
  {"title": "Suasana Sungai", "file": "assets/music/sungai.mp3", "icon": Icons.water_rounded, "color": Colors.teal},
];

  @override
  void initState() {
    super.initState();
    _player.setLoopMode(LoopMode.one);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Dibuat lebih lambat agar denyutnya terasa rileks
      lowerBound: 0.98,
      upperBound: 1.02,
    )..repeat(reverse: true);
  }

  Future<void> playMusic(int index) async {
    final item = musics[index];

    if (playingIndex == index) {
      await _player.pause();
      setState(() => playingIndex = null);
      return;
    }

    try {
      await _player.setAsset(item["file"] as String);
      await _player.play();
      setState(() => playingIndex = index);
    } catch (e) {
      Get.snackbar("Opps", "Gagal memutar audio: $e", 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  // 🛠️ PERBAIKAN 1: Menggunakan cara native Flutter (Bebas eror & tidak butuh import controller)
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Gradasi background ambient terapeutik
  final bgGradient = isDark
      ? const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1E2F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  return Scaffold(
    // ... sisa kode Scaffold bawahnya tetap sama
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- PREMIUM CUSTOM APP BAR ---
            SliverAppBar(
              expandedHeight: 140.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2FF),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  "Musik Relaksasi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),
                background: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 30),
                    child: Icon(
                      Icons.spa_rounded,
                      size: 80,
                      color: (isDark ? Colors.white : const Color(0xFF2E66E7)).withOpacity(0.08),
                    ),
                  ),
                ),
              ),
            ),

            // --- DAFTAR AUDIO ---
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = musics[index];
                    final isPlaying = playingIndex == index;
                    final itemColor = item["color"] as MaterialColor;

                    // Mengatur warna kartu berdasarkan status putar & tema aplikasi
                    final cardBgColor = isPlaying
                        ? itemColor.shade700
                        : (isDark ? const Color(0xFF1E293B) : Colors.white);

                    // 🛠️ PERBAIKAN 2: Mengubah Colors.white90 menjadi Colors.white.withOpacity(0.9)
                    final mainTextColor = isPlaying 
                        ? Colors.white 
                        : (isDark ? Colors.white.withOpacity(0.9) : Colors.black87);

                    final subTextColor = isPlaying 
                        ? Colors.white70 
                        : (isDark ? Colors.white54 : Colors.black54);
                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isPlaying ? _pulseController.value : 1.0,
                          child: child,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isPlaying
                                  ? itemColor.withOpacity(0.4)
                                  : Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                              blurRadius: isPlaying ? 16 : 10,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => playMusic(index),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Wadah Ikon (Avatar) Elemen Alam
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isPlaying 
                                          ? Colors.white.withOpacity(0.2)
                                          : itemColor.withOpacity(isDark ? 0.2 : 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item["icon"] as IconData,
                                      color: isPlaying ? Colors.white : itemColor.shade600,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Judul & Subtitle Status
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["title"] as String,
                                          style: TextStyle(
                                            color: mainTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (isPlaying) ...[
                                              const Icon(Icons.volume_up_rounded, size: 14, color: Colors.white70),
                                              const SizedBox(width: 4),
                                            ],
                                            Text(
                                              isPlaying ? "Memutar di latar..." : "Ketuk untuk dengar",
                                              style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Tombol Kontrol Kanan (Play / Pause)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isPlaying ? Colors.white : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        size: 28,
                                        color: isPlaying ? itemColor.shade700 : (isDark ? Colors.white60 : Colors.black45),
                                      ),
                                      onPressed: () => playMusic(index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: musics.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}