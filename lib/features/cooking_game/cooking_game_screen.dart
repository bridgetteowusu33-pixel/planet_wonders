import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/pw_theme.dart';
import '../achievements/providers/achievement_provider.dart';
import '../achievements/ui/badge_unlock_animation.dart';
import 'cooking_controller.dart';
import 'models/cooking_step.dart';
import 'models/recipe.dart';
import 'ui/celebration_overlay.dart';
import 'ui/cooking_header.dart';
import 'ui/ingredient_tray.dart';
import 'ui/plate_area.dart';
import 'ui/pot_area.dart';
import 'ui/stir_pad.dart';

class CookingGameScreen extends ConsumerStatefulWidget {
  const CookingGameScreen({
    super.key,
    required this.recipe,
    this.entrySource = 'games',
    this.entryCountryId,
  });

  final Recipe recipe;
  final String entrySource;
  final String? entryCountryId;

  @override
  ConsumerState<CookingGameScreen> createState() => _CookingGameScreenState();
}

class _CookingGameScreenState extends ConsumerState<CookingGameScreen> {
  late final CookingController _controller;
  bool _completionReported = false;

  @override
  void initState() {
    super.initState();
    _controller = CookingController(recipe: widget.recipe)
      ..addListener(_onControllerChange);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChange)
      ..dispose();
    super.dispose();
  }

  void _onControllerChange() {
    final isComplete = _controller.state == CookingState.complete;
    if (isComplete && !_completionReported) {
      _completionReported = true;
      _notifyCookingCompleted();
    }
    if (mounted) setState(() {});
  }

  void _notifyCookingCompleted() {
    final countryId =
        (widget.entryCountryId != null &&
            widget.entryCountryId!.trim().isNotEmpty)
        ? widget.entryCountryId!.trim()
        : widget.recipe.countryId;

    Future<void>.microtask(() {
      ref
          .read(achievementProvider.notifier)
          .markCookingRecipeCompleted(
            countryId: countryId,
            recipeId: widget.recipe.id,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: Text(
          _headline(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              CookingHeader(
                recipeName: widget.recipe.name,
                state: _controller.state,
                progress: _controller.overallProgress(),
              ),
              _FactChip(text: _controller.currentFact),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _buildStateBody(),
                ),
              ),
            ],
          ),
          if (_controller.state == CookingState.complete)
            CelebrationOverlay(
              badgeTitle: '${_countryLabel()} Chef Star!\n+1 Culture Star',
              onDone: () => Navigator.of(context).pop(true),
            ),
          const BadgeUnlockAnimationListener(),
        ],
      ),
    );
  }

  Widget _buildStateBody() {
    switch (_controller.state) {
      case CookingState.intro:
        return _buildIntro();
      case CookingState.addIngredients:
        return _buildAddIngredients();
      case CookingState.stir:
        return _buildStir();
      case CookingState.plate:
        return _buildPlate();
      case CookingState.complete:
        return const SizedBox.expand(key: ValueKey('complete'));
    }
  }

  Widget _buildIntro() {
    return Center(
      key: const ValueKey('intro'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: PWColors.navy.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.recipe.emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              Text(
                widget.recipe.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                widget.entrySource == 'food'
                    ? 'Tap start and cook this country recipe!'
                    : 'Ready to play cooking in 3 fun steps?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _controller.startCooking,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Cooking'),
                style: FilledButton.styleFrom(
                  backgroundColor: PWColors.coral,
                  minimumSize: const Size(190, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddIngredients() {
    return Column(
      key: const ValueKey('add'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Text(
            _controller.currentInstruction,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        PotArea(
          ingredients: widget.recipe.ingredients,
          addedIngredientIds: _controller.addedIngredientIds,
          onIngredientDropped: _controller.addIngredient,
          dropAnimationTick: _controller.dropAnimationTick,
        ),
        IngredientTray(ingredients: _controller.remainingIngredients),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: FilledButton(
            onPressed: _controller.allIngredientsAdded
                ? _controller.continueToStirIfReady
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: PWColors.mint,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _controller.allIngredientsAdded
                  ? 'Next: Stir'
                  : 'Add all ingredients first',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStir() {
    return Column(
      key: const ValueKey('stir'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Text(
            _controller.currentInstruction,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PotArea(
                ingredients: widget.recipe.ingredients,
                addedIngredientIds: _controller.addedIngredientIds,
                onIngredientDropped: (_) {},
                bubbling: true,
                dropAnimationTick: _controller.dropAnimationTick,
              ),
              SizedBox(
                width: 300,
                height: 300,
                child: StirPad(
                  progress: _controller.stirProgress,
                  onStirStart: _controller.onStirStart,
                  onStirUpdate: (point, size) =>
                      _controller.onStirUpdate(point: point, areaSize: size),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPlate() {
    return Column(
      key: const ValueKey('plate'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Text(
            _controller.currentInstruction,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PlateArea(
              progress: _controller.plateProgress,
              onServe: _controller.serveScoop,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String _headline() {
    if (widget.entrySource == 'food') {
      return 'Let\'s Cook ${_countryLabel()} Food!';
    }
    return 'Let\'s Play Cooking!';
  }

  String _countryLabel() {
    final raw = (widget.entryCountryId ?? widget.recipe.countryId).trim();
    if (raw.isEmpty) return 'Country';
    return raw
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: PWColors.yellow.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PWColors.navy.withValues(alpha: 0.1)),
        ),
        child: Text(
          '💡 $text',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
