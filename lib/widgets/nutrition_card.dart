import 'package:flutter/material.dart';
import 'package:project/models/nutrition.dart';

class NutritionCard extends StatelessWidget {
  final Nutrition nutrition;

  const NutritionCard({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildNutritionRow('Calories', '${nutrition.calories}', 'kkal'),
          _buildDivider(),
          _buildNutritionRow('Carbs', '${nutrition.carbs}', 'g'),
          _buildDivider(),
          _buildNutritionRow('Fat', '${nutrition.fat}', 'g'),
          _buildDivider(),
          _buildNutritionRow('Fiber', '${nutrition.fiber}', 'g'),
          _buildDivider(),
          _buildNutritionRow('Protein', '${nutrition.protein}', 'g'),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          Text(
            '$value $unit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.08),
      height: 1,
    );
  }
}
