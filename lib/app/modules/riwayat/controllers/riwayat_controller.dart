import 'package:get/get.dart';

class RiwayatController extends GetxController {
  final historyData = [
    {
      'month': 'Agustus 2023',
      'items': [
        {'date': 'Thursday, 23 Nov', 'mood': 'Sangat Baik', 'icon': '😊'},
        {'date': 'Monday, 12 Nov', 'mood': 'Cukup Tenang', 'icon': '😌'},
      ]
    },
    {
      'month': 'November 2023',
      'items': [
        {'date': 'Thursday, 23 Nov', 'mood': 'Sangat Baik', 'icon': '😊'},
        {'date': 'Monday, 12 Nov', 'mood': 'Cukup Tenang', 'icon': '😌'},
      ]
    }
  ].obs;
}