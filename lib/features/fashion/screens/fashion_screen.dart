import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/gallery_service.dart';
import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/fashion_registry.dart';
import '../models/fashion_data.dart';
import '../models/outfit_snapshot.dart';

/// Main fashion dress-up screen — paper-doll style.
///
/// Layout (top → bottom):
///   1. Top bar — back chevron, "Country · Fashion"
///   2. Character display — layered PNGs (body + outfit) or emoji fallback
///   3. Category tabs — pill buttons (Dress, Tops, Bottoms, Hats)
///   4. Item carousel — horizontal scroll of outfit cards
///   5. Action buttons — Color Outfit + Save
///   6. Optional "Did You Know?" micro-card
class FashionScreen extends ConsumerStatefulWidget {
  const FashionScreen({super.key, required this.countryId});

  final String countryId;

  @override
  ConsumerState<FashionScreen> createState() => _FashionScreenState();
}

class _FashionScreenState extends ConsumerState<FashionScreen> {
  final _characterKey = GlobalKey();
  int _activeCategoryIndex = 0;
  late final OutfitState _outfit;

  bool _showFact = false;
  bool _saving = false;
  FashionFact? _currentFact;

  // Debug panel state (only used in kDebugMode).
  bool _debugOpen = false;
  double _debugShiftY = 0.0;
  double _debugScale = 1.0;

  @override
  void initState() {
    super.initState();
    _outfit = OutfitState();
  }

  void _selectItem(OutfitItem item, String categoryId) {
    setState(() {
      _outfit.select(categoryId, item);
      _showFact = false;
      // Sync debug sliders with newly selected item.
      _debugShiftY = item.shiftY;
      _debugScale = item.scale;
    });

    // Show a random fact after a short delay.
    final fashion = findFashion(widget.countryId);
    if (fashion != null && fashion.facts.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        final rng = Random();
        setState(() {
          _currentFact = fashion.facts[rng.nextInt(fashion.facts.length)];
          _showFact = true;
        });
      });
    }
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final boundary = _characterKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null || !mounted) return;

      await GalleryService.saveDrawing(byteData.buffer.asUint8List());
      ref.invalidate(galleryProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Outfit saved to Gallery!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fashion = findFashion(widget.countryId);

    if (fashion == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Fashion not found')),
      );
    }

    final country = findCountryById(widget.countryId);
    final categories = fashion.categories;
    final activeCategory = categories[_activeCategoryIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            _TopBar(
              flag: country?.flagEmoji ?? '',
              countryName: country?.name ?? widget.countryId,
            ),

            // ── Character display ──
            Expanded(
              flex: 5,
              child: RepaintBoundary(
                key: _characterKey,
                child: fashion.hasAssets
                    ? _LayeredCharacter(
                        bodyAsset: fashion.bodyAsset!,
                        outfit: _outfit,
                        bodyShiftY: fashion.bodyShiftY,
                        bodyScale: fashion.bodyScale,
                        debugItemId: kDebugMode
                            ? _outfit
                                  .selectedFor(
                                    fashion.categories[_activeCategoryIndex].id,
                                  )
                                  ?.id
                            : null,
                        debugShiftY: _debugShiftY,
                        debugScale: _debugScale,
                      )
                    : _EmojiCharacter(
                        fashion: fashion,
                        outfit: _outfit,
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Category tabs ──
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final isActive = i == _activeCategoryIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _activeCategoryIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? PWColors.blue
                            : PWColors.navy.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.white : PWColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Item carousel ──
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: activeCategory.items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final item = activeCategory.items[i];
                  final isSelected =
                      _outfit.selectedFor(activeCategory.id)?.id == item.id;
                  return _OutfitCard(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => _selectItem(item, activeCategory.id),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Debug panel (dev mode only) ──
            if (kDebugMode && fashion.hasAssets)
              _DebugPositionPanel(
                isOpen: _debugOpen,
                onToggle: () => setState(() => _debugOpen = !_debugOpen),
                shiftY: _debugShiftY,
                scale: _debugScale,
                itemLabel: _outfit.selectedFor(activeCategory.id)?.name,
                onShiftYChanged: (v) => setState(() => _debugShiftY = v),
                onScaleChanged: (v) => setState(() => _debugScale = v),
              ),

            // ── Did You Know? micro-card ──
            if (_showFact && _currentFact != null)
              _FactMicroCard(
                fact: _currentFact!,
                onDismiss: () => setState(() => _showFact = false),
              ),

            // ── Action buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        if (!fashion.hasAssets) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Color mode coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        // Build snapshot of current outfit.
                        final layers = <OutfitLayer>[];
                        final dress = _outfit.selectedFor('dress');
                        if (dress?.assetPath != null) {
                          layers.add(OutfitLayer(
                            assetPath: dress!.assetPath!,
                            shiftY: dress.shiftY,
                            scale: dress.scale,
                          ));
                        } else {
                          final bottom = _outfit.selectedFor('bottoms');
                          if (bottom?.assetPath != null) {
                            layers.add(OutfitLayer(
                              assetPath: bottom!.assetPath!,
                              shiftY: bottom.shiftY,
                              scale: bottom.scale,
                            ));
                          }
                          final top = _outfit.selectedFor('tops');
                          if (top?.assetPath != null) {
                            layers.add(OutfitLayer(
                              assetPath: top!.assetPath!,
                              shiftY: top.shiftY,
                              scale: top.scale,
                            ));
                          }
                        }
                        final hat = _outfit.selectedFor('hats');
                        if (hat?.assetPath != null) {
                          layers.add(OutfitLayer(
                            assetPath: hat!.assetPath!,
                            shiftY: hat.shiftY,
                            scale: hat.scale,
                          ));
                        }

                        final snapshot = OutfitSnapshot(
                          bodyAsset: fashion.bodyAsset!,
                          bodyShiftY: fashion.bodyShiftY,
                          bodyScale: fashion.bodyScale,
                          layers: layers,
                        );

                        context.push(
                          '/fashion/${widget.countryId}/color',
                          extra: snapshot,
                        );
                      },
                      icon: const Text(
                        '\u{1F3A8}', // 🎨
                        style: TextStyle(fontSize: 18),
                      ),
                      label: const Text('Color Outfit'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _onSave,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '\u{1F4BE}', // 💾
                              style: TextStyle(fontSize: 18),
                            ),
                      label: const Text('Save'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.flag, required this.countryName});

  final String flag;
  final String countryName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.chevron_left_rounded, size: 32),
            color: PWColors.navy,
          ),
          Text(
            '$flag $countryName',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
          ),
          Text(
            ' \u00B7 Fashion',
            style: TextStyle(
              fontSize: 16,
              color: PWColors.navy.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layered character — Stack of transparent PNGs (paper-doll)
//
// All images share the same 1024×1536 canvas. Each clothing item has
// per-item shiftY and scale values to align it to the body.
//
// Layer order (bottom → top):
//   body → bottoms → tops → dress (replaces tops+bottoms) → hats
// ---------------------------------------------------------------------------

class _LayeredCharacter extends StatelessWidget {
  const _LayeredCharacter({
    required this.bodyAsset,
    required this.outfit,
    this.bodyShiftY = 0.0,
    this.bodyScale = 1.0,
    this.debugItemId,
    this.debugShiftY = 0.0,
    this.debugScale = 1.0,
  });

  final String bodyAsset;
  final OutfitState outfit;
  final double bodyShiftY;
  final double bodyScale;

  /// When non-null, the item with this ID uses debug overrides.
  final String? debugItemId;
  final double debugShiftY;
  final double debugScale;

  @override
  Widget build(BuildContext context) {
    // Build ordered layer list: (item, assetPath)
    final layers = <OutfitItem>[];

    final dress = outfit.selectedFor('dress');
    if (dress?.assetPath != null) {
      layers.add(dress!);
    } else {
      final bottom = outfit.selectedFor('bottoms');
      if (bottom?.assetPath != null) layers.add(bottom!);
      final top = outfit.selectedFor('tops');
      if (top?.assetPath != null) layers.add(top!);
    }

    final hat = outfit.selectedFor('hats');
    if (hat?.assetPath != null) layers.add(hat!);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PWColors.blue.withValues(alpha: 0.12),
            PWColors.mint.withValues(alpha: 0.12),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cW = constraints.maxWidth;
          final cH = constraints.maxHeight;

          // Body is 1024×1536 (2:3). Compute rendered size.
          const imgAspect = 1024 / 1536;
          final containerAspect = cW / cH;

          double bodyW, bodyH;
          if (containerAspect > imgAspect) {
            bodyH = cH;
            bodyW = cH * imgAspect;
          } else {
            bodyW = cW;
            bodyH = cW / imgAspect;
          }

          final dx = (cW - bodyW) / 2;
          final dy = (cH - bodyH) / 2;

          // Unique key for the current outfit combination.
          final layerKey = layers.map((e) => e.id).join('_');

          return Stack(
            children: [
              // Body base — stays static (no animation)
              Builder(builder: (_) {
                final bw = bodyW * bodyScale;
                final bh = bodyH * bodyScale;
                return Positioned(
                  left: dx + (bodyW - bw) / 2,
                  top: dy + bodyH * bodyShiftY,
                  width: bw,
                  height: bh,
                  child: Image.asset(bodyAsset, fit: BoxFit.contain),
                );
              }),

              // Clothing layers — bounce-in on outfit change
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  transitionBuilder: (child, animation) {
                    final bounce = Tween<double>(begin: 0.93, end: 1.0)
                        .animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ));
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: bounce,
                        child: child,
                      ),
                    );
                  },
                  child: Stack(
                    key: ValueKey(layerKey),
                    children: [
                      for (final item in layers)
                        Builder(builder: (_) {
                          final isDebug = item.id == debugItemId;
                          final sy = isDebug ? debugShiftY : item.shiftY;
                          final sc = isDebug ? debugScale : item.scale;
                          return Positioned(
                            left: dx + (bodyW - bodyW * sc) / 2,
                            top: dy + bodyH * sy,
                            width: bodyW * sc,
                            height: bodyH * sc,
                            child: Image.asset(
                              item.assetPath!,
                              fit: BoxFit.contain,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Emoji character fallback — for countries without assets yet
// ---------------------------------------------------------------------------

class _EmojiCharacter extends StatelessWidget {
  const _EmojiCharacter({
    required this.fashion,
    required this.outfit,
  });

  final FashionData fashion;
  final OutfitState outfit;

  @override
  Widget build(BuildContext context) {
    final selectedItems = <OutfitItem>[];
    for (final cat in fashion.categories) {
      final sel = outfit.selectedFor(cat.id);
      if (sel != null) selectedItems.add(sel);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PWColors.blue.withValues(alpha: 0.12),
            PWColors.mint.withValues(alpha: 0.12),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fashion.characterEmoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 8),
              Text(
                fashion.characterName,
                style: GoogleFonts.baloo2(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: PWColors.navy,
                ),
              ),
            ],
          ),
          if (selectedItems.isNotEmpty)
            Positioned(
              top: 16,
              left: 20,
              child: _FloatingItem(item: selectedItems[0]),
            ),
          if (selectedItems.length > 1)
            Positioned(
              top: 16,
              right: 20,
              child: _FloatingItem(item: selectedItems[1]),
            ),
          if (selectedItems.length > 2)
            Positioned(
              bottom: 16,
              left: 20,
              child: _FloatingItem(item: selectedItems[2]),
            ),
          if (selectedItems.length > 3)
            Positioned(
              bottom: 16,
              right: 20,
              child: _FloatingItem(item: selectedItems[3]),
            ),
        ],
      ),
    );
  }
}

class _FloatingItem extends StatelessWidget {
  const _FloatingItem({required this.item});

  final OutfitItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: item.color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Outfit card — single item in the carousel
// ---------------------------------------------------------------------------

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final OutfitItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        decoration: BoxDecoration(
          color: isSelected ? item.color.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? item.color
                : PWColors.navy.withValues(alpha: 0.1),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: item.color.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: PWColors.navy.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show asset thumbnail if available, else emoji
            if (item.assetPath != null)
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  item.assetPath!,
                  fit: BoxFit.contain,
                ),
              )
            else
              Text(item.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? item.color : PWColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Did You Know? micro-card
// ---------------------------------------------------------------------------

class _FactMicroCard extends StatelessWidget {
  const _FactMicroCard({
    required this.fact,
    required this.onDismiss,
  });

  final FashionFact fact;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PWColors.yellow.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Text(
                '\u{1F4A1}', // 💡
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Did you know?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: PWColors.navy.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fact.text,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PWColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.close_rounded,
                size: 18,
                color: PWColors.navy.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Debug position panel — dev mode only
// ---------------------------------------------------------------------------

class _DebugPositionPanel extends StatelessWidget {
  const _DebugPositionPanel({
    required this.isOpen,
    required this.onToggle,
    required this.shiftY,
    required this.scale,
    required this.onShiftYChanged,
    required this.onScaleChanged,
    this.itemLabel,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final double shiftY;
  final double scale;
  final String? itemLabel;
  final ValueChanged<double> onShiftYChanged;
  final ValueChanged<double> onScaleChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bug_report, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    itemLabel != null ? 'Debug: $itemLabel' : 'Debug Panel',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isOpen ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 52,
                        child: Text(
                          'shiftY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: shiftY.clamp(-0.5, 0.5),
                          min: -0.5,
                          max: 0.5,
                          divisions: 200,
                          onChanged: onShiftYChanged,
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text(
                          shiftY.toStringAsFixed(3),
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 52,
                        child: Text(
                          'scale',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: scale.clamp(0.3, 2.0),
                          min: 0.3,
                          max: 2.0,
                          divisions: 170,
                          onChanged: onScaleChanged,
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text(
                          scale.toStringAsFixed(3),
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (itemLabel != null)
                    SelectableText(
                      'shiftY: $shiftY, scale: $scale',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Colors.orange.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
