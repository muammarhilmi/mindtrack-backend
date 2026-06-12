import 'package:get/get.dart';
import '../../../data/providers/assessment_provider.dart';

class KonsultasiController extends GetxController {

  // Toggle Voice / Manual
  final isVoiceMode = true.obs;

  // Aktivitas Harian
  final sleepHours = 7.0.obs;

  final RxnInt sleepQuality = RxnInt();
  final RxnInt physicalActivity = RxnInt();
  final RxnInt socialInteraction = RxnInt();
  final RxnInt productivity = RxnInt();

  final RxList<int?> phqAnswers =
    List<int?>.filled(5, null).obs;

final RxList<int?> gadAnswers =
    List<int?>.filled(5, null).obs;

final RxList<int?> stressAnswers =
    List<int?>.filled(5, null).obs;

  final AssessmentProvider _assessmentProvider =
      AssessmentProvider();

  void switchMode(bool voice) {
    isVoiceMode.value = voice;
  }

  Future<Map<String, dynamic>> submitAssessment() async {

  final phq = phqAnswers.map((e) => e ?? 0).toList();
  final gad = gadAnswers.map((e) => e ?? 0).toList();
  final stress = stressAnswers.map((e) => e ?? 0).toList();

  print("PHQ KIRIM: $phq");
  print("GAD KIRIM: $gad");
  print("STRESS KIRIM: $stress");

  return await _assessmentProvider.submitAssessment(
    phqAnswers: phq,
    gadAnswers: gad,
    stressAnswers: stress,
    sleepHours: sleepHours.value,
    sleepQuality: sleepQuality.value!,
    physicalActivity: physicalActivity.value!,
    socialInteraction: socialInteraction.value!,
    productivity: productivity.value!,
  );
}
}