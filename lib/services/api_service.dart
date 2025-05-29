import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ApiService {
  // Fonction de login qui interroge https://std33.beaupeyrat.com/auth avec email et password
  static Future<String?> login(String email, String password) async {
    final url = Uri.parse('https://std33.beaupeyrat.com/auth');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Login response status: ${response.statusCode}');
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // Supposons que le token JWT est dans la clé "token"
      if (responseBody is Map && responseBody.containsKey('token')) {
        return responseBody['token'] as String;
      } else {
        print('Erreur: clé "token" manquante dans la réponse JSON');
        return null;
      }
    } else {
      print('Erreur de login: ${response.statusCode}');
      return null;
    }
  }

  // Nouvelle méthode pour récupérer les corps célestes
  static Future<List<Map<String, dynamic>>> fetchCelestialBodies() async {
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('https://std33.beaupeyrat.com/api/celestial_bodies'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Utilise la clé 'member' pour accéder à la liste
        final List<dynamic> bodies = data['member'] ?? [];
        return List<Map<String, dynamic>>.from(bodies);
      } else {
        throw Exception('Failed to load celestial bodies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching celestial bodies: $e');
    }
  }

  static Future<String> fetchCelestialBodyTypeName(String typeUrl) async {
    final token = await TokenService.getToken();
    final url = Uri.parse('https://std33.beaupeyrat.com/api/celestial_body_types');
    final response = await http.get(url, headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token',});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'] ?? 'Type inconnu';
    } else {
      return 'Type inconnu';
    }
  }
}