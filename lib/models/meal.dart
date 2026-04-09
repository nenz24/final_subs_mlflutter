class Meal {
  final String idMeal;
  final String strMeal;
  final String? strMealThumb;
  final String? strInstructions;
  final String? strCategory;
  final String? strArea;
  final List<MapEntry<String, String>> ingredients;

  Meal({
    required this.idMeal,
    required this.strMeal,
    this.strMealThumb,
    this.strInstructions,
    this.strCategory,
    this.strArea,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <MapEntry<String, String>>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;

      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(MapEntry(
          ingredient.trim(),
          measure?.trim() ?? '',
        ));
      }
    }

    return Meal(
      idMeal: json['idMeal'] as String,
      strMeal: json['strMeal'] as String,
      strMealThumb: json['strMealThumb'] as String?,
      strInstructions: json['strInstructions'] as String?,
      strCategory: json['strCategory'] as String?,
      strArea: json['strArea'] as String?,
      ingredients: ingredients,
    );
  }
}
