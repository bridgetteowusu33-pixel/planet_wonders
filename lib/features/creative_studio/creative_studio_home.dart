// File: lib/features/creative_studio/creative_studio_home.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/pw_theme.dart';

class CreativeStudioHomeScreen extends StatelessWidget {
  const CreativeStudioHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF89C9F3), Color(0xFFB8F2D0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: PWColors.navy,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6E8DFB), Color(0xFF7D55EE)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      'Creative Studio',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Make Something Amazing!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _StudioCard(
                  title: 'FREE DRAW',
                  subtitle: 'Draw Anything',
                  colorA: const Color(0xFFFFE8A6),
                  colorB: const Color(0xFFFFD77D),
                  icon: Icons.brush_rounded,
                  onTap: () =>
                      context.push('/creative-studio/canvas?mode=free_draw'),
                ),
                const SizedBox(height: 12),
                _StudioCard(
                  title: 'DRAW WITH ME',
                  subtitle: 'Follow Fun Ideas',
                  colorA: const Color(0xFFD3C1FF),
                  colorB: const Color(0xFFB18BFF),
                  icon: Icons.auto_awesome_rounded,
                  onTap: () => context.push('/draw-with-me'),
                ),
                const SizedBox(height: 12),
                _StudioCard(
                  title: 'SCENE BUILDER',
                  subtitle: 'Draw in Places',
                  colorA: const Color(0xFFC6F3E8),
                  colorB: const Color(0xFFA7EBD9),
                  icon: Icons.landscape_rounded,
                  onTap: () => context.push('/creative-studio/scenes'),
                ),
                const SizedBox(height: 12),
                _StudioCard(
                  title: 'MY ART',
                  subtitle: 'See Your Pictures',
                  colorA: const Color(0xFFFFD3E8),
                  colorB: const Color(0xFFFFB9DA),
                  icon: Icons.photo_library_rounded,
                  onTap: () => context.push('/creative-studio/my-art'),
                ),
                const Spacer(),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.push('/creative-studio/mode'),
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Mode Selector'),
                    style: TextButton.styleFrom(
                      foregroundColor: PWColors.navy,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudioCard extends StatefulWidget {
  const _StudioCard({
    required this.title,
    required this.subtitle,
    required this.colorA,
    required this.colorB,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color colorA;
  final Color colorB;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_StudioCard> createState() => _StudioCardState();
}

class _StudioCardState extends State<_StudioCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.98 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: Ink(
            height: 108,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [widget.colorA, widget.colorB]),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(widget.icon, size: 38, color: PWColors.navy),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: PWColors.navy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PWColors.navy.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 36,
                  color: PWColors.navy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
