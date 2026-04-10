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
    return Consumer<FoodClassifierProvider>(
      builder: (context, provider, _) {
        final result = provider.classificationResult;
        if (result == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Result')),
            body: const Center(
              child: Text(
                'No classification result',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: const Color(0xFF0F1923),
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (provider.selectedImage != null)
                            Image.file(
                              provider.selectedImage!,
                              fit: BoxFit.cover,
                            ),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                  const Color(0xFF0F1923),
                                ],
                                stops: const [0.3, 0.7, 1.0],
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 16,
                            left: 20,
                            right: 20,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        result.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'AI Food Detection',
                                        style: TextStyle(
                                          color:
                                              const Color(0xFF0D9373)
                                                  .withValues(alpha: 0.8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _ConfidenceRing(
                                  confidence: result.confidence,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        indicatorColor: const Color(0xFF0D9373),
                        indicatorWeight: 3,
                        labelColor: const Color(0xFF0D9373),
                        unselectedLabelColor: Colors.white54,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.restaurant_menu, size: 20),
                            text: 'Nutrition',
                          ),
                          Tab(
                            icon: Icon(Icons.menu_book, size: 20),
                            text: 'Recipes',
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _buildNutritionTab(provider),
                  _buildRecipesTab(context, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionTab(FoodClassifierProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Nutrition Facts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Estimated values powered by Gemini AI',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        if (provider.isFetchingNutrition)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: Color(0xFF0D9373),
              ),
            ),
          )
        else if (provider.nutrition != null)
          NutritionCard(nutrition: provider.nutrition!)
        else
          _buildEmptyState(
            Icons.no_food_rounded,
            'Nutrition info not available',
          ),
      ],
    );
  }

  Widget _buildRecipesTab(
    BuildContext context,
    FoodClassifierProvider provider,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Related Recipes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'From TheMealDB',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        if (provider.isFetchingMeals)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: Color(0xFF0D9373),
              ),
            ),
          )
        else if (provider.meals.isEmpty)
          _buildEmptyState(
            Icons.search_off_rounded,
            'No related recipes found',
          )
        else
          ...provider.meals.map((meal) => _buildMealCard(context, meal)),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF162231),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(meal: meal),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: meal.strMealThumb != null
                      ? Image.network(
                          meal.strMealThumb!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackThumb(),
                        )
                      : _buildFallbackThumb(),
                ),
                const SizedBox(width: 14),
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
                      if (meal.strCategory != null ||
                          meal.strArea != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (meal.strCategory != null) ...[
                              Icon(
                                Icons.category_outlined,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meal.strCategory!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (meal.strCategory != null &&
                                meal.strArea != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '·',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            if (meal.strArea != null) ...[
                              Icon(
                                Icons.public,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meal.strArea!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF0D9373).withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumb() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF0D9373).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.restaurant,
        color: const Color(0xFF0D9373).withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ConfidenceRing extends StatelessWidget {
  final double confidence;

  const _ConfidenceRing({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 4,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: confidence,
              strokeWidth: 4,
              color: _getColor(),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (confidence >= 0.7) return const Color(0xFF22C55E);
    if (confidence >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}


class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFF0F1923),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
