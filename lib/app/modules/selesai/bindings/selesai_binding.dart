import 'package:get/get.dart';

import '../controllers/selesai_controller.dart';

class SelesaiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelesaiController>(
      () => SelesaiController(),
    );
  }
}
