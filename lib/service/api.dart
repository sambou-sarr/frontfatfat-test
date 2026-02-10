import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // ⚠️ Utilisez 10.0.2.2 au lieu de 127.0.0.1 si vous testez sur un émulateur Android
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Récupération centralisée du Token pour éviter les erreurs 401
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ------------------------------
  // 1. INSCRIPTION (MÉTHODE RÉINTÉGRÉE)
  // ------------------------------
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

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return {'status': response.statusCode, 'body': responseBody};
    } catch (e) {
      return {
        'status': 500,
        'body': {'message': 'Impossible de contacter le serveur : $e'},
      };
    }
  }

  // ------------------------------
  // 2. CONNEXION
  // ------------------------------
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

    // Sauvegarde du token pour les prochaines requêtes (Sanctum)
    if (response.statusCode == 200 && responseData['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', responseData['token']);
    }

    return {"status": response.statusCode, "body": responseData};
  }

  // ------------------------------
  // 3. INFOS UTILISATEUR & PROFIL
  // ------------------------------
  static Future<Map<String, dynamic>> getUserInfo() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    } catch (e) {
      return {
        'status': 500,
        'body': {'message': 'Erreur réseau'},
      };
    }
  }

  // ------------------------------
  // 4. ESTIMATION DU PRIX (INDISPENSABLE POUR LE MÉMOIRE)
  // ------------------------------
  static Future<Map<String, dynamic>> estimerPrix(
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();

    if (token == null) {
      return {
        'status': 401,
        'body': {'message': 'Utilisateur non authentifié'},
      };
    }

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

      final responseBody = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;

      return {'status': response.statusCode, 'body': responseBody};
    } catch (e) {
      return {
        'status': 500,
        'body': {'message': 'Erreur serveur estimation', 'error': e.toString()},
      };
    }
  }

  // ------------------------------
  // 5. CRÉATION DE
  // ------------------------------
  static Future<Map<String, dynamic>> createMission(
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    try {
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
    } catch (e) {
      return {
        'status': 500,
        'body': {'message': 'Erreur réseau'},
      };
    }
  }

  // ------------------------------
  // 6. GÉO-CODAGE (POUR LA CARTE)
  // ------------------------------
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1',
        ),
        headers: {'User-Agent': 'FatFat_App_Senegal'},
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
      print("Erreur Geocoding: $e");
    }
    return null;
  }
  // Ajoutez ceci dans votre classe Api existante

  // ... vos méthodes existantes (login, getUserInfo, etc.) ...

  // 1. CHANGER LA DISPONIBILITÉ
  static Future<Map<String, dynamic>> toggleAvailability() async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/livreur/disponibilite',
        ), // Assurez-vous que la route existe dans api.php
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    } catch (e) {
      return {
        'status': 500,
        'body': {'message': 'Erreur réseau'},
      };
    }
  }

  // 2. RÉCUPÉRER LES COMMANDES DISPONIBLES
  static Future<List<dynamic>> getAvailableMissions() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/livreur/commandes-disponibles'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['commandes'] ?? []; // Retourne la liste ou une liste vide
      }
    } catch (e) {
      print("Erreur fetch missions: $e");
    }
    return [];
  }

  // 3. ACCEPTER UNE COMMANDE
  static Future<bool> acceptMission(int id) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/livreur/accepter-commande/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- CETTE MÉTHODE DOIT ÊTRE À L'INTÉRIEUR DE LA CLASSE API ---
  static Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Récupère l'ID stocké lors du login.
    // Si nul, retourne une chaîne vide.
    return prefs.getString('user_id') ?? '';
  }

  // ✅ CORRECT : Pas d'argument entre les parenthèses
  static Future<Map<String, dynamic>> getUserMissions(int id) async {
    try {
      final token = await _getToken();

      // On utilise l'id passé en paramètre pour construire l'URL
      final response = await http.get(
        Uri.parse('$baseUrl/client/historique/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // On décode le corps de la réponse
      final decodedBody = jsonDecode(response.body);

      return {'status': response.statusCode, 'body': decodedBody};
    } catch (e) {
      print("Erreur API getUserMissions: $e");
      return {'status': 500, 'error': e.toString()};
    }
  }

  // lib/service/api.dart

  static Future<Map<String, dynamic>> confirmerLivraison(
    int commandeId,
    String codeOtp,
  ) async {
    final token = await _getToken();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/livreur/confirmer-livraison/$commandeId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'code_otp': codeOtp, // Le code saisi par le livreur
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? "Erreur de validation",
        };
      }
    } catch (e) {
      return {'success': false, 'message': "Erreur réseau"};
    }
  }
}
