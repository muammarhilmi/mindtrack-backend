import 'package:flutter/material.dart';
import 'journal_list_view.dart';
import 'package:capstone/app/data/models/journal_model.dart';
import 'package:capstone/app/data/services/journal_service.dart';
import 'package:get/get.dart';
import 'package:capstone/app/core/controllers/global_auth_controller.dart';
import 'package:capstone/app/modules/beranda/controllers/beranda_controller.dart'; // ⬅️ sesuaikan path sesuai struktur foldermu

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  final JournalService journalService = JournalService();

  final GlobalAuthController authController =
      Get.find<GlobalAuthController>();

  bool isSaving = false;

  final TextEditingController controller = TextEditingController();

  String selectedMood = "😊";

  final moods = ["😊", "😌", "😔", "😢", "😡"];
  final guideTexts = [
    "Bagaimana hari kamu hari ini?",
    "Apa yang kamu rasakan sekarang?",
    "Apakah ada hal yang mengganggu pikiranmu?",
    "Apa hal baik yang terjadi hari ini?",
  ];

  String guideText = "";

  @override
  void initState() {
    super.initState();
    guideText = guideTexts.first;
  }

  Future<void> saveJournal() async {
  final text = controller.text.trim();

  if (text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Jurnal tidak boleh kosong"),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final user = authController.currentUser.value;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Silakan login terlebih dahulu"),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() {
    isSaving = true;
  });

  try {
    final journal = JournalModel(
      userId: user.id,
      title:
          "Jurnal ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      content: text,
      mood: selectedMood,
      createdAt: DateTime.now(),
    );

    await journalService.createJournal(journal);
    if (Get.isRegistered<BerandaController>()) {
      Get.find<BerandaController>().fetchJournals();
    }

    controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✨ Jurnal berhasil disimpan"),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  } finally {
    setState(() {
      isSaving = false;
    });
  }
}

  void openList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const JournalListView(),
      ),
    );
  }

  void changeGuide() {
    setState(() {
      guideText = (guideTexts..shuffle()).first;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Palet Warna Adaptif
    const primaryBlue = Color(0xFF2E66E7);
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final promptBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEAF0FF);

    return Scaffold(
      backgroundColor: scaffoldBg,
      
      // --- APP BAR CLEAN LOOK ---
      appBar: AppBar(
        title: const Text(
          "Jurnal Harian",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Pindahan tombol "Jurnal Kamu" ke atas dengan ikon premium
          IconButton(
            icon: const Icon(Icons.auto_stories_rounded, color: Colors.white),
            tooltip: "Riwayat Jurnal",
            onPressed: openList,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- WRITING PROMPT / GUIDE ---
            GestureDetector(
              onTap: changeGuide,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: promptBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryBlue.withOpacity(isDark ? 0.3 : 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: primaryBlue, size: 22), // Alternatif menggunakan Icons.lightbulb_rounded jika error
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        guideText,
                        style: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1E3A8A),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.refresh_rounded, 
                      color: primaryBlue.withOpacity(0.6), 
                      size: 18
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- MOOD PICKER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Bagaimana perasaanmu saat ini?",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: moods.map((m) {
                      final isSelected = selectedMood == m;

                      return GestureDetector(
                        onTap: () => setState(() => selectedMood = m),
                        child: SizedBox(
                          // 🛠️ PERBAIKAN 1: Bounding box statis agar antar-item punya ruang aman & tidak saling tumpuk
                          width: 60,
                          height: 60,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              // 🛠️ PERBAIKAN 2: Mengubah ukuran lingkaran via width & height secara dinamis (menggantikan transform)
                              width: isSelected ? 56 : 44,
                              height: isSelected ? 56 : 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryBlue
                                    : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                                shape: BoxShape.circle,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primaryBlue.withOpacity(0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              // 🛠️ PERBAIKAN 3: Membuat ukuran emojinya ikut membesar dengan halus saat terpilih
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  fontSize: isSelected ? 26 : 20,
                                ),
                                child: Text(m),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- MINIMAL NOTEBOOK INPUT ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: "Mulai tuangkan ceritamu di sini...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none, // Hilangkan border luar kaku
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveJournal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: primaryBlue.withOpacity(0.3),
                ),
                child: isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded),
                        SizedBox(width: 8),
                        Text(
                          "Simpan Jurnal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}