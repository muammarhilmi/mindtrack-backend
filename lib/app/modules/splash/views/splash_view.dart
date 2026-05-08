import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/views/auth_view.dart';// ⬅️ penting kalau pakai direct route

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {

      // 🔥 PILIH SALAH SATU (RECOMMENDED: pakai ini dulu)
      Get.offAll(() => const AuthView());

      // ❗ kalau mau pakai route:
      // Get.offAllNamed(Routes.AUTH);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Stack(
        children: [

          /// 🌈 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF5F7FB),
                  Color(0xFFE9EEFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 🎨 ORNAMEN ATAS
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF3A66DB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// 🎨 ORNAMEN BAWAH
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// 🧩 CONTENT
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// ✨ LOGO + ANIMASI
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 40 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                "assets/images/logo.jpg",
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "MindTrack",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFF3A66DB),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "CLARITY IN EVERY BREATH",
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    /// ✨ DESKRIPSI
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          "Sistem Deteksi Pola Kesehatan Mental Mahasiswa Berbasis Aktivitas Harian",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// ⏳ LOADING
                    const CircularProgressIndicator(
                      color: Color(0xFF3A66DB),
                      strokeWidth: 2.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}