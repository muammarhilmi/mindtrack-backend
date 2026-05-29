import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilController extends GetxController {
  final nameController = TextEditingController(text: "Rudi asli Jombang");
  final emailController = TextEditingController(text: "rudijom@example.com");
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  var selectedGender = "Bisox".obs; // Sesuaikan typo di gambar: Bisox/Pria/Wanita
  var selectedTheme = "Terang".obs;
}