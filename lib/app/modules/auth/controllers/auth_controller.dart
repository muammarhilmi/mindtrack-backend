import 'package:get/get.dart';

class AuthController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;

  void login() {
    print("Email: ${email.value}");
    print("Password: ${password.value}");

    // TODO: nanti sambung ke API / Firebase
    // contoh:
    // Get.offAllNamed(Routes.BERANDA);
  }
}