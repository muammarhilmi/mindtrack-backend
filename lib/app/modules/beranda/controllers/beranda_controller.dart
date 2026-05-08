import 'package:get/get.dart';

class BerandaController extends GetxController {
  // Contoh data reaktif
  final userName = "Budi".obs;
  final weeklyProgress = 0.85.obs; // 85%
  
  // Data simulasi untuk grid relaksasi
  final relaxationItems = [
    {'title': 'Nafas Pagi', 'time': '5 Menit', 'type': 'Menenangkan'},
    {'title': 'Alunan Lembut', 'time': '12 Menit', 'type': 'Fokus'},
    {'title': 'Hutan Pinus', 'time': '15 Menit', 'type': 'Tidur'},
    {'title': 'Sore Tenang', 'time': '8 Menit', 'type': 'Rileks'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }
}