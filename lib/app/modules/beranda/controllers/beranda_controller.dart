import 'package:get/get.dart';
import 'package:flutter/widgets.dart'; 
import '../../../controllers/navigation_controller.dart';

class BerandaController extends GetxController {
  var userName = "Budi".obs;
  var weeklyProgress = 0.7.obs;
   @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NavigationController>().currentIndex.value = 0;
    });
  }

}