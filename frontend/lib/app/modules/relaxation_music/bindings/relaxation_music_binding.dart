import 'package:get/get.dart';

import '../controllers/relaxation_music_controller.dart';

class RelaxationMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RelaxationMusicController>(
      () => RelaxationMusicController(),
    );
  }
}
