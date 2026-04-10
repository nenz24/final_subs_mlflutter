import 'package:flutter/material.dart';
import 'package:project/models/meal.dart';

class DetailScreen extends StatelessWidget {
  final Meal meal;

  const DetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0F1923),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (meal.strMealThumb != null)
                    Image.network(
                      meal.strMealThumb!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF162231),
                        child: const Center(
                          child: Icon(Icons.restaurant, size: 60, color: Colors.white24),
                        ),
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0F1923).withValues(alpha: 0.8),
                          const Color(0xFF0F1923),
                        ],
                        stops: const [0.3, 0.75, 1.0],
                      ),
                    ),
                  ),
                  // Title at bottom
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.strMeal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        if (meal.strCategory != null || meal.strArea != null) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (meal.strCategory != null)
                                _buildChip(meal.strCategory!, Icons.category_outlined),
                              if (meal.strArea != null)
                                _buildChip(meal.strArea!, Icons.public),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients section
                  _buildSectionHeader('Ingredients', Icons.shopping_basket_outlined),
                  const SizedBox(height: 14),
                  _buildIngredientsGrid(),

                  const SizedBox(height: 28),

                  // Instructions section
                  _buildSectionHeader('Instructions', Icons.receipt_long_outlined),
                  const SizedBox(height: 14),
                  _buildInstructionsCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9373).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0D9373).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF0D9373)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF0D9373),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9373).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0D9373), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsGrid() {
    if (meal.ingredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF162231),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'No ingredients available',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF162231),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: meal.ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          final isLast = index == meal.ingredients.length - 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0D9373).withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 12),
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
                    style: TextStyle(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF162231),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        meal.strInstructions ?? 'No instructions available',
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
          height: 1.8,
        ),
      ),
    );
  }
}
