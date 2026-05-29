import 'package:get/get.dart';

class SelesaiController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void increment() => count.value++;
}