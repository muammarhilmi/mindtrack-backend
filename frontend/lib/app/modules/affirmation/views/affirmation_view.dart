import 'dart:math';
import 'package:flutter/material.dart';

class AffirmationView extends StatefulWidget {
  const AffirmationView({super.key});

  @override
  State<AffirmationView> createState() => _AffirmationViewState();
}

class _AffirmationViewState extends State<AffirmationView>
    with SingleTickerProviderStateMixin { // 🛟 Cukup satu Mixin karena kita optimalkan satu controller untuk semua loop ambient
  
  final List<String> affirmations = [
    "Saya cukup, bahkan saat tidak produktif.",
    "Saya aman di tempat saya berada sekarang.",
    "Saya tidak harus terburu-buru dalam hidup.",
    "Saya boleh merasa lelah dan tetap berharga.",
    "Hari ini tidak harus sempurna.",
    "Saya memilih untuk lebih tenang.",
    "Saya tidak perlu membandingkan diri.",
    "Apa yang saya rasakan adalah valid.",
    "Saya sedang bertumbuh, meski perlahan.",
    "Saya percaya hidup sedang membentuk saya.",
    "Saya bisa melewati ini, pelan-pelan.",
    "Tidak semua hal harus saya kendalikan.",
  ];

  int index = 0;
  final random = Random();
  List<_Particle> particles = [];
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();

    // Controller ambient berjalan konstan tanpa henti untuk partikel & efek napas teks
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _generateParticles();
  }

  void _generateParticles() {
    particles = List.generate(20, (i) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.0003 + random.nextDouble() * 0.0006,
        size: 2 + random.nextDouble() * 4,
      );
    });
  }

  void next() {
    setState(() {
      index = (index + 1) % affirmations.length;
    });
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  // 🌿 Partikel melayang secara kontinu tanpa interupsi ketukan
  Widget _buildAmbientParticles() {
    return AnimatedBuilder(
      animation: _ambientController,
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
                  color: const Color(0xFF6C7CE7).withOpacity(0.12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C7CE7).withOpacity(0.05),
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
    return Scaffold(
      body: GestureDetector(
        onTap: next,
        behavior: HitTestBehavior.opaque, // Memastikan ketukan di area kosong tetap memicu fungsi next
        child: Stack(
          children: [
            // --- LUXURY IRIDESCENT GRADIENT ---
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF1F5FF), // Soft Pastel Indigo Touch
                    Color(0xFFF8FAFC), // Crisp Clean Pearl
                    Color(0xFFF4F3FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            _buildAmbientParticles(),

            // --- CENTRAL CONTENT WITH CINEMATIC SWITCHER ---
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ornamen kutipan estetik pembangun atmosfer
                    Icon(
                      Icons.format_quote_rounded,
                      size: 46,
                      color: const Color(0xFF6C7CE7).withOpacity(0.25),
                    ),
                    const SizedBox(height: 16),
                    
                    // Komponen sulap transision silang otomatis
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04), // Efek dorongan tipis dari bawah saat muncul
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        affirmations[index],
                        key: ValueKey<int>(index), // 🔥 Wajib diisi agar Flutter tahu teks telah berganti objek
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          height: 1.8,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                          color: Color(0xFF1E2235),
                          fontFamily: 'Georgia', // Gaya baca premium dipertahankan
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BREATHING FOOTER HINT ---
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, child) {
                  // Memanfaatkan rumus matematika sinus untuk membuat efek opacity memudar-terang (0.25 ke 0.65) secara berkala
                  final pulse = 0.25 + (sin(_ambientController.value * 2 * pi) + 1) * 0.2;
                  return Opacity(
                    opacity: pulse,
                    child: child,
                  );
                },
                child: const Text(
                  "ketuk di mana saja untuk melanjutkan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
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