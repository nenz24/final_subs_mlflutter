import 'package:flutter/material.dart';
import 'package:project/models/meal.dart';

class DetailScreen extends StatelessWidget {
  final Meal meal;

  const DetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.strMeal),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image
            if (meal.strMealThumb != null)
              Image.network(
                meal.strMealThumb!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: const Color(0xFF16213E),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 60,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Area
                  if (meal.strCategory != null || meal.strArea != null)
                    Wrap(
                      spacing: 8,
                      children: [
                        if (meal.strCategory != null)
                          _buildTag(meal.strCategory!, Colors.blue.shade700),
                        if (meal.strArea != null)
                          _buildTag(meal.strArea!, Colors.purple.shade700),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Ingredients section
                  _buildSectionTitle('Ingredients'),
                  const SizedBox(height: 12),
                  _buildIngredientsTable(),

                  const SizedBox(height: 24),

                  // Instructions section
                  _buildSectionTitle('Instructions'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      meal.strInstructions ?? 'No instructions available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withValues(alpha: 1.0),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildIngredientsTable() {
    if (meal.ingredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No ingredients available',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF0F3460),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Ingredient',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Measure',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ...meal.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: index < meal.ingredients.length - 1
                      ? BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        )
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      ingredient.key,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      ingredient.value,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
