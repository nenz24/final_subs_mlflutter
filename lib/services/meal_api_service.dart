import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/models/meal.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> searchMealByName(String name) async {
    try {
      final uri = Uri.parse('$_baseUrl/search.php?s=$name');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null || meals.isEmpty) {
          return [];
        }

        return meals
            .map((m) => Meal.fromJson(m as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Meal?> getMealById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/lookup.php?i=$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null || meals.isEmpty) {
          return null;
        }

        return Meal.fromJson(meals[0] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
