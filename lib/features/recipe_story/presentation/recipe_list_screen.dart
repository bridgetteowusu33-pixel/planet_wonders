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
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded, size: 22),
            tooltip: 'My Recipe Book',
            onPressed: () => context.push('/recipe-album'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                child: Row(
                  children: [
                    const Text('\u{1F468}\u{200D}\u{1F373}',
                        style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choose a recipe story and cook step by step!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
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
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _RecipeCard(
                          recipe: recipe,
                          index: index,
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

class _RecipeCard extends StatefulWidget {
  const _RecipeCard({
    required this.recipe,
    required this.index,
    required this.onTap,
  });

  final RecipeStory recipe;
  final int index;
  final VoidCallback onTap;

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final delay = widget.index * 0.15;
    final begin = delay.clamp(0.0, 0.6);
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, 1.0, curve: Curves.easeOutCubic),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(curve);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _difficultyColor(widget.recipe.safeDifficulty);

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: PWColors.navy.withValues(alpha: 0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: diffColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final dpr = MediaQuery.of(context).devicePixelRatio;
                            final cacheWidth = math.max(
                                256,
                                math.min(1024,
                                    (constraints.maxWidth * dpr).round()));
                            return Image.asset(
                              widget.recipe.thumbnailAsset ??
                                  widget.recipe.imageAsset,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              cacheWidth: cacheWidth,
                              filterQuality: FilterQuality.low,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: diffColor.withValues(alpha: 0.1),
                                child: Center(
                                  child: Text(
                                    widget.recipe.emoji,
                                    style: const TextStyle(fontSize: 56),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Difficulty badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: diffColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: diffColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(
                                widget.recipe.safeDifficulty,
                                (_) => const Text('\u{2B50}',
                                    style: TextStyle(fontSize: 10)),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.recipe.difficultyLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Gradient overlay at bottom of image
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Accent strip
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        diffColor.withValues(alpha: 0.6),
                        diffColor,
                        diffColor.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    children: [
                      Text(
                        '${widget.recipe.emoji} ${widget.recipe.title}',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.recipe.steps.length} steps',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: PWColors.navy.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(int difficulty) {
    return switch (difficulty) {
      1 => PWColors.mint,
      2 => PWColors.yellow,
      _ => PWColors.coral,
    };
  }
}
