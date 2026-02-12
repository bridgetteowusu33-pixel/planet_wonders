import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/pw_theme.dart';
import '../game_breaks/providers/game_break_settings_provider.dart';

class ParentsScreen extends ConsumerWidget {
  const ParentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameBreakSettingsProvider);
    final notifier = ref.read(gameBreakSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 20,
              color: PWColors.navy.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'Parent Hub',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Game Breaks section ──
          _SectionHeader(
            title: 'Game Breaks',
            emoji: '\u{1F3AE}', // 🎮
          ),
          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              SwitchListTile(
                title: Text(
                  'Enable Game Breaks',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Short optional games between activities',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWColors.navy.withValues(alpha: 0.5),
                  ),
                ),
                value: settings.enabled,
                onChanged: (v) => notifier.setEnabled(v),
                activeThumbColor: PWColors.mint,
              ),

              if (settings.enabled) ...[
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    'After Activities',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Suggest a game after coloring or stories',
                    style: TextStyle(
                      fontSize: 13,
                      color: PWColors.navy.withValues(alpha: 0.5),
                    ),
                  ),
                  value: settings.afterActivities,
                  onChanged: (v) => notifier.setAfterActivities(v),
                  activeThumbColor: PWColors.mint,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    'Calm Mode',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Fewer prompts, slower animations',
                    style: TextStyle(
                      fontSize: 13,
                      color: PWColors.navy.withValues(alpha: 0.5),
                    ),
                  ),
                  value: settings.calmMode,
                  onChanged: (v) => notifier.setCalmMode(v),
                  activeThumbColor: PWColors.mint,
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // ── Reports section (placeholder) ──
          _SectionHeader(
            title: 'Reports',
            emoji: '\u{1F4CA}', // 📊
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                title: Text(
                  'Learning Report',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Coming soon',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWColors.navy.withValues(alpha: 0.5),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: PWColors.navy.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Screen Time section (placeholder) ──
          _SectionHeader(
            title: 'Screen Time',
            emoji: '\u{23F1}\u{FE0F}', // ⏱️
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                title: Text(
                  'Usage Limits',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Coming soon',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWColors.navy.withValues(alpha: 0.5),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: PWColors.navy.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.emoji});

  final String title;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.baloo2(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: PWColors.navy,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
