import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatbotController extends GetxController {
  final textController = TextEditingController();
  final scrollController = ScrollController();

  // Data pesan sementara menggunakan Map
  final messages = <Map<String, dynamic>>[
    {'text': "Hello, Alex.", 'isSender': false},
    {'text': "I'm here to support your emotional journey today. How are you feeling in this moment?", 'isSender': false},
    {'text': "Khatam berbagai cobaan", 'isSender': false},
    {'text': "Selalu menertawakan ramalan bintang kartu tarot", 'isSender': true},
    {'text': "Orang pintar pembaca nasib", 'isSender': false},
    {'text': "Namun aku bingung kenapa ku tak pergi", 'isSender': true},
    {'text': "Aku bingung kalian masih disini", 'isSender': false},
  ].obs;

  void sendMessage() {
    if (textController.text.trim().isNotEmpty) {
      messages.add({
        'text': textController.text,
        'isSender': true,
      });
      textController.clear();

      // Efek scroll ke paling bawah setelah kirim pesan
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}