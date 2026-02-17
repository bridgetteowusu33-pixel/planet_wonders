// File: lib/features/creative_studio/draw_mode_selector.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/pw_theme.dart';
import 'creative_state.dart';

class DrawModeSelectorScreen extends StatelessWidget {
  const DrawModeSelectorScreen({super.key, this.initialMode});

  final CreativeEntryMode? initialMode;

  @override
  Widget build(BuildContext context) {
    final highlight = initialMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Draw Mode'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How do you want to create today?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: PWColors.navy.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _ModeTile(
                icon: Icons.brush_rounded,
                title: 'Free Draw',
                subtitle: 'Draw anything you imagine',
                color: const Color(0xFFF9D97C),
                selected: highlight == CreativeEntryMode.freeDraw,
                onTap: () =>
                    context.push('/creative-studio/canvas?mode=free_draw'),
              ),
              const SizedBox(height: 10),
              _ModeTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Draw With Me',
                subtitle: 'Trace and create with guidance',
                color: const Color(0xFFCCB2FF),
                selected: highlight == CreativeEntryMode.drawWithMe,
                onTap: () => context.push('/draw-with-me'),
              ),
              const SizedBox(height: 10),
              _ModeTile(
                icon: Icons.landscape_rounded,
                title: 'Scene Builder',
                subtitle: 'Draw in colorful places',
                color: const Color(0xFFAFEBD8),
                selected: highlight == CreativeEntryMode.sceneBuilder,
                onTap: () => context.push('/creative-studio/scenes'),
              ),
              const SizedBox(height: 10),
              _ModeTile(
                icon: Icons.photo_library_rounded,
                title: 'My Art',
                subtitle: 'See your saved pictures',
                color: const Color(0xFFFFC9DE),
                selected: false,
                onTap: () => context.push('/creative-studio/my-art'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          height: 94,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? PWColors.navy : color.withValues(alpha: 0.65),
              width: selected ? 2.4 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: PWColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PWColors.navy.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
