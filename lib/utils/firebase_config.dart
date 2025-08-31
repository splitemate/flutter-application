import 'dart:convert';
import 'package:flutter/services.dart';

class FirebaseConfig {
  static String? _webClientId;
  static String? _projectId;

  static Future<void> initialize() async {
    try {
      // Read the google-services.json file
      final String jsonString =
          await rootBundle.loadString('assets/google-services.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extract web client ID (client_type: 3)
      final List<dynamic> clients = jsonData['client'] as List;
      for (var client in clients) {
        final List<dynamic> oauthClients = client['oauth_client'] as List;
        for (var oauthClient in oauthClients) {
          if (oauthClient['client_type'] == 3) {
            _webClientId = oauthClient['client_id'] as String;
            break;
          }
        }
        if (_webClientId != null) break;
      }

      // Extract project ID
      _projectId = jsonData['project_info']['project_id'] as String;
    } catch (e) {
      print('Error loading Firebase config: $e');
    }
  }

  static String get webClientId {
    if (_webClientId == null) {
      throw Exception(
          'FirebaseConfig not initialized. Call FirebaseConfig.initialize() first.');
    }
    return _webClientId!;
  }

  static String get projectId {
    if (_projectId == null) {
      throw Exception(
          'FirebaseConfig not initialized. Call FirebaseConfig.initialize() first.');
    }
    return _projectId!;
  }
}
