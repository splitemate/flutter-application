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
            print('FirebaseConfig: Web Client ID found: $_webClientId');
            break;
          }
        }
        if (_webClientId != null) break;
      }

      // Extract project ID
      _projectId = jsonData['project_info']['project_id'] as String;
      print('FirebaseConfig: Project ID found: $_projectId');
      
      if (_webClientId == null) {
        print('FirebaseConfig: Warning - No web client ID found in google-services.json');
        print('FirebaseConfig: Available clients: ${clients.length}');
        for (var client in clients) {
          if (client['oauth_client'] != null) {
            final oauthClients = client['oauth_client'] as List;
            print('FirebaseConfig: Client has ${oauthClients.length} OAuth clients');
            for (var oauthClient in oauthClients) {
              print('FirebaseConfig: OAuth client type: ${oauthClient['client_type']}');
            }
          }
        }
      }
    } catch (e) {
      print('FirebaseConfig: Error loading Firebase config: $e');
      print('FirebaseConfig: Make sure google-services.json is properly placed in assets/');
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
