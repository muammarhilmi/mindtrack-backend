import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BreathingView extends StatefulWidget {
  const BreathingView({super.key});

  @override
  State<BreathingView> createState() => _BreathingViewState();
}

class _BreathingViewState extends State<BreathingView>
    with TickerProviderStateMixin { // 🛠️ Diubah ke TickerProviderStateMixin agar bisa support > 1 controller
  late AnimationController _controller;
  late AnimationController _particleController; // 🛠️ Controller khusus partikel
  late Animation<double> _animation;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isRunning = false;
  bool isMusicPlaying = false;

  String phase = "Siap";
  String selectedMode = "Box Breathing";

  int inhale = 4;
  int hold = 4;
  int exhale = 4;
  int timeRemaining = 0; // 🛠️ Untuk hitung mundur detik di dalam lingkaran

  final random = Random();
  List<_Particle> particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Tweaking animasi melar lingkaran agar terasa lebih organis (0.95 ke 1.45)
    _animation = Tween<double>(begin: 0.95, end: 1.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    // Ticker mandiri untuk debu halus di background
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _generateParticles();
  }

  void _generateParticles() {
    particles = List.generate(25, (i) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.0004 + random.nextDouble() * 0.0008,
        size: 2 + random.nextDouble() * 4,
      );
    });
  }

  Future<void> playMusic() async {
    try {
      await _audioPlayer.setAsset('assets/music/hutan.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
      setState(() => isMusicPlaying = true);
    } catch (e) {
      debugPrint("Gagal memutar audio: $e");
    }
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    setState(() => isMusicPlaying = false);
  }

  void setMode(String mode) {
    if (isRunning) return; // Kunci perubahan mode saat latihan berjalan demi kestabilan
    setState(() {
      selectedMode = mode;
      if (mode == "Box Breathing") {
        inhale = 4;
        hold = 4;
        exhale = 4;
      } else {
        inhale = 4;
        hold = 7;
        exhale = 8;
      }
    });
  }

  void start() {
    setState(() => isRunning = true);
    playMusic();
    _runCycle();
  }

  void stop() {
    setState(() {
      isRunning = false;
      phase = "Siap";
      timeRemaining = 0;
    });
    stopMusic();
    _controller.stop();
  }

  // 🛠️ Siklus pernapasan pintar dengan sinkronisasi detak detik asli & animasi
  Future<void> _runCycle() async {
    if (!isRunning) return;

    // 1. FASE TARIK NAPAS
    setState(() {
      phase = "Tarik Napas";
      timeRemaining = inhale;
    });
    _controller.duration = Duration(seconds: inhale);
    _controller.forward(from: 0);
    
    for (int i = inhale; i > 0; i--) {
      if (!isRunning) return;
      setState(() => timeRemaining = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!isRunning) return;

    // 2. FASE TAHAN NAPAS
    setState(() {
      phase = "Tahan Napas";
      timeRemaining = hold;
    });
    // Tetap berada di ukuran maksimal saat menahan napas
    for (int i = hold; i > 0; i--) {
      if (!isRunning) return;
      setState(() => timeRemaining = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!isRunning) return;

    // 3. FASE HEMBUSKAN
    setState(() {
      phase = "Hembuskan";
      timeRemaining = exhale;
    });
    _controller.duration = Duration(seconds: exhale);
    _controller.reverse(from: 1.0);

    for (int i = exhale; i > 0; i--) {
      if (!isRunning) return;
      setState(() => timeRemaining = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!isRunning) return;
    _runCycle(); // Loop ke siklus berikutnya
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // 🌿 Animasi partikel mengambang halus berbasis controller terisolasi
  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: particles.map((p) {
            p.y -= p.speed;
            if (p.y < 0) {
              p.y = 1;
              p.x = random.nextDouble();
            }

            return Positioned(
              left: p.x * MediaQuery.of(context).size.width,
              top: p.y * MediaQuery.of(context).size.height,
              child: Container(
                width: p.size,
                height: p.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.1),
                      blurRadius: p.size,
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Palet warna khusus meditasi (Deep Blue Space Night vibe)
    const primaryTeal = Color(0xFF67E8F9);
    const accentBlue = Color(0xFF3B82F6);

    return Scaffold(
      // Mengizinkan isi body mengalir tembus ke belakang AppBar bawaan
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text(
          "Ruang Napas",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isMusicPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: Colors.white70, // Putih transparan lembut
            ),
            onPressed: isMusicPlaying ? stopMusic : playMusic,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Stack(
        children: [
          // --- BACKGROUND GRADIENT CINEMATIC ---
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A), // Midnight Slate
                  Color(0xFF1E3A8A), // Deep Ocean Blue
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          _buildParticles(),

          // --- MAIN INTERFACE CONTENT ---
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 10),

                // 🎯 SELEKTOR MODE (GLASSMORPHISM STYLE)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _modeChip("Box Breathing"),
                    const SizedBox(width: 12),
                    _modeChip("4-7-8 Breathing"),
                  ],
                ),

                // 🔮 TRIPLE GOWING RINGS + DETIK HITUNG MUNDUR
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final sizeValue = 180 * _animation.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran Aura Luar (Sangat Tipis)
                        Container(
                          width: sizeValue * 1.3,
                          height: sizeValue * 1.3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentBlue.withOpacity(0.04),
                          ),
                        ),
                        // Lingkaran Aura Tengah
                        Container(
                          width: sizeValue * 1.15,
                          height: sizeValue * 1.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryTeal.withOpacity(0.08),
                          ),
                        ),
                        // Inti Lingkaran Utama
                        Container(
                          width: sizeValue,
                          height: sizeValue,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accentBlue.withOpacity(0.4),
                                primaryTeal.withOpacity(0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryTeal.withOpacity(0.25),
                                blurRadius: 40,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Center(
                            child: isRunning
                                ? Text(
                                    "$timeRemaining",
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                    ),
                                  )
                                : const Icon(
                                    Icons.spa_rounded,
                                    size: 56,
                                    color: Colors.white70,
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // INFO FASE DAN URUTAN METRIK DETIK
                Column(
                  children: [
                    Text(
                      phase,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$inhale • $hold • $exhale",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                // 🔘 TOMBOL UTAMA AKSYON
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                    width: 160,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isRunning ? stop : start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRunning ? Colors.white.withOpacity(0.15) : Colors.white,
                        foregroundColor: isRunning ? Colors.white : const Color(0xFF0F172A),
                        elevation: isRunning ? 0 : 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: isRunning 
                              ? BorderSide(color: Colors.white.withOpacity(0.4), width: 1) 
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        isRunning ? "Selesai" : "Mulai",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip(String title) {
    final isSelected = selectedMode == title;

    return GestureDetector(
      onTap: () => setMode(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double size;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}

// Extension pembantu untuk mempercepat penulisan opacity warna putih bawaan
extension on Colors {
  static const Color whiteAC = Color(0xB3FFFFFF); // Putih 70% Opacity
}