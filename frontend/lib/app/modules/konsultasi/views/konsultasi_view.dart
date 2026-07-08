import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/konsultasi_controller.dart';
import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../data/assessment_data.dart';

class KonsultasiView extends GetView<KonsultasiController> {
  const KonsultasiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<NavigationController>().currentIndex.value = 1;

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E66E7),
        elevation: 0,
        centerTitle: false,
        title: const Text('MindTrack',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.spa, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() => controller.isVoiceMode.value
                ? _buildVoiceBody()
                : _buildManualBody()),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  // ═══════════════════════════════════════════════════
  //  HEADER + TOGGLE
  // ═══════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          Text('Konsultasi Hari Ini',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 4),
          const Text(
            'Ceritakan perasaan Anda — kami siap mendengarkan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Obx(() => Row(children: [
                  _toggleBtn('Voice', controller.isVoiceMode.value,
                      () => controller.switchMode(true)),
                  _toggleBtn('Manual', !controller.isVoiceMode.value,
                      () => controller.switchMode(false)),
                ])),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2E66E7) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  VOICE BODY
  // ═══════════════════════════════════════════════════
  Widget _buildVoiceBody() {
    return Obx(() {
      final started = controller.chatMessages.isNotEmpty ||
          controller.voiceStatus.value != VoiceStatus.idle;
      if (!started) return _buildVoiceIntro();
      return _buildVoiceSession();
    });
  }

  // ── Halaman pembuka sebelum sesi dimulai ────────────
  Widget _buildVoiceIntro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF2E66E7), const Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF2E66E7).withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: 4)
                ],
              ),
              child: const Icon(Icons.psychology_alt, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 24),
            Text('Asisten Suara MindTrack',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 10),
            const Text(
              'Jawab pertanyaan dengan berbicara santai — '
              'tidak perlu menekan tombol kirim. '
              'AI kami akan langsung mendengar dan merespons.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            // Fitur kilat
            _featureRow(Icons.mic_none, 'Bicara bebas, otomatis terkirim'),
            _featureRow(Icons.chat_bubble_outline, 'Percakapan natural & mengalir'),
            _featureRow(Icons.speed, 'Ditenagai Groq (respons cepat)'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.startVoiceSession,
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text('Mulai Sesi Suara',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E66E7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E66E7)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Sesi aktif (chat bubbles + mic) ─────────────────
  Widget _buildVoiceSession() {
    return Column(
      children: [
        // Progress bar di atas
        _buildProgressBar(),

        // Chat bubbles — scrollable
        Expanded(
          child: Obx(() {
            final msgs = controller.chatMessages;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: msgs.length,
              itemBuilder: (_, i) => _buildBubble(msgs[i]),
            );
          }),
        ),

        // Live transcript (teks sementara saat user bicara)
        Obx(() {
          final live = controller.liveTranscript.value;
          if (live.isEmpty && controller.voiceStatus.value != VoiceStatus.listening) {
            return const SizedBox.shrink();
          }
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    live.isEmpty ? 'Mendengarkan Anda...' : live,
                    style: const TextStyle(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }),

        // Status + Mic button
        _buildMicPanel(),

        // Tombol simpan (muncul saat semua step selesai)
        Obx(() {
          if (controller.currentStep.value < KonsultasiController.totalSteps) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _bottomButton('Simpan Laporan Hari Ini', () async {
              try {
                final result = await controller.submitAssessment();
                Get.toNamed('/hasil', arguments: result);
              } catch (e) {
                Get.snackbar('Belum Bisa Disimpan',
                    e.toString().replaceFirst('Exception: ', ''));
              }
            }),
          );
        }),

        const SizedBox(height: 8),
      ],
    );
  }

  // ── Chat bubble ──────────────────────────────────────
  Widget _buildBubble(ChatMessage msg) {
    final isAi = msg.isAi;
    return Padding(
      padding: EdgeInsets.only(
          left: isAi ? 0 : 48,
          right: isAi ? 48 : 0,
          bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAi) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2E66E7),
              child: const Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isAi
                    ? (Get.isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50)
                    : const Color(0xFF2E66E7),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isAi ? 4 : 18),
                  bottomRight: Radius.circular(isAi ? 18 : 4),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isAi
                      ? Get.theme.textTheme.bodyLarge?.color
                      : Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Panel Mic + label status ─────────────────────────
  Widget _buildMicPanel() {
    return Obx(() {
      final status = controller.voiceStatus.value;

      Color micColor;
      IconData micIcon;
      String label;
      bool micEnabled;

      switch (status) {
        case VoiceStatus.listening:
          micColor   = Colors.red;
          micIcon    = Icons.stop_rounded;
          label      = 'Ketuk untuk selesai lebih awal';
          micEnabled = true;
          break;
        case VoiceStatus.thinking:
          micColor   = Colors.orange;
          micIcon    = Icons.hourglass_top_rounded;
          label      = 'Memahami jawaban Anda...';
          micEnabled = false;
          break;
        case VoiceStatus.speaking:
          micColor   = const Color(0xFF7C4DFF);
          micIcon    = Icons.volume_up_rounded;
          label      = 'Asisten sedang berbicara...';
          micEnabled = false;
          break;
        default:
          micColor   = const Color(0xFF2E66E7);
          micIcon    = Icons.mic_rounded;
          label      = 'Ketuk mic untuk berbicara';
          micEnabled = true;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            GestureDetector(
              onTap: micEnabled ? controller.tapMic : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: micColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: micColor.withOpacity(status == VoiceStatus.listening ? 0.5 : 0.3),
                      blurRadius: status == VoiceStatus.listening ? 28 : 14,
                      spreadRadius: status == VoiceStatus.listening ? 6 : 0,
                    ),
                  ],
                ),
                child: Icon(micIcon, color: Colors.white, size: 34),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                label,
                key: ValueKey(label),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════
  //  MANUAL BODY (tidak berubah sama sekali)
  // ═══════════════════════════════════════════════════
  Widget _buildManualBody() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: PageView.builder(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: KonsultasiController.totalSteps + 1,
            itemBuilder: (context, index) {
              if (index < KonsultasiController.totalClinical) {
                return _buildClinicalStep(index);
              } else if (index < KonsultasiController.totalSteps) {
                return _buildLifestyleStep(index - KonsultasiController.totalClinical);
              } else {
                return _buildSummaryStep();
              }
            },
          ),
        ),
      ],
    );
  }

  // ── Progress bar (dipakai Manual & Voice) ───────────
  Widget _buildProgressBar() {
    return Obx(() {
      final step  = controller.currentStep.value;
      final total = KonsultasiController.totalSteps;
      final type  = step < KonsultasiController.totalClinical
          ? allClinicalQuestions[step.clamp(0, KonsultasiController.totalClinical - 1)].type
          : null;
      final label = type != null
          ? _instrumentLabel(type)
          : (step < total ? 'Aktivitas Harian' : 'Ringkasan');
      final color = type != null ? _instrumentColor(type) : const Color(0xFF2E66E7);

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ]),
                Text('${step.clamp(0, total)} / $total',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: controller.progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _instrumentLabel(InstrumentType type) {
    switch (type) {
      case InstrumentType.phq:    return 'Suasana Hati';
      case InstrumentType.gad:    return 'Kecemasan';
      case InstrumentType.stress: return 'Stres';
    }
  }

  Color _instrumentColor(InstrumentType type) {
    switch (type) {
      case InstrumentType.phq:    return const Color(0xFF2E66E7);
      case InstrumentType.gad:    return const Color(0xFF7C4DFF);
      case InstrumentType.stress: return const Color(0xFFFF7A45);
    }
  }

  // ── Soal klinis ──────────────────────────────────────
  Widget _buildClinicalStep(int flatIndex) {
    final question = allClinicalQuestions[flatIndex];
    final color    = _instrumentColor(question.type);

    return Obx(() {
      final selected = controller.clinicalAnswers[flatIndex];
      return SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(_instrumentLabel(question.type),
                          style: TextStyle(
                              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 14),
                    Text(question.text,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: Get.theme.textTheme.bodyLarge?.color)),
                    const SizedBox(height: 8),
                    const Text(
                        'Selama beberapa hari terakhir, seberapa sering Anda mengalami hal ini?',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 26),
                    ...List.generate(answerOptions.length, (i) {
                      final active = selected == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => controller.answerClinical(flatIndex, i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 18),
                            decoration: BoxDecoration(
                              color: active ? color : Colors.transparent,
                              border: Border.all(
                                  color: active ? color : Colors.grey.shade300,
                                  width: active ? 0 : 1),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                          color: color.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(answerOptions[i],
                                      style: TextStyle(
                                          color: active
                                              ? Colors.white
                                              : Get.theme.textTheme.bodyMedium?.color,
                                          fontWeight: active
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                ),
                                if (active)
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            _navRow(showNext: false),
          ],
        ),
      );
    });
  }

  // ── Lifestyle steps ──────────────────────────────────
  Widget _buildLifestyleStep(int li) {
    switch (li) {
      case 0:
        return _lifestyleWrapper(
            title: 'Durasi Tidur', icon: Icons.bedtime_outlined,
            child: Obx(() => _buildSlider(
                controller.sleepHours.value, (v) => controller.sleepHours.value = v)),
            canNext: true);
      case 1:
        return _lifestyleWrapper(
            title: 'Kualitas Tidur', icon: Icons.nightlight_outlined,
            child: _buildChoiceSection(controller.sleepQuality,
                const ['Sangat Buruk', 'Buruk', 'Cukup', 'Baik', 'Sangat Baik']));
      case 2:
        return _lifestyleWrapper(
            title: 'Aktivitas Fisik Hari Ini', icon: Icons.directions_run,
            child: _buildChoiceSection(controller.physicalActivity,
                const ['Tidak Ada', 'Ringan', 'Sedang', 'Aktif', 'Sangat Aktif']));
      case 3:
        return _lifestyleWrapper(
            title: 'Interaksi Sosial Hari Ini', icon: Icons.people_outline,
            child: _buildChoiceSection(controller.socialInteraction,
                const ['Tidak Ada', 'Sedikit', 'Cukup', 'Banyak', 'Sangat Banyak']));
      default:
        return _lifestyleWrapper(
            title: 'Produktivitas Hari Ini', icon: Icons.task_alt,
            child: _buildChoiceSection(controller.productivity,
                const ['Sangat Rendah', 'Rendah', 'Sedang', 'Tinggi', 'Sangat Tinggi']));
    }
  }

  Widget _lifestyleWrapper({
    required String title,
    required IconData icon,
    required Widget child,
    bool canNext = false,
  }) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF2E66E7).withOpacity(0.1),
                    child: Icon(icon, color: const Color(0xFF2E66E7)),
                  ),
                  const SizedBox(height: 18),
                  Text(title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 26),
                  child,
                ],
              ),
            ),
          ),
          _navRow(showNext: canNext),
        ],
      ),
    );
  }

  Widget _navRow({required bool showNext}) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              if (controller.currentStep.value > 0)
                TextButton.icon(
                    onPressed: controller.prevStep,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Kembali')),
              const Spacer(),
              if (showNext)
                ElevatedButton(
                  onPressed: controller.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E66E7),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Lanjut', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ));
  }

  Widget _buildSummaryStep() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E66E7), size: 60),
            const SizedBox(height: 20),
            Text('Semua pertanyaan sudah terisi',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            const Text('Tekan tombol di bawah untuk menyimpan laporan kesehatan mental hari ini.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _bottomButton('Simpan Laporan Hari Ini', () async {
              try {
                final result = await controller.submitAssessment();
                Get.toNamed('/hasil', arguments: result);
              } catch (e) {
                Get.snackbar('Belum Bisa Disimpan',
                    e.toString().replaceFirst('Exception: ', ''));
              }
            }),
            _navRow(showNext: false),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  REUSABLE WIDGETS
  // ═══════════════════════════════════════════════════
  Widget _buildSlider(double val, Function(double) onChanged) {
    return Column(
      children: [
        Text('${val.toStringAsFixed(1)} Jam',
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E66E7))),
        Slider(
            value: val,
            min: 0,
            max: 12,
            divisions: 20,
            activeColor: const Color(0xFF2E66E7),
            onChanged: onChanged),
      ],
    );
  }

  Widget _buildChoiceSection(Rx<int?> selected, List<String> options) {
    return Obx(() => Column(
          children: List.generate(options.length, (index) {
            final active = selected.value == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  selected.value = index;
                  controller.nextStep();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF2E66E7) : Colors.transparent,
                    border: Border.all(
                        color: active ? const Color(0xFF2E66E7) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(options[index],
                      style: TextStyle(
                          color: active
                              ? Colors.white
                              : Get.theme.textTheme.bodyMedium?.color,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal)),
                ),
              ),
            );
          }),
        ));
  }

  Widget _bottomButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E66E7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
