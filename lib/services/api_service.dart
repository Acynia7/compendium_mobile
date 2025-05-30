import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
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

  static Future<Map<String, dynamic>?> fetchUserDetails(String token) async {
    try {
      final decodedToken = Jwt.parseJwt(token);
      final String? email = decodedToken['email']?.toString();

      if (email == null) {
        throw Exception('Email not found in token');
      }

      // Appel à l'API avec l'email en paramètre de requête
      final response = await http.get(
        Uri.parse('https://std33.beaupeyrat.com/api/users?email=$email'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Si la réponse est une liste, prends le premier utilisateur correspondant
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        } else if (data is Map && data.containsKey('member')) {
          // Si c'est une collection Hydra
          final members = data['member'];
          if (members is List && members.isNotEmpty) {
            return members[0] as Map<String, dynamic>;
          }
        }
        return null;
      } else if (response.statusCode == 404) {
        throw Exception('User not found for email $email');
      } else {
        throw Exception('Error fetching user details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching user details: $e');
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

  static Future<bool> addToFavorites(int celestialBodyId) async {
    try {
      print('[addToFavorites] Démarrage de la méthode');
      final token = await TokenService.getToken();
      print('[addToFavorites] Token récupéré : $token');
      if (token == null) throw Exception('Token non disponible');

      // Récupère les infos utilisateur pour obtenir l'IRI de l'utilisateur
      final userDetails = await fetchUserDetails(token);
      print('[addToFavorites] userDetails : $userDetails');
      if (userDetails == null || userDetails['@id'] == null) {
        throw Exception('Impossible de récupérer l\'utilisateur courant');
      }
      final userIri = userDetails['@id'];
      print('[addToFavorites] userIri : $userIri');

      final url = Uri.parse('https://std33.beaupeyrat.com/api/favorites');
      print('[addToFavorites] URL POST : $url');
      final body = {
        "celestialBodies": "/api/celestial_bodies/$celestialBodyId",
        "user": userIri,
        "createdAt": DateTime.now().toIso8601String(),
      };
      print('[addToFavorites] Body envoyé : $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/ld+json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('[addToFavorites] StatusCode : ${response.statusCode}');
      print('[addToFavorites] Response body : ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[addToFavorites] Succès de l\'ajout aux favoris');
        return true;
      } else {
        print('[addToFavorites] Erreur n°1 : ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('[addToFavorites] Exception : $e');
      return false;
    }
  }

  // Nouvelle méthode pour récupérer un favori par son IRI
  static Future<Map<String, dynamic>?> fetchFavoriteByIri(String iri, String token) async {
    final url = Uri.parse('https://std33.beaupeyrat.com$iri');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/ld+json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
}