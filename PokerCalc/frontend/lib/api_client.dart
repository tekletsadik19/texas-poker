import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://localhost:8081';

  static Future<Map<String, dynamic>> bestHand(
    List<String> hole,
    List<String> community,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hand/best'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hole': hole, 'community': community}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to evaluate best hand: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> compareHands(
    List<String> p1Hole,
    List<String> p1Comm,
    List<String> p2Hole,
    List<String> p2Comm,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hand/compare'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'player1': {'hole': p1Hole, 'community': p1Comm},
        'player2': {'hole': p2Hole, 'community': p2Comm},
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to compare hands: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> probability(
    List<String> hole,
    List<String> community,
    int numPlayers,
    int simulations,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hand/probability'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hole': hole,
        'community': community,
        'num_players': numPlayers,
        'simulations': simulations,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to calc probability: ${response.body}');
    }
  }
}
