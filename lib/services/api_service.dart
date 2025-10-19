import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000"; // localhost untuk emulator Android

  Future<void> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update user");
    }
  }
}
