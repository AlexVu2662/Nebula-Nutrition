import 'dart:convert';
import 'package:http/http.dart' as http;
import 'food.dart';

class ApiService{
  static const String _url = 'https://api.calorieninjas.com/v1/nutrition?query=';
  static const String _key = 'TN5Fst1OVikhrrl8hFZ9MQ==CfqYaBGcPC9Xhz7v';

  Future<List<Food>> fetchNutrition(String query) async {
    final response = await http.get(
      Uri.parse('$_url$query'),
      headers: {
        'X-Api-Key': _key,
      },
    );
    if(response.statusCode == 200){
      final jsonData = jsonDecode(response.body);
      final List<dynamic> items = jsonData['items'];
      return items.map((item) => Food.fromJson(item)).toList();
    } else{
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}