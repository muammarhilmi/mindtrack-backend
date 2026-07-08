import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../data/assessment_data.dart';
import '../../../data/providers/assessment_provider.dart';

// ══════════════════════════════════════════════════════════════
//  Model satu pesan chat (untuk riwayat UI gelembung)
// ══════════════════════════════════════════════════════════════
class ChatMessage {
  final String text;
  final bool isAi;
  ChatMessage({required this.text, required this.isAi});
}

// ══════════════════════════════════════════════════════════════
//  Status sesi voice
// ══════════════════════════════════════════════════════════════
enum VoiceStatus { idle, listening, thinking, speaking }

class KonsultasiController extends GetxController {
  // ── Mode toggle ─────────────────────────────────────────────
  final isVoiceMode = true.obs;

  // ── Manual mode ─────────────────────────────────────────────
  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;

  static const int totalClinical  = 23;   // 9 PHQ + 7 GAD + 7 Stress
  static const int totalLifestyle = 5;
  static const int totalSteps     = totalClinical + totalLifestyle; // 28

  final RxList<int?> clinicalAnswers = List<int?>.filled(totalClinical, null).obs;

  final sleepHours        = 7.0.obs;
  final RxnInt sleepQuality      = RxnInt();
  final RxnInt physicalActivity  = RxnInt();
  final RxnInt socialInteraction = RxnInt();
  final RxnInt productivity      = RxnInt();

  final AssessmentProvider _assessmentProvider = AssessmentProvider();

  // ── Voice mode state ─────────────────────────────────────────
  final voiceStatus     = VoiceStatus.idle.obs;
  final liveTranscript  = ''.obs;           // teks realtime STT
  final chatMessages    = <ChatMessage>[].obs; // riwayat gelembung chat

  // Engine
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _sttReady = false;

  // Groq
  static const _groqUrl  = 'https://api.groq.com/openai/v1/chat/completions';
  static const _groqKey  = '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'; // ← isi API key
  static const _groqModel = 'llama-3.3-70b-versatile';

  // Riwayat untuk konteks Groq (role: system/user/assistant)
  final List<Map<String, String>> _groqHistory = [];

  // Guard agar tidak ada dua permintaan paralel
  bool _processing = false;

  // ══════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ══════════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _initEngines();
  }

  Future<void> _initEngines() async {
    // TTS
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    // STT
    _sttReady = await _speech.initialize(
      onStatus: (s) {
        // 'notListening' / 'done' → auto-submit jika ada transkripsi
        if ((s == 'notListening' || s == 'done') &&
            voiceStatus.value == VoiceStatus.listening) {
          _onListenDone();
        }
      },
      onError: (_) {
        voiceStatus.value = VoiceStatus.idle;
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  MODE SWITCH
  // ══════════════════════════════════════════════════════════════
  void switchMode(bool voice) {
    isVoiceMode.value = voice;
    if (!voice) {
      _tts.stop();
      _speech.stop();
      voiceStatus.value = VoiceStatus.idle;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  VOICE SESSION — START
  // ══════════════════════════════════════════════════════════════
  Future<void> startVoiceSession() async {
    if (!_sttReady) {
      Get.snackbar('Izin Mikrofon', 'Aktifkan izin mikrofon di pengaturan.');
      return;
    }
    _groqHistory.clear();
    chatMessages.clear();
    currentStep.value = 0;

    const greeting =
        'Halo! Saya asisten MindTrack. Saya akan menemani Anda '
        'menjawab beberapa pertanyaan seputar perasaan dan aktivitas '
        'hari ini. Cukup jawab dengan santai ya.';
    await _aiSay(greeting);
    // Setelah AI selesai bicara, langsung minta user bicara
    await _startListening();
  }

  // ══════════════════════════════════════════════════════════════
  //  STT — MULAI MENDENGARKAN
  // ══════════════════════════════════════════════════════════════
  Future<void> _startListening() async {
    if (!_sttReady || _processing) return;
    liveTranscript.value = '';
    voiceStatus.value = VoiceStatus.listening;

    await _speech.listen(
      localeId: 'id_ID',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2), // ← jeda diam 2 dtk → auto-submit
      onResult: (result) {
        liveTranscript.value = result.recognizedWords;
        // finalResult = STT yakin user sudah selesai bicara
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _onListenDone();
        }
      },
    );
  }

  // Dipanggil saat STT berhenti (auto atau manual)
  void _onListenDone() {
    if (_processing) return;
    _speech.stop();
    voiceStatus.value = VoiceStatus.thinking;

    final transcript = liveTranscript.value.trim();
    if (transcript.isEmpty) {
      // Tidak ada suara → minta ulang
      _aiSay('Maaf, saya tidak menangkap jawaban Anda. Bisa diulangi?')
          .then((_) => _startListening());
      return;
    }

    // Tampilkan gelembung user
    chatMessages.add(ChatMessage(text: transcript, isAi: false));
    liveTranscript.value = '';

    _sendToGroq(transcript);
  }

  // ══════════════════════════════════════════════════════════════
  //  KIRIM KE GROQ — INTI LOGIKA
  // ══════════════════════════════════════════════════════════════
  Future<void> _sendToGroq(String userText) async {
    if (_processing) return;
    _processing = true;

    // Bangun konteks pertanyaan saat ini
    String ctx = '';
    if (currentStep.value < totalClinical) {
      final q = allClinicalQuestions[currentStep.value];
      final label = _instrumentLabel(q.type);
      ctx = 'Instrumen: $label. '
          'Pertanyaan klinis (JANGAN ubah makna): "${q.text}". '
          'Skala jawaban: 0=Tidak sama sekali, 1=Beberapa hari, '
          '2=Lebih dari separuh hari, 3=Hampir setiap hari.';
    } else if (currentStep.value < totalSteps) {
      final li = currentStep.value - totalClinical;
      ctx = 'Pertanyaan gaya hidup: ${_lifestyleTitle(li)}. '
          'Opsi: ${_lifestyleOptions(li).asMap().entries.map((e) => '${e.key}=${e.value}').join(', ')}.';
    } else {
      ctx = 'Semua pertanyaan selesai. Buat kalimat penutup yang hangat tanpa diagnosis.';
    }

    const systemPrompt = '''
Kamu adalah konselor AI MindTrack yang hangat dan empatik, berbicara dalam Bahasa Indonesia natural.
Tugasmu: merespons jawaban user dengan 1–2 kalimat empati yang mengalir,
lalu menyambung ke pertanyaan berikutnya SECARA NATURAL (jangan kaku atau formal).
JANGAN menyebutkan skala angka, pilihan ganda, atau kata "pertanyaan berikutnya".

Kembalikan HANYA JSON mentah (tanpa markdown), format persis:
{
  "skor": 0,
  "respon": "kalimat respons + pertanyaan berikutnya yang mengalir"
}

Nilai "skor":
- Untuk pertanyaan klinis: integer 0–3 sesuai frekuensi yang diungkapkan user.
- Untuk gaya hidup: integer 0–4 sesuai indeks opsi yang paling cocok.
  Khusus durasi tidur: estimasi jam (0–12) sebagai angka desimal (gunakan field "jam_tidur" BUKAN "skor").
- Jika tidak bisa dipastikan, gunakan nilai yang paling mendekati.
''';

    _groqHistory.add({'role': 'user', 'content': userText});

    try {
      final res = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Authorization': 'Bearer $_groqKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _groqModel,
          'messages': [
            {'role': 'system', 'content': '$systemPrompt\n\nKonteks saat ini: $ctx'},
            ..._groqHistory,
          ],
          'response_format': {'type': 'json_object'},
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (res.statusCode != 200) throw Exception('Groq error ${res.statusCode}');

      final raw  = jsonDecode(res.body)['choices'][0]['message']['content'] as String;
      final json = jsonDecode(raw);

      final String aiReply = json['respon'] ?? '';

      // Simpan skor ke state
      _applyScore(json);

      // Maju ke step berikutnya
      if (currentStep.value < totalSteps) currentStep.value++;

      _groqHistory.add({'role': 'assistant', 'content': aiReply});

      await _aiSay(aiReply);

      // Jika sesi belum selesai, langsung mulai dengarkan lagi
      if (currentStep.value < totalSteps) {
        await _startListening();
      } else {
        voiceStatus.value = VoiceStatus.idle;
      }
    } catch (e) {
      const fallback = 'Maaf, koneksi saya terganggu. Bisa ulangi jawaban Anda?';
      await _aiSay(fallback);
      await _startListening();
    } finally {
      _processing = false;
    }
  }

  void _applyScore(Map<String, dynamic> json) {
    final step = currentStep.value;
    if (step < totalClinical) {
      final s = (json['skor'] as num?)?.toInt()?.clamp(0, 3) ?? 0;
      clinicalAnswers[step] = s;
    } else if (step < totalSteps) {
      final li = step - totalClinical;
      if (li == 0) {
        // Durasi tidur: jam_tidur (desimal) atau fallback ke skor
        final hours = (json['jam_tidur'] ?? json['skor'] as num?)?.toDouble() ?? 7.0;
        sleepHours.value = hours.clamp(0.0, 12.0);
      } else {
        final s = (json['skor'] as num?)?.toInt()?.clamp(0, 4) ?? 0;
        switch (li) {
          case 1: sleepQuality.value      = s; break;
          case 2: physicalActivity.value  = s; break;
          case 3: socialInteraction.value = s; break;
          case 4: productivity.value      = s; break;
        }
      }
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  TTS HELPER
  // ══════════════════════════════════════════════════════════════
  Future<void> _aiSay(String text) async {
    chatMessages.add(ChatMessage(text: text, isAi: true));
    voiceStatus.value = VoiceStatus.speaking;
    await _tts.speak(text);
    voiceStatus.value = VoiceStatus.idle;
  }

  // Tombol "ketuk mic" manual (opsional — jika user ingin mulai tanpa menunggu)
  void tapMic() {
    if (voiceStatus.value == VoiceStatus.listening) {
      // Paksa selesai lebih awal
      _speech.stop();
      _onListenDone();
    } else if (voiceStatus.value == VoiceStatus.idle) {
      _startListening();
    }
    // Saat thinking/speaking, tidak ada aksi
  }

  // ══════════════════════════════════════════════════════════════
  //  LABEL HELPERS
  // ══════════════════════════════════════════════════════════════
  String _instrumentLabel(InstrumentType t) {
    switch (t) {
      case InstrumentType.phq:    return 'Suasana Hati (PHQ-9)';
      case InstrumentType.gad:    return 'Kecemasan (GAD-7)';
      case InstrumentType.stress: return 'Stres (DASS-21)';
    }
  }

  String _lifestyleTitle(int i) {
    const titles = ['Durasi Tidur', 'Kualitas Tidur',
        'Aktivitas Fisik', 'Interaksi Sosial', 'Produktivitas'];
    return i < titles.length ? titles[i] : '';
  }

  List<String> _lifestyleOptions(int i) {
    switch (i) {
      case 0: return ['0 jam', '3 jam', '6 jam', '8 jam', '10 jam+'];
      case 1: return ['Sangat Buruk', 'Buruk', 'Cukup', 'Baik', 'Sangat Baik'];
      case 2: return ['Tidak Ada', 'Ringan', 'Sedang', 'Aktif', 'Sangat Aktif'];
      case 3: return ['Tidak Ada', 'Sedikit', 'Cukup', 'Banyak', 'Sangat Banyak'];
      case 4: return ['Sangat Rendah', 'Rendah', 'Sedang', 'Tinggi', 'Sangat Tinggi'];
      default: return [];
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  MANUAL MODE HELPERS (tidak berubah)
  // ══════════════════════════════════════════════════════════════
  List<int> get phqAnswers    => clinicalAnswers.sublist(0,  9).map((e) => e ?? 0).toList();
  List<int> get gadAnswers    => clinicalAnswers.sublist(9,  16).map((e) => e ?? 0).toList();
  List<int> get stressAnswers => clinicalAnswers.sublist(16, 23).map((e) => e ?? 0).toList();

  void answerClinical(int flatIndex, int value) {
    clinicalAnswers[flatIndex] = value;
    _autoAdvance();
  }

  bool _isAdvancing = false;
  void _autoAdvance() {
    if (_isAdvancing) return;
    _isAdvancing = true;
    Future.delayed(const Duration(milliseconds: 200), () {
      _isAdvancing = false;
      if (currentStep.value < totalSteps) nextStep();
    });
  }

  void nextStep() {
    if (currentStep.value < totalSteps) {
      currentStep.value++;
      if (pageController.hasClients) {
        pageController.animateToPage(currentStep.value,
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      if (pageController.hasClients) {
        pageController.animateToPage(currentStep.value,
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  double get progress => currentStep.value / totalSteps;

  bool get isComplete =>
      !clinicalAnswers.contains(null) &&
      sleepQuality.value      != null &&
      physicalActivity.value  != null &&
      socialInteraction.value != null &&
      productivity.value      != null;

  void resetAssessment() {
    clinicalAnswers.value = List<int?>.filled(totalClinical, null);
    sleepHours.value = 7.0;
    sleepQuality.value      = null;
    physicalActivity.value  = null;
    socialInteraction.value = null;
    productivity.value      = null;
    currentStep.value = 0;
    chatMessages.clear();
    _groqHistory.clear();
    liveTranscript.value = '';
    voiceStatus.value = VoiceStatus.idle;
    if (pageController.hasClients) pageController.jumpToPage(0);
  }

  Future<Map<String, dynamic>> submitAssessment() async {
    if (!isComplete) {
      throw Exception('Masih ada pertanyaan yang belum terisi. Silakan periksa kembali.');
    }
    final result = await _assessmentProvider.submitAssessment(
      phqAnswers:       phqAnswers,
      gadAnswers:       gadAnswers,
      stressAnswers:    stressAnswers,
      sleepHours:       sleepHours.value,
      sleepQuality:     sleepQuality.value      ?? 0,
      physicalActivity: physicalActivity.value  ?? 0,
      socialInteraction:socialInteraction.value ?? 0,
      productivity:     productivity.value      ?? 0,
    );
    resetAssessment();
    return result;
  }

  @override
  void onClose() {
    pageController.dispose();
    _speech.stop();
    _tts.stop();
    super.onClose();
  }
}