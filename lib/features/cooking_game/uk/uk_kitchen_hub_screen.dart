import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/theme/pw_theme.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../cooking_entry.dart';
import '../data/recipes_ghana.dart';
import '../models/recipe.dart';
import 'british_kitchen_painter.dart';

class UKKitchenHubScreen extends ConsumerStatefulWidget {
  const UKKitchenHubScreen({super.key, required this.source});

  final String source;

  @override
  ConsumerState<UKKitchenHubScreen> createState() => _UKKitchenHubScreenState();
}

class _UKKitchenHubScreenState extends ConsumerState<UKKitchenHubScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-GB');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.1);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  Future<void> _speak(String text) async {
    if (_speaking) {
      await _tts.stop();
      setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievements = ref.watch(achievementProvider);
    final completedKeys = achievements.completedCookingRecipes;
    final recipes = cookingRecipesForCountry('uk');

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 860;
            final crossAxisCount = isTablet ? 3 : 2;
            final horizontalPad = isTablet ? 32.0 : 16.0;

            return Stack(
              children: [
                // British kitchen background
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: const BritishKitchenPainter(),
                    ),
                  ),
                ),

                // Scrollable content
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 960.0 : 600.0,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // Back button row
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Chef greeting
                          _ChefGreeting(
                            speaking: _speaking,
                            onSpeak: () => _speak(
                              'Welcome to the British Kitchen, Little Chef! '
                              'Pick a recipe and let\u{2019}s get cooking!',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Recipe grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = recipes[index];
                              final key = 'uk::${recipe.id}';
                              final isCompleted = completedKeys.contains(key);
                              return _RecipeCard(
                                recipe: recipe,
                                isCompleted: isCompleted,
                                onTap: () => openCookingGameV2(
                                  context,
                                  recipeId: '${recipe.id}_v2',
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Recipe Book button
                          _RecipeBookButton(
                            completedCount: completedKeys
                                .where((k) => k.startsWith('uk::'))
                                .length,
                            totalCount: recipes.length,
                          ),
                          const SizedBox(height: 10),

                          // "More Coming Soon" label
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '\u{2B50}', // ⭐
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'More Recipes Coming Soon!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: PWColors.navy.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chef Greeting
// ---------------------------------------------------------------------------

class _ChefGreeting extends StatelessWidget {
  const _ChefGreeting({required this.speaking, required this.onSpeak});

  final bool speaking;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFD166), Color(0xFFFFB86B)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            '\u{1F468}\u{200D}\u{1F373}', // 👨‍🍳
            style: TextStyle(fontSize: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Little Chef!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cook British Classics with Friends!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSpeak,
            icon: Icon(
              speaking ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recipe Card
// ---------------------------------------------------------------------------

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.isCompleted,
    required this.onTap,
  });

  final Recipe recipe;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final diffColor = recipe.difficulty == RecipeDifficulty.easy
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF9800);
    final diffLabel =
        recipe.difficulty == RecipeDifficulty.easy ? 'Easy' : 'Medium';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                : Colors.white,
            width: 2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: PWColors.navy.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Food emoji
                  Text(
                    recipe.emoji,
                    style: const TextStyle(fontSize: 44),
                  ),
                  const SizedBox(height: 8),

                  // Recipe name
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3142),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: diffColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$diffLabel \u{2022} ${recipe.stepCount} Steps',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: diffColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Completed check
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4CAF50),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recipe Book Button
// ---------------------------------------------------------------------------

class _RecipeBookButton extends StatelessWidget {
  const _RecipeBookButton({
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const _RecipeBookBottomSheet(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF8E24AA), Color(0xFFAB47BC)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '\u{1F4D6}', // 📖
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Recipe Book',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount recipes completed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline Recipe Book (full-screen route)
// ---------------------------------------------------------------------------

class _RecipeBookBottomSheet extends ConsumerWidget {
  const _RecipeBookBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementProvider);
    final completedKeys = achievements.completedCookingRecipes;
    final recipes = cookingRecipesForCountry('uk');
    final completedCount =
        completedKeys.where((k) => k.startsWith('uk::')).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My UK Recipe Book'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),

            // Progress header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    PWColors.yellow.withValues(alpha: 0.25),
                    PWColors.mint.withValues(alpha: 0.20),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '$completedCount/${recipes.length} Recipes Completed',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: recipes.isEmpty
                          ? 0
                          : completedCount / recipes.length,
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Badge tiers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BadgeTier(
                        emoji: '\u{1F3C5}', // 🏅
                        label: 'Little Chef',
                        unlocked: completedCount >= 1,
                      ),
                      _BadgeTier(
                        emoji: '\u{1F944}', // 🥄
                        label: 'Golden Spoon',
                        unlocked: completedCount >= 3,
                      ),
                      _BadgeTier(
                        emoji: '\u{1F3C6}', // 🏆
                        label: 'Tea Time Star',
                        unlocked: completedCount >= 6,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recipe list
            for (final recipe in recipes) ...[
              _RecipeBookEntry(
                recipe: recipe,
                isCompleted: completedKeys.contains('uk::${recipe.id}'),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BadgeTier extends StatelessWidget {
  const _BadgeTier({
    required this.emoji,
    required this.label,
    required this.unlocked,
  });

  final String emoji;
  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: unlocked ? 1.0 : 0.35,
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? const Color(0xFF2D3142)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeBookEntry extends StatelessWidget {
  const _RecipeBookEntry({
    required this.recipe,
    required this.isCompleted,
  });

  final Recipe recipe;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
              : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Emoji or lock
          SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Text(
                isCompleted ? recipe.emoji : '\u{1F512}', // 🔒
                style: TextStyle(fontSize: isCompleted ? 32 : 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isCompleted
                        ? const Color(0xFF2D3142)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCompleted
                      ? recipe.funFacts.first
                      : 'Cook this recipe to unlock!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? const Color(0xFF6B7280)
                        : const Color(0xFFBDBDBD),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 26,
            ),
        ],
      ),
    );
  }
}
