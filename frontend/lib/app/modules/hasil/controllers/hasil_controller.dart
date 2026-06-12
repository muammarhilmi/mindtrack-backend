import 'package:get/get.dart';

class HasilController extends GetxController {

  final phqScore = 0.obs;
  final gadScore = 0.obs;
  final stressScore = 0.obs;

  final phqLevel = ''.obs;
  final gadLevel = ''.obs;
  final stressLevel = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final data = Get.arguments ?? {};
    print("DATA HASIL:");
    print(data);

    phqScore.value =
        data["phq_score"] ?? 0;

    gadScore.value =
        data["gad_score"] ?? 0;

    stressScore.value =
        data["stress_score"] ?? 0;

    phqLevel.value =
        data["phq_level"] ?? "-";

    gadLevel.value =
        data["gad_level"] ?? "-";

    stressLevel.value =
        data["stress_level"] ?? "-";
  }
  int get totalScore =>
    phqScore.value +
    gadScore.value +
    stressScore.value;
}