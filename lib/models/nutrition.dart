class Nutrition {
  final int calories;
  final int carbs;
  final int fat;
  final int fiber;
  final int protein;

  Nutrition({
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.protein,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    final nutrition = json['nutrition'] as Map<String, dynamic>? ?? json;
    return Nutrition(
      calories: (nutrition['calories'] as num?)?.toInt() ?? 0,
      carbs: (nutrition['carbs'] as num?)?.toInt() ?? 0,
      fat: (nutrition['fat'] as num?)?.toInt() ?? 0,
      fiber: (nutrition['fiber'] as num?)?.toInt() ?? 0,
      protein: (nutrition['protein'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'protein': protein,
      };
}
