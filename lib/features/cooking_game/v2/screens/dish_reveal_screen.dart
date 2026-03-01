import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/cooking_audio_service.dart';
import '../models/v2_recipe.dart';
import '../providers/v2_cooking_state.dart';
import '../widgets/chef_avatar.dart';

class DishRevealScreen extends StatefulWidget {
  const DishRevealScreen({
    super.key,
    required this.recipe,
    required this.state,
    required this.onCookAgain,
    this.onMyKitchen,
    required this.onExit,
  });

  final V2Recipe recipe;
  final V2CookingState state;
  final VoidCallback onCookAgain;
  final VoidCallback? onMyKitchen;
  final VoidCallback onExit;

  @override
  State<DishRevealScreen> createState() => _DishRevealScreenState();
}

class _DishRevealScreenState extends State<DishRevealScreen> {
  @override
  void initState() {
    super.initState();
    _playTadaHaptic();
  }

  Future<void> _playTadaHaptic() async {
    CookingAudioService.instance.playSfx(
      'recipe_complete',
      widget.recipe.countryId,
    );
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.state.stars;
    final isPerfect = stars >= 3;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: <Widget>[
            const Spacer(flex: 2),
            // Confetti emoji row
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, t, child) {
                return Transform.scale(scale: 0.5 + t * 0.5, child: child);
              },
              child: const Text(
                '\u{1F389}\u{1F38A}', // 🎉🎊
                style: TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 12),
            // Big dish image reveal
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, t, child) {
                return Transform.scale(
                  scale: t,
                  child: Opacity(
                    opacity: t.clamp(0, 1),
                    child: child,
                  ),
                );
              },
              child: widget.recipe.dishImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        widget.recipe.dishImagePath!,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Text(
                          widget.recipe.emoji,
                          style: const TextStyle(fontSize: 96),
                        ),
                      ),
                    )
                  : Text(
                      widget.recipe.emoji,
                      style: const TextStyle(fontSize: 96),
                    ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              isPerfect ? 'Perfect Chef!' : 'Dish Complete!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: isPerfect
                    ? const Color(0xFFFF8C00)
                    : const Color(0xFF1D3557),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.recipe.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF355070),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ChefAvatar(
                  countryId: widget.recipe.countryId,
                  size: 120,
                  mood: ChefAvatarMood.proud,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.recipe.characterName} is so proud!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(3, (i) {
                final earned = i < stars;
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: earned ? 1 : 0.3),
                  duration: Duration(milliseconds: 400 + i * 200),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.5 + value * 0.5,
                      child: Opacity(
                        opacity: value.clamp(0, 1),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      earned
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 56,
                      color: earned
                          ? const Color(0xFFFFB703)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _StatChip(
                  label: 'Mistakes',
                  value: '${widget.state.mistakes}',
                  icon: Icons.close_rounded,
                  color: const Color(0xFFFF6B6B),
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: 'Max Combo',
                  value: '${widget.state.maxCombo}',
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFFFFB703),
                ),
              ],
            ),
            const Spacer(flex: 3),
            // Buttons
            _ActionButton(
              title: 'Cook Again',
              onTap: widget.onCookAgain,
              colors: const <Color>[Color(0xFFFFB703), Color(0xFFFFA000)],
            ),
            if (widget.onMyKitchen != null) ...[
              const SizedBox(height: 10),
              _ActionButton(
                title: 'My Kitchen',
                onTap: widget.onMyKitchen!,
                colors: const <Color>[Color(0xFF90CAF9), Color(0xFF42A5F5)],
              ),
            ],
            const SizedBox(height: 10),
            _ActionButton(
              title: 'Exit',
              onTap: widget.onExit,
              colors: const <Color>[Color(0xFF6BCB77), Color(0xFF4CAF50)],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.onTap,
    required this.colors,
  });

  final String title;
  final VoidCallback onTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 12,
              offset: Offset(0, 7),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
