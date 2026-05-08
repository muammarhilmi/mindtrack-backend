import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E66E7),
        elevation: 0,
        title: const Text('MindTrack', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("History", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B434D))),
            const Text("Your journey towards peace and clarity, archived for your reflection.", 
              style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.historyData.length,
              itemBuilder: (context, index) {
                var section = controller.historyData[index];
                return Column(
                  children: [
                    _buildMonthSeparator(section['month'] as String),
                    ...(section['items'] as List).map((item) => _buildHistoryCard(item)).toList(),
                  ],
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSeparator(String month) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(month, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: Text(item['icon']),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['date'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.green),
                    const SizedBox(width: 5),
                    Text(item['mood'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Row(
              children: [
                Text("RESULTS", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          )
        ],
      ),
    );
  }
}