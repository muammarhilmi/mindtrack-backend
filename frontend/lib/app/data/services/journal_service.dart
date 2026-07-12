import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/network_config.dart';
import '../models/journal_model.dart';

class JournalService {
  Future<void> createJournal(JournalModel journal) async {
    final response = await http.post(
      Uri.parse("${NetworkConfig.baseUrl}/journal"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(journal.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<List<JournalModel>> getJournal(String userId) async {
    final response = await http.get(
      Uri.parse("${NetworkConfig.baseUrl}/journal/$userId"),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final List data = jsonDecode(response.body);

    return data
        .map((e) => JournalModel.fromJson(e))
        .toList();
  }

  Future<void> deleteJournal(String id) async {
    final response = await http.delete(
      Uri.parse("${NetworkConfig.baseUrl}/journal/$id"),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}