import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class JournalListView extends StatefulWidget {
  const JournalListView({super.key});

  @override
  State<JournalListView> createState() => _JournalListViewState();
}

class _JournalListViewState extends State<JournalListView> {
  late Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box('journals');
  }

  // Helper untuk mengubah string ISO8601 menjadi tanggal yang manis dibaca tanpa package tambahan
  String _formatReadableDate(String? dateStr) {
    if (dateStr == null) return "";
    final date = DateTime.tryParse(dateStr);
    if (date == null) return "";
    
    final months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", 
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  // Dialog konfirmasi hapus agar tidak sengaja terhapus
  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Jurnal?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Cerita momen ini akan dihapus permanen dari memori aplikasimu."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                box.deleteAt(box.length - 1 - index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Jurnal telah dihapus"),
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                ),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Dialog membaca jurnal dengan tampilan layout seperti lembar catatan premium
  void _showReadDialog(BuildContext context, Map item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E66E7).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(item["mood"] ?? "😊", style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"] ?? "Tanpa Judul",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatReadableDate(item["date"]),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4, // Batasi tinggi teks panjang agar bisa di-scroll
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    item["content"] ?? "",
                    style: TextStyle(
                      fontSize: 15, 
                      height: 1.6, 
                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E66E7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Selesai Membaca", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final journals = box.values.toList().reversed.toList();

    // Tema Warna Adaptif
    const primaryBlue = Color(0xFF2E66E7);
    final scaffoldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          "Jurnal Kamu",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      
      body: journals.isEmpty
          // --- PREMIUM EMPTY STATE ---
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_rounded, 
                      size: 72, 
                      color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade300
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Lembar Jurnal Masih Kosong",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Mulai rekam jejak pikiran, emosi, dan momen baikmu hari ini.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, 
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        height: 1.4
                      ),
                    ),
                  ],
                ),
              ),
            )
          // --- MODERN FEED LIST ---
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: journals.length,
              itemBuilder: (context, index) {
                final item = journals[index] as Map;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _showReadDialog(context, item),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lingkaran wadah mood penanda emosi
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                item["mood"] ?? "😊",
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(width: 14),
                            
                            // Konten teks judul dan sub-isi jurnal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item["title"] ?? "-",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatReadableDate(item["date"]),
                                        style: TextStyle(
                                          fontSize: 11, 
                                          color: isDark ? Colors.white30 : Colors.black38
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item["content"]?.toString() ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Tombol hapus dengan konfirmasi aman
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              color: Colors.redAccent.withOpacity(0.7),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _confirmDelete(context, index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}