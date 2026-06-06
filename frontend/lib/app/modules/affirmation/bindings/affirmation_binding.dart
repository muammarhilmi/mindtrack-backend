import 'package:get/get.dart';

import '../controllers/affirmation_controller.dart';

class AffirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AffirmationController>(
      () => AffirmationController(),
    );
  }
}
