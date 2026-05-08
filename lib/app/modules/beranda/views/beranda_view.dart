import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/beranda_controller.dart';

class BerandaView extends GetView<BerandaController> {
  const BerandaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 20),
            _buildSummaryCard(),
            const SizedBox(height: 25),
            _buildWeeklyTrend(),
            const SizedBox(height: 25),
            _buildArticleSection(),
            const SizedBox(height: 25),
            _buildQuickRelaxationGrid(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- Widget Components ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2E66E7),
      title: const Text('MindTrack', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 15),
          child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF2E66E7))),
        )
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text('Selamat pagi, ${controller.userName.value}', 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B434D)))),
        const SizedBox(height: 8),
        const Text('Mari kita luangkan waktu sejenak untuk bernapas dan memulai hari dengan ketenangan.',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ringkasan Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Text('Senin, 22 Mei', style: TextStyle(fontSize: 10)),
              )
            ],
          ),
          const SizedBox(height: 15),
          _summaryTile(Icons.sentiment_satisfied_alt, "SUASANA HATI", "Sangat Tenang", Colors.green.shade50),
          const SizedBox(height: 10),
          _summaryTile(Icons.nights_stay, "KUALITAS TIDUR", "7.1 Jam", Colors.blue.shade50),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kemajuan Mingguan', style: TextStyle(fontSize: 11)),
              Obx(() => Text('${(controller.weeklyProgress.value * 100).toInt()}%', style: const TextStyle(fontSize: 11))),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Obx(() => LinearProgressIndicator(
              value: controller.weeklyProgress.value,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF1B434D),
              minHeight: 8,
            )),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(IconData icon, String title, String value, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeeklyTrend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weekly Trend', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(child: Icon(Icons.show_chart, size: 50, color: Colors.blueGrey)),
        )
      ],
    );
  }

  Widget _buildArticleSection() {
    return Column(
      children: [
        _articleCard("Morning Meditation", "Take 10 minutes to focus...", const Color(0xFFE3F2FD), Icons.wb_sunny_outlined),
        const SizedBox(height: 10),
        _articleCard("Evening Walk", "A gentle 20-minute walk...", const Color(0xFFE8F5E9), Icons.directions_walk),
      ],
    );
  }

  Widget _articleCard(String title, String desc, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              CircleAvatar(backgroundColor: Colors.white, child: Icon(icon, size: 20)),
            ],
          ),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, 
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
            ),
            child: const Text('Baca selengkapnya', style: TextStyle(fontSize: 11)),
          )
        ],
      ),
    );
  }

  Widget _buildQuickRelaxationGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Relaksasi Cepat', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Lihat Semua', style: TextStyle(fontSize: 12))),
          ],
        ),
        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.relaxationItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8
          ),
          itemBuilder: (context, index) {
            var item = controller.relaxationItems[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(image: NetworkImage("https://picsum.photos/200"), fit: BoxFit.cover)
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("${item['time']} • ${item['type']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            );
          },
        )),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E66E7),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Konsultasi'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chatbot'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
      ],
    );
  }
}