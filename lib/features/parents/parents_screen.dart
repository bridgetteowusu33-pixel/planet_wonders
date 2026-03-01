import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/audio/narration_settings_provider.dart';
import '../../core/motion/motion_settings_provider.dart';
import '../../core/theme/pw_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../game_breaks/providers/game_break_settings_provider.dart';
import '../screen_time/providers/screen_time_settings_provider.dart';
import '../screen_time/widgets/pin_dialog.dart';

class ParentsScreen extends ConsumerWidget {
  const ParentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gameBreakSettingsProvider);
    final notifier = ref.read(gameBreakSettingsProvider.notifier);
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final bedtime = ref.watch(bedtimeProvider);
    final bedtimeNotifier = ref.read(bedtimeProvider.notifier);
    final motion = ref.watch(motionSettingsProvider);
    final motionNotifier = ref.read(motionSettingsProvider.notifier);
    final stSettings = ref.watch(screenTimeSettingsProvider);
    final narrationSettings = ref.watch(narrationSettingsProvider);
    final narrationNotifier = ref.read(narrationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 20,
              color: PWThemeColors.of(context).textMuted,
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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Bedtime Active pill ──
          if (bedtime.enabled && bedtime.isActive) ...[
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A2F6B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '\u{1F319}', // 🌙
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Bedtime Active',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

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
                    color: PWThemeColors.of(context).textMuted,
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
                      color: PWThemeColors.of(context).textMuted,
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
                      color: PWThemeColors.of(context).textMuted,
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

          // ── Audio section ──
          _SectionHeader(
            title: 'Audio',
            emoji: '\u{1F50A}', // 🔊
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: Text(
                  'Story Voice',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Use a natural voice for story narration',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWThemeColors.of(context).textMuted,
                  ),
                ),
                value: narrationSettings.storyVoiceEnabled,
                onChanged: (v) => narrationNotifier.setStoryVoiceEnabled(v),
                activeThumbColor: PWColors.mint,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Reports section ──
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
                  'View activity and skills progress',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWThemeColors.of(context).textMuted,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: PWThemeColors.of(context).textMuted,
                ),
                onTap: () => context.push('/reports'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Screen Time section ──
          _SectionHeader(
            title: 'Screen Time',
            emoji: '\u{23F1}\u{FE0F}', // ⏱️
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: PWColors.blue),
                title: Text(
                  'Screen Time',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  '${stSettings.limitLabel} daily limit',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWThemeColors.of(context).textMuted,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (stSettings.hasPin)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 16,
                          color: PWThemeColors.of(context).textMuted.withValues(alpha: 0.5),
                        ),
                      ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: PWThemeColors.of(context).textMuted,
                    ),
                  ],
                ),
                onTap: () async {
                  if (stSettings.hasPin) {
                    final verified = await showPinDialog(
                      context: context,
                      mode: PinMode.verify,
                      onVerify: (pin) => ref
                          .read(screenTimeSettingsProvider.notifier)
                          .verifyPin(pin),
                      onSet: (_) {},
                    );
                    if (!verified || !context.mounted) return;
                  }
                  context.push('/screen-time');
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Appearance section ──
          _SectionHeader(
            title: 'Appearance',
            emoji: '\u{1F3A8}', // 🎨
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _ThemeTile(
                label: '\u{2600}\u{FE0F}  Light Mode',
                isSelected: currentTheme == ThemeModeType.light,
                onTap: () => themeNotifier.setLight(),
              ),
              const Divider(height: 1),
              _ThemeTile(
                label: '\u{1F319}  Dark Mode',
                isSelected: currentTheme == ThemeModeType.dark,
                onTap: () => themeNotifier.setDark(),
              ),
              const Divider(height: 1),
              _ThemeTile(
                label: '\u{1F4F1}  System Default',
                isSelected: currentTheme == ThemeModeType.system,
                onTap: () => themeNotifier.setSystem(),
              ),
              const Divider(height: 1),
              // Bedtime Mode toggle
              SwitchListTile(
                title: Text(
                  '\u{1F319}  Bedtime Mode',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Automatically switch to Dark Mode after 8pm',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWThemeColors.of(context).textMuted,
                  ),
                ),
                value: bedtime.enabled,
                onChanged: (v) => bedtimeNotifier.setEnabled(v),
                activeThumbColor: const Color(0xFF6B5CE7),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Accessibility section ──
          _SectionHeader(
            title: 'Accessibility',
            emoji: '\u{267F}', // ♿
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: Text(
                  'Reduce Motion',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Fewer animations (helps with motion sensitivity)',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWThemeColors.of(context).textMuted,
                  ),
                ),
                value: motion.reduceMotionEffective,
                onChanged: (v) => motionNotifier.setMode(
                  v ? ReduceMotionMode.on : ReduceMotionMode.off,
                ),
                activeThumbColor: PWColors.blue,
              ),
              if (motion.mode != ReduceMotionMode.system) ...[
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  title: Text(
                    'Reset to System Default',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: PWColors.blue,
                    ),
                  ),
                  onTap: () => motionNotifier.setMode(ReduceMotionMode.system),
                ),
              ],
              const Divider(height: 1),
              // Preview button
              ListTile(
                title: Text(
                  'Preview',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  motion.reduceMotionEffective
                      ? 'Animations are currently reduced'
                      : 'Animations are currently normal',
                  style: TextStyle(
                    fontSize: 13,
                    color: PWThemeColors.of(context).textMuted,
                  ),
                ),
                trailing: _MotionPreviewIcon(
                  reduceMotion: motion.reduceMotionEffective,
                ),
                onTap: () => _showMotionPreview(context, motion),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ── App branding footer ──
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/logos/planet_wonders_logo.webp',
                  height: 40,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 6),
                Text(
                  'Planet Wonders Kids by Afia Labs',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PWThemeColors.of(context).textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: PWThemeColors.of(context).textMuted.withValues(alpha: 0.45),
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
    );
  }

  void _showMotionPreview(BuildContext context, MotionSettings motion) {
    showDialog(
      context: context,
      builder: (ctx) => _MotionPreviewDialog(
        reduceMotion: motion.reduceMotionEffective,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Motion preview dialog
// ---------------------------------------------------------------------------

class _MotionPreviewDialog extends StatefulWidget {
  const _MotionPreviewDialog({required this.reduceMotion});

  final bool reduceMotion;

  @override
  State<_MotionPreviewDialog> createState() => _MotionPreviewDialogState();
}

class _MotionPreviewDialogState extends State<_MotionPreviewDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showBadge = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.reduceMotion
          ? const Duration(milliseconds: 120)
          : const Duration(milliseconds: 600),
    );
    // Trigger the demo animation after a short delay.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showBadge = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = PWThemeColors.of(context);

    return AlertDialog(
      backgroundColor: tc.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.reduceMotion ? 'Reduced Motion' : 'Normal Motion',
        style: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: tc.textPrimary,
        ),
      ),
      content: SizedBox(
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = widget.reduceMotion
                    ? (_showBadge ? 1.0 : 0.0)
                    : Curves.elasticOut.transform(_controller.value);
                final opacity = _showBadge ? 1.0 : 0.0;

                return Opacity(
                  opacity: widget.reduceMotion
                      ? opacity
                      : _controller.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  const Text(
                    '\u{1F3C6}', // 🏆
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Badge Unlocked!',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.reduceMotion
                  ? 'Instant reveal, no bounce'
                  : 'Elastic bounce-in animation',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tc.textMuted,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: PWColors.blue,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Motion preview icon (animated or static based on setting)
// ---------------------------------------------------------------------------

class _MotionPreviewIcon extends StatefulWidget {
  const _MotionPreviewIcon({required this.reduceMotion});

  final bool reduceMotion;

  @override
  State<_MotionPreviewIcon> createState() => _MotionPreviewIconState();
}

class _MotionPreviewIconState extends State<_MotionPreviewIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!widget.reduceMotion) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_MotionPreviewIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    } else if (!widget.reduceMotion && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) {
      return Icon(
        Icons.animation_rounded,
        color: PWThemeColors.of(context).textMuted,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.85 + 0.15 * _controller.value,
          child: child,
        );
      },
      child: Icon(
        Icons.animation_rounded,
        color: PWColors.blue,
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
            color: PWThemeColors.of(context).textPrimary,
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
    final tc = PWThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: tc.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected
            ? PWColors.blue
            : PWThemeColors.of(context).textMuted.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}

