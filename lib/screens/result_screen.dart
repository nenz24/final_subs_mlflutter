import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/food_classifier_provider.dart';
import 'package:project/screens/detail_screen.dart';
import 'package:project/models/meal.dart';
import 'package:project/widgets/nutrition_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<FoodClassifierProvider>(
        builder: (context, provider, _) {
          final result = provider.classificationResult;
          if (result == null) {
            return const Center(
              child: Text(
                'No classification result',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food image
                _buildFoodImage(provider),

                const SizedBox(height: 20),

                // Food name and confidence
                _buildPredictionHeader(result.label, result.confidence),

                const SizedBox(height: 24),

                // Nutrition section
                _buildNutritionSection(provider),

                const SizedBox(height: 24),

                // MealDB references section
                _buildReferencesSection(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodImage(FoodClassifierProvider provider) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: provider.selectedImage != null
          ? Image.file(
              provider.selectedImage!,
              fit: BoxFit.cover,
            )
          : Container(color: const Color(0xFF16213E)),
    );
  }

  Widget _buildPredictionHeader(String label, double confidence) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _getConfidenceColor(confidence),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${(confidence * 100).toStringAsFixed(2)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSection(FoodClassifierProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrition Facts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (provider.isFetchingNutrition)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (provider.nutrition != null)
          NutritionCard(nutrition: provider.nutrition!)
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nutrition info not available',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReferencesSection(
    BuildContext context,
    FoodClassifierProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reference',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (provider.isFetchingMeals)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (provider.meals.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No related recipes found',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        else
          ...provider.meals.map((meal) => _buildMealCard(context, meal)),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, Meal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(meal: meal),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Meal thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: meal.strMealThumb != null
                    ? Image.network(
                        meal.strMealThumb!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: const Color(0xFF0F3460),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white54,
                          ),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFF0F3460),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white54,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              // Meal info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.strMeal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (meal.strCategory != null || meal.strArea != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        [meal.strCategory, meal.strArea]
                            .where((e) => e != null)
                            .join(' • '),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green.shade700;
    if (confidence >= 0.4) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}
