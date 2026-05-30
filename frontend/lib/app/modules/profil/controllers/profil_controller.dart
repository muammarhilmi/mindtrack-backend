import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/global_auth_controller.dart';
import '../../../routes/app_pages.dart';

class ProfilController extends GetxController {

  final GlobalAuthController auth =
      Get.find<GlobalAuthController>();

  late TextEditingController
      nameController;

  late TextEditingController
      emailController;

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  RxString selectedGender =
      "Belum dipilih".obs;

  RxString selectedTheme =
      "Terang".obs;

  @override
  void onInit() {
    super.onInit();

    final user =
        auth.currentUser.value;

    nameController =
        TextEditingController(
      text: user?.name ?? "",
    );

    emailController =
        TextEditingController(
      text: user?.email ?? "",
    );

    String gender = user?.gender ?? "Belum dipilih";
    if (!["Belum dipilih", "Pria", "Wanita", "Lainnya"].contains(gender)) {
      gender = "Belum dipilih";
    }
    selectedGender.value = gender;

    selectedTheme.value =
        user?.theme == "dark"
            ? "Gelap"
            : "Terang";
  }

  Future<void> saveProfile() async {
    try {
      if (passwordController.text.isNotEmpty &&
          passwordController.text != confirmPasswordController.text) {
        Get.snackbar("Error", "Password tidak sama");
        return;
      }

      await auth.updateProfile(
        name: nameController.text,
        email: emailController.text,
        gender: selectedGender.value,
        password: passwordController.text.isEmpty
            ? null
            : passwordController.text,
      );

      Get.snackbar("Berhasil", "Profile diperbarui");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> logout()
  async {

    await auth.logout();

    Get.offAllNamed(
      Routes.AUTH,
    );
  }
}