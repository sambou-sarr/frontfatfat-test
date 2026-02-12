import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // ⚠️ Utilisez "http://10.0.2.2:8000/api" pour l'émulateur Android
  // ⚠️ Utilisez "http://localhost:8000/api" pour Flutter Web ou iOS
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // --- RÉCUPÉRATION DU TOKEN ---
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ---------------------------------------------------------
  // 1. AUTHENTIFICATION (Login & Register)
  // ---------------------------------------------------------

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    } catch (e) {
      return {
        'status': 500,
        'body': {'message': 'Erreur de connexion serveur'},
      };
    }
  }

  static Future<Map<String, dynamic>> login(
    String telephone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"telephone": telephone, "password": password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', responseData['token']);
      // On stocke aussi l'ID pour les appels futurs comme l'historique
      await prefs.setString('user_id', responseData['user']['id'].toString());
    }
    return {"status": response.statusCode, "body": responseData};
  }

  // ---------------------------------------------------------
  // 2. CLIENT : COMMANDES & ESTIMATION
  // ---------------------------------------------------------

  static Future<Map<String, dynamic>> getUserInfo() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return {'status': response.statusCode, 'body': jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> getUserInfol() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/userl'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return {'status': response.statusCode, 'body': jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> estimerPrix(
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/client/estimate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    } catch (e) {
      return {
        'status': 500,
        'body': {'message': 'Erreur estimation'},
      };
    }
  }

  static Future<Map<String, dynamic>> createMission(
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/client/commandes'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return {'status': response.statusCode, 'body': jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> getUserMissions(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return {'status': 401, 'message': 'Non authentifié'};

      final response = await http.get(
        Uri.parse('$baseUrl/client/historique/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // On décode le JSON
      final decodedBody = jsonDecode(response.body);

      return {'status': response.statusCode, 'body': decodedBody};
    } catch (e) {
      print("Erreur fatale API : $e");
      return {'status': 500, 'message': e.toString()};
    }
  }

  // ---------------------------------------------------------
  // 3. LIVREUR : GESTION DES MISSIONS
  // ---------------------------------------------------------

  static Future<Map<String, dynamic>> toggleAvailability() async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/livreur/disponibilite'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return {'status': response.statusCode, 'body': jsonDecode(response.body)};
  }

  static Future<List<dynamic>> getAvailableMissions() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/livreur/commandes-disponibles'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['commandes'] ?? [];
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  static Future<bool> acceptMission(int id) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/livreur/accepter-commande/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> confirmerLivraison(
    int commandeId,
    String codeOtp,
  ) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/livreur/confirmer-livraison/$commandeId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'code_otp': codeOtp}),
    );
    return jsonDecode(response.body);
  }

  // ---------------------------------------------------------
  // 4. OUTILS (GÉO-CODAGE)
  // ---------------------------------------------------------

  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1',
        ),
        headers: {'User-Agent': 'FatFat_App_Dakar'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lng': double.parse(data[0]['lon']),
          };
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
