import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/recipe_story_repository.dart';
import '../domain/recipe.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({
    super.key,
    required this.countryId,
    this.source = 'food',
  });

  final String countryId;
  final String source;

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late final Future<List<RecipeStory>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture =
        RecipeStoryRepository.instance.loadRecipesForCountry(widget.countryId);
  }

  @override
  Widget build(BuildContext context) {
    final country = findCountryById(widget.countryId);
    final countryName = country?.name ?? _label(widget.countryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipe Stories - $countryName',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      PWColors.coral.withValues(alpha: 0.22),
                      PWColors.yellow.withValues(alpha: 0.26),
                      PWColors.mint.withValues(alpha: 0.22),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  'Choose a recipe story and cook step by step with simple actions.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<RecipeStory>>(
                  future: _recipesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Recipe stories are unavailable right now.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    }

                    final recipes = snapshot.data ?? const [];
                    if (recipes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'No recipe stories are available yet for $countryName.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      itemCount: recipes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _RecipeCard(
                          recipe: recipe,
                          onTap: () => context.push(
                            '/recipe-story/${widget.countryId}/${recipe.id}?source=${widget.source}',
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label(String id) {
    return id
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onTap,
  });

  final RecipeStory recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: PWColors.navy.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dpr = MediaQuery.of(context).devicePixelRatio;
                    final cacheWidth = math
                        .max(256, math.min(1024, (constraints.maxWidth * dpr).round()));
                    return Image.asset(
                      recipe.thumbnailAsset ?? recipe.imageAsset,
                      fit: BoxFit.cover,
                      cacheWidth: cacheWidth,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                children: [
                  Text(
                    recipe.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${'★' * recipe.safeDifficulty} ${recipe.difficultyLabel}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PWColors.navy.withValues(alpha: 0.76),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
