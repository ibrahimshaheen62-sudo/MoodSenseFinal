import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/emotion_api.dart';

class EmotionApi {
  // change to your backend URL
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<List<Map<String, dynamic>>> getEmotion(String text) async {
    final url = Uri.parse('$baseUrl/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'top_k': 3}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final predictions = data['predictions'] as List;

      return List<Map<String, dynamic>>.from(predictions);
    } else {
      throw Exception('Failed to fetch emotion: ${response.statusCode}');
    }
  }
}
