import 'package:get/get.dart';

import '../controllers/breathing_controller.dart';

class BreathingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BreathingController>(
      () => BreathingController(),
    );
  }
}
