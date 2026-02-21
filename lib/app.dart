import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/motion/motion_settings_provider.dart';
import 'core/routing/app_router.dart';
import 'core/theme/pw_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/gradient_background.dart';
import 'features/screen_time/lock/lock_overlay.dart';
import 'features/screen_time/providers/usage_tracker_provider.dart';

class PlanetWondersApp extends ConsumerStatefulWidget {
  const PlanetWondersApp({super.key});

  /// Navigator key exposed so widgets above the Navigator (e.g. LockOverlay
  /// in the MaterialApp builder) can show dialogs.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  @override
  ConsumerState<PlanetWondersApp> createState() => _PlanetWondersAppState();
}

class _PlanetWondersAppState extends ConsumerState<PlanetWondersApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh bedtime window on resume (covers timezone changes too).
      ref.read(bedtimeProvider.notifier).onAppResumed();
      ref.read(usageTrackerProvider.notifier).onAppResumed();
    } else if (state == AppLifecycleState.paused) {
      ref.read(usageTrackerProvider.notifier).onAppPaused();
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    // Pick up system reduce-motion changes.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final mq = MediaQueryData.fromView(view);
    ref
        .read(motionSettingsProvider.notifier)
        .updateSystemReduceMotion(mq.disableAnimations);
  }

  late final GoRouter _router = buildAppRouter(
    navigatorKey: PlanetWondersApp.rootNavigatorKey,
    shellBuilder: (context, state, navigationShell) =>
        _Shell(navigationShell: navigationShell),
  );

  @override
  Widget build(BuildContext context) {
    final effectiveMode = ref.watch(effectiveThemeModeProvider);
    final motionSettings = ref.watch(motionSettingsProvider);

    const showPerfOverlay = bool.fromEnvironment(
      'PW_SHOW_PERF_OVERLAY',
      defaultValue: false,
    );
    const showCheckerboardRasterCache = bool.fromEnvironment(
      'PW_CHECKERBOARD_RASTER_CACHE',
      defaultValue: false,
    );
    const showCheckerboardOffscreenLayers = bool.fromEnvironment(
      'PW_CHECKERBOARD_OFFSCREEN',
      defaultValue: false,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: kDebugMode && showPerfOverlay,
      checkerboardRasterCacheImages: kDebugMode && showCheckerboardRasterCache,
      checkerboardOffscreenLayers:
          kDebugMode && showCheckerboardOffscreenLayers,
      theme: planetWondersLightTheme(
        reduceMotion: motionSettings.reduceMotionEffective,
      ),
      darkTheme: planetWondersDarkTheme(
        reduceMotion: motionSettings.reduceMotionEffective,
      ),
      themeMode: effectiveMode,
      routerConfig: _router,
      builder: (context, child) {
        final tracker = ref.watch(usageTrackerProvider);
        final showLock = tracker.isLocked || tracker.isBedtimeLocked;

        Widget content = child!;
        if (showLock) {
          content = Stack(
            children: [
              content,
              LockOverlay(
                reason: tracker.isBedtimeLocked
                    ? LockReason.bedtime
                    : LockReason.dailyLimit,
              ),
            ],
          );
        }

        return GradientBackground(child: content);
      },
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: RepaintBoundary(child: navigationShell),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: RepaintBoundary(
            child: _StickerBottomNav(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerBottomNav extends StatelessWidget {
  const _StickerBottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _tabs = <_StickerTabData>[
    _StickerTabData(
      label: 'Home',
      icon: Icons.home_rounded,
      iconAsset: 'assets/icons/home.png',
      fallbackEmoji: '\u{1F3E0}',
      top: Color(0xFF2A66E5),
      bottom: Color(0xFF1D46AA),
    ),
    _StickerTabData(
      label: 'Gallery',
      icon: Icons.photo_size_select_actual_rounded,
      iconAsset: 'assets/icons/gallery.png',
      fallbackEmoji: '\u{1F5BC}',
      top: Color(0xFFFFD54F),
      bottom: Color(0xFFEEA820),
    ),
    _StickerTabData(
      label: 'Passport',
      icon: Icons.public_rounded,
      iconAsset: 'assets/icons/passport.png',
      fallbackEmoji: '\u{1F30D}',
      top: Color(0xFF5CCBFF),
      bottom: Color(0xFF268FD8),
    ),
    _StickerTabData(
      label: 'Parents',
      icon: Icons.lock_rounded,
      iconAsset: 'assets/icons/parents.png',
      fallbackEmoji: '\u{1F512}',
      top: Color(0xFF2A66E5),
      bottom: Color(0xFF1D46AA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final iconCacheSize = (72 * dpr).round().clamp(1, 1024).toInt();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        color: const Color(0xFF1542A8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33122D5D),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final isSelected = index == selectedIndex;
          final top = isSelected
              ? const Color(0xFFFFD54F)
              : const Color(0xFF2C67DF);
          final bottom = isSelected
              ? const Color(0xFFEEA820)
              : const Color(0xFF1D49A9);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onDestinationSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    // Dark edge underneath for 3D depth
                    color: Color.lerp(bottom, Colors.black, 0.35),
                  ),
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [top, bottom],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Top shine highlight
                        Positioned(
                          left: 5,
                          right: 5,
                          top: 5,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.40),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: tab.iconAsset != null
                                    ? Image.asset(
                                        tab.iconAsset!,
                                        fit: BoxFit.contain,
                                        cacheWidth: iconCacheSize,
                                        cacheHeight: iconCacheSize,
                                        filterQuality: FilterQuality.low,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  tab.icon,
                                                  color: Colors.white,
                                                  size: 52,
                                                ),
                                      )
                                    : Icon(
                                        tab.icon,
                                        color: Colors.white,
                                        size: 52,
                                      ),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  tab.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.fredoka(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    height: 1.05,
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
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StickerTabData {
  const _StickerTabData({
    required this.label,
    required this.icon,
    required this.top,
    required this.bottom,
    this.iconAsset,
    this.fallbackEmoji,
  });

  final String label;
  final IconData icon;
  final Color top;
  final Color bottom;
  final String? iconAsset;
  final String? fallbackEmoji;
}
