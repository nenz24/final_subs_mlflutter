import 'package:flutter/material.dart';
import 'package:project/models/nutrition.dart';

class NutritionCard extends StatelessWidget {
  final Nutrition nutrition;

  const NutritionCard({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF162231),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // Calorie row — highlighted
          _buildCalorieRow(),
          const SizedBox(height: 20),
          // Macro nutrients grid
          Row(
            children: [
              Expanded(
                child: _buildNutrientCircle(
                  'Carbs',
                  '${nutrition.carbs}g',
                  nutrition.carbs.toDouble(),
                  const Color(0xFF06B6D4),
                ),
              ),
              Expanded(
                child: _buildNutrientCircle(
                  'Protein',
                  '${nutrition.protein}g',
                  nutrition.protein.toDouble(),
                  const Color(0xFF0D9373),
                ),
              ),
              Expanded(
                child: _buildNutrientCircle(
                  'Fat',
                  '${nutrition.fat}g',
                  nutrition.fat.toDouble(),
                  const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildNutrientCircle(
                  'Fiber',
                  '${nutrition.fiber}g',
                  nutrition.fiber.toDouble(),
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D9373).withValues(alpha: 0.15),
            const Color(0xFF06B6D4).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0D9373).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9373).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Calories',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${nutrition.calories}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'kkal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCircle(
    String label,
    String value,
    double rawValue,
    Color color,
  ) {
    // Normalize to 0-1 range (max ~200g for display purposes)
    final progress = (rawValue / 200).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4,
                  color: color.withValues(alpha: 0.12),
                ),
              ),
              // Progress ring
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Value
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
