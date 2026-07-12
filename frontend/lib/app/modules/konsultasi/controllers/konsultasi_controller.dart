import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../data/assessment_data.dart';
import '../../../data/providers/assessment_provider.dart';
import '../../../controllers/navigation_controller.dart';

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

  // ── Groq API ──────────────────────────────────────────────────
  // Dapatkan API Key di https://console.groq.com/keys
  static const _groqKey   = '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'; 
  static const _groqModel = 'llama-3.3-70b-versatile'; 
  static const _groqUrl   = 'https://api.groq.com/openai/v1/chat/completions';

  // Riwayat percakapan format standar OpenAI/Groq: role 'user' / 'assistant'
  final List<Map<String, String>> _chatHistory = [];

  // Guard agar tidak ada dua permintaan paralel
  bool _processing = false;

  // Apakah sesi voice sedang "aktif"
  bool _sessionActive = false;
  StreamSubscription<int>? _tabSub;

  // ══════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ══════════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _initEngines();
    _watchTabChanges();
  }

  Future<void> _initEngines() async {
    // 1. Pengaturan Dasar TTS
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.48); // Sedikit diperlambat agar lebih empatik
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    // 2. Inisialisasi STT
    _sttReady = await _speech.initialize(
      onStatus: (s) {
        if ((s == 'notListening' || s == 'done') &&
            voiceStatus.value == VoiceStatus.listening) {
          _onListenDone();
        }
      },
      onError: (_) {
        voiceStatus.value = VoiceStatus.idle;
      },
    );

    // 3. Panggil fungsi ubah suara secara terpisah TANPA 'await'
    // Sehingga tidak memblokir alur aplikasi jika prosesnya lama.
    _optimizeVoice(); 
  }

  // Fungsi KHUSUS untuk mengubah ke suara "Network"
  Future<void> _optimizeVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null) return;

      for (var voice in voices) {
        final name = voice['name']?.toString().toLowerCase() ?? '';
        final locale = voice['locale']?.toString().toLowerCase() ?? '';
        
        if (locale.contains('id') && name.contains('network')) {
          await _tts.setVoice({
            "name": voice['name'].toString(),
            "locale": voice['locale'].toString()
          });
          debugPrint('Suara diubah ke natural (network): ${voice['name']}');
          break;
        }
      }
    } catch (e) {
      debugPrint('Gagal mengubah suara, menggunakan suara bawaan. Error: $e');
    }
  }

  void _watchTabChanges() {
    if (!Get.isRegistered<NavigationController>()) return;
    final nav = Get.find<NavigationController>();
    _tabSub = nav.currentIndex.listen((index) {
      if (index != 1) {
        _stopSession();
      }
    });
  }

  void _stopSession() {
    _sessionActive = false;
    _speech.stop();
    _tts.stop();
    if (voiceStatus.value != VoiceStatus.idle) {
      voiceStatus.value = VoiceStatus.idle;
    }
    liveTranscript.value = '';
  }

  void switchMode(bool voice) {
    isVoiceMode.value = voice;
    if (!voice) {
      _stopSession();
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
    _chatHistory.clear();
    chatMessages.clear();
    currentStep.value = 0;
    _sessionActive = true;

    const greeting =
        'Halo! Saya asisten MindTrack. Saya akan menemani Anda '
        'menjawab beberapa pertanyaan seputar perasaan dan aktivitas '
        'hari ini. Ketuk mic saat Anda siap menjawab ya.';
    await _aiSay(greeting);
  }

  // ══════════════════════════════════════════════════════════════
  //  STT — MULAI MENDENGARKAN
  // ══════════════════════════════════════════════════════════════
  Future<void> _startListening() async {
    if (!_sttReady || _processing || !_sessionActive) return;
    liveTranscript.value = '';
    voiceStatus.value = VoiceStatus.listening;

    await _speech.listen(
      localeId: 'id_ID',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        liveTranscript.value = result.recognizedWords;
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _onListenDone();
        }
      },
    );
  }

  void _onListenDone() {
    // 1. Cek apakah sudah sedang diproses
    if (_processing || !_sessionActive) return;

    // 2. Kunci SEGERA agar panggilan kedua (dari onStatus) tidak tembus
    _processing = true; 
    _speech.stop();

    final transcript = liveTranscript.value.trim();
    
    // Jika kosong, reset lock agar bisa dicoba lagi
    if (transcript.isEmpty) {
      _processing = false; 
      voiceStatus.value = VoiceStatus.idle;
      _aiSay('Maaf, saya tidak menangkap jawaban Anda. Ketuk mic dan coba lagi ya.');
      return;
    }

    voiceStatus.value = VoiceStatus.thinking;
    chatMessages.add(ChatMessage(text: transcript, isAi: false));
    liveTranscript.value = '';

    // 3. Panggil Groq (tetap gunakan _processing = true agar tidak ada input lain masuk)
    _sendToGroq(transcript);
  }

  // ══════════════════════════════════════════════════════════════
  //  KIRIM KE GROQ API
  // ══════════════════════════════════════════════════════════════
  Future<void> _sendToGroq(String userText, {int attempt = 0}) async {
    if (_processing) return;
    _processing = true;

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

    // Prompt dipertajam untuk memastikan output JSON yang ketat
    final systemPrompt = '''
Kamu adalah konselor AI MindTrack yang hangat dan empatik, berbicara dalam Bahasa Indonesia natural.
Tugasmu: merespons jawaban user dengan 1–2 kalimat empati yang mengalir,
lalu menyambung ke pertanyaan berikutnya SECARA NATURAL.
JANGAN menyebutkan skala angka atau pilihan ganda.

WAJIB MENGEMBALIKAN HANYA FORMAT JSON SEPERTI INI TANPA TEKS LAIN:
{
  "skor": 0,
  "respon": "kalimat respons + pertanyaan berikutnya"
}

Nilai "skor":
- Untuk pertanyaan klinis: integer 0–3 sesuai frekuensi.
- Untuk gaya hidup: integer 0–4 sesuai indeks opsi.
  (Khusus durasi tidur: estimasi jam gunakan field "jam_tidur").
Konteks saat ini: $ctx
''';

    if (attempt == 0) {
      _chatHistory.add({
        'role': 'user',
        'content': userText,
      });
    }

    final List<Map<String, String>> messagesPayload = [
      {'role': 'system', 'content': systemPrompt},
      ..._chatHistory,
    ];

    try {
      final res = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Authorization': 'Bearer $_groqKey', // Pastikan ganti API Key yang baru!
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _groqModel,
          'messages': messagesPayload,
          'response_format': {'type': 'json_object'}, 
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      ).timeout(const Duration(seconds: 40)); // Timeout diperpanjang jadi 40 detik

      if (res.statusCode != 200) {
        throw Exception('API Error ${res.statusCode}: ${res.body}');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      String raw = body['choices'][0]['message']['content'] as String;
      
      // ── LOGIKA EKSTRAKSI JSON YANG LEBIH KUAT ──
      // Mengambil teks HANYA di dalam kurung kurawal { ... }
      final startIndex = raw.indexOf('{');
      final endIndex = raw.lastIndexOf('}');
      
      if (startIndex != -1 && endIndex != -1) {
        raw = raw.substring(startIndex, endIndex + 1);
      } else {
        throw Exception('Gagal menemukan format JSON di respons AI: $raw');
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;

      final String aiReply = (json['respon'] as String?)?.trim() ?? '';
      if (aiReply.isEmpty) throw Exception('Respons AI kosong di dalam JSON');

      _applyScore(json);

      if (currentStep.value < totalSteps) currentStep.value++;

      _chatHistory.add({
        'role': 'assistant',
        'content': aiReply,
      });
      
      _processing = false;

      if (!_sessionActive) return; 

      await _aiSay(aiReply);

    } catch (e, st) {
      // INI PENTING: Mencetak error sebenarnya ke Debug Console
      debugPrint('🚨 [ERROR GROQ API] 🚨');
      debugPrint('Attempt: $attempt');
      debugPrint('Error detail: $e');
      debugPrint('=====================');
      
      _processing = false;
      if (!_sessionActive) return;

      if (attempt < 1) {
        // Jeda 1 detik sebelum mencoba ulang (hindari spam)
        await Future.delayed(const Duration(milliseconds: 1000));
        await _sendToGroq(userText, attempt: attempt + 1);
        return;
      }

      const fallback = 'Maaf, sistem saya sedang mengalami gangguan sesaat. Ketuk mic dan ulangi jawaban Anda ya.';
      await _aiSay(fallback);
    }
  }

  void _applyScore(Map<String, dynamic> json) {
    final step = currentStep.value;
    if (step < totalClinical) {
      final raw = (json['skor'] as num?)?.toInt() ?? 0;
      clinicalAnswers[step] = raw.clamp(0, 3).toInt();
    } else if (step < totalSteps) {
      final li = step - totalClinical;
      if (li == 0) {
        final hours = (json['jam_tidur'] as num?)?.toDouble() ??
            (json['skor'] as num?)?.toDouble() ??
            7.0;
        sleepHours.value = hours.clamp(0.0, 12.0);
      } else {
        final raw = (json['skor'] as num?)?.toInt() ?? 0;
        final s = raw.clamp(0, 4).toInt();
        switch (li) {
          case 1: sleepQuality.value      = s; break;
          case 2: physicalActivity.value  = s; break;
          case 3: socialInteraction.value = s; break;
          case 4: productivity.value      = s; break;
        }
      }
    }
  }

  Future<void> _aiSay(String text) async {
    chatMessages.add(ChatMessage(text: text, isAi: true));
    voiceStatus.value = VoiceStatus.speaking;
    await _tts.speak(text);
    if (_sessionActive || voiceStatus.value == VoiceStatus.speaking) {
      voiceStatus.value = VoiceStatus.idle;
    }
  }

  void tapMic() {
    if (voiceStatus.value == VoiceStatus.listening) {
      // Cukup hentikan STT. 
      // Listener di _initEngines() otomatis mendeteksi 'notListening' dan memanggil _onListenDone().
      _speech.stop();
    } else if (voiceStatus.value == VoiceStatus.idle) {
      _startListening();
    }
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
  //  MANUAL MODE HELPERS
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
    _chatHistory.clear();
    liveTranscript.value = '';
    voiceStatus.value = VoiceStatus.idle;
    if (pageController.hasClients) pageController.jumpToPage(0);
  }

  void resetForAccountSwitch() {
    _stopSession();
    resetAssessment();
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
    _stopSession();
    _tabSub?.cancel();
    pageController.dispose();
    super.onClose();
  }
}