import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isTablet = w >= 600;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        // --- Top bar ---
                        Row(
                          children: [
                            Material(
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
                            const Spacer(),
                            IconButton(
                              onPressed: () => context.go('/'),
                              icon: const Icon(
                                Icons.home_rounded,
                                color: PWColors.navy,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // --- Title badge ---
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6E8DFB), Color(0xFF7D55EE)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border:
                                Border.all(color: Colors.white, width: 2),
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Make Something Amazing!',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),

                        const SizedBox(height: 20),

                        // --- 3D activity grid ---
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: isTablet ? 1.0 : 0.95,
                            children: [
                              _Studio3DTab(
                                label: 'Free Draw',
                                icon: Icons.brush_rounded,
                                fallbackEmoji: '\u{1F58C}\u{FE0F}',
                                gradientTop: const Color(0xFFFFD54F),
                                gradientBottom: const Color(0xFFFFA726),
                                onTap: () => context.push(
                                  '/creative-studio/canvas?mode=free_draw',
                                ),
                              ),
                              _Studio3DTab(
                                label: 'Draw With Me',
                                icon: Icons.auto_awesome_rounded,
                                fallbackEmoji: '\u{2728}',
                                gradientTop: const Color(0xFFCE93D8),
                                gradientBottom: const Color(0xFF9C27B0),
                                onTap: () => context.push('/draw-with-me'),
                              ),
                              _Studio3DTab(
                                label: 'Scene Builder',
                                icon: Icons.landscape_rounded,
                                fallbackEmoji: '\u{1F3DE}\u{FE0F}',
                                gradientTop: const Color(0xFF80CBC4),
                                gradientBottom: const Color(0xFF26A69A),
                                onTap: () => context.push(
                                  '/creative-studio/scenes',
                                ),
                              ),
                              _Studio3DTab(
                                label: 'My Art',
                                icon: Icons.photo_library_rounded,
                                fallbackEmoji: '\u{1F5BC}\u{FE0F}',
                                gradientTop: const Color(0xFFF48FB1),
                                gradientBottom: const Color(0xFFE91E63),
                                onTap: () => context.push(
                                  '/creative-studio/my-art',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 3D sticker-style tab matching the home screen design.
class _Studio3DTab extends StatelessWidget {
  const _Studio3DTab({
    required this.label,
    required this.icon,
    required this.fallbackEmoji,
    required this.gradientTop,
    required this.gradientBottom,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String fallbackEmoji;
  final Color gradientTop;
  final Color gradientBottom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(28));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          // Dark edge underneath for 3D depth
          color: Color.lerp(gradientBottom, Colors.black, 0.35),
        ),
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientTop, gradientBottom],
            ),
          ),
          child: Stack(
            children: [
              // Top shine highlight
              Positioned(
                left: 6,
                right: 6,
                top: 6,
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.45),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            icon,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fredoka(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
