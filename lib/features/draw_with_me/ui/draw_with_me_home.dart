// File: lib/features/draw_with_me/ui/draw_with_me_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pw_theme.dart';
import '../engine/trace_engine.dart';
import '../models/trace_shape.dart';
import 'difficulty_selector.dart';

class DrawWithMeHomeScreen extends ConsumerStatefulWidget {
  const DrawWithMeHomeScreen({super.key});

  @override
  ConsumerState<DrawWithMeHomeScreen> createState() =>
      _DrawWithMeHomeScreenState();
}

class _DrawWithMeHomeScreenState extends ConsumerState<DrawWithMeHomeScreen> {
  bool _loading = true;
  String? _error;

  List<TracePack> _packs = <TracePack>[];
  final Map<String, List<TraceShape>> _shapesByPack =
      <String, List<TraceShape>>{};

  String? _selectedPackId;
  TraceDifficulty _difficulty = TraceDifficulty.easy;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final engine = ref.read(traceEngineProvider);
      final packs = await engine.loadPacks();
      final shapesByPack = <String, List<TraceShape>>{};

      for (final pack in packs) {
        shapesByPack[pack.id] = await engine.loadShapesForPack(pack.id);
      }

      if (!mounted) return;

      setState(() {
        _packs = packs;
        _shapesByPack.clear();
        _shapesByPack.addAll(shapesByPack);
        _selectedPackId = packs.isNotEmpty ? packs.first.id : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TracePack? selectedPack;
    for (final pack in _packs) {
      if (pack.id == _selectedPackId) {
        selectedPack = pack;
        break;
      }
    }
    final shapes = selectedPack == null
        ? const <TraceShape>[]
        : (_shapesByPack[selectedPack.id] ?? const <TraceShape>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw With Me'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _ErrorState(error: _error!, onRetry: _loadData)
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trace & Create',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trace the lines, then decorate your masterpiece.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PWColors.navy.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DifficultySelector(
                      value: _difficulty,
                      onChanged: (difficulty) {
                        setState(() => _difficulty = difficulty);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _packs.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final pack = _packs[index];
                          final selected = pack.id == _selectedPackId;
                          return ChoiceChip(
                            selected: selected,
                            showCheckmark: false,
                            backgroundColor: pack.color.withValues(alpha: 0.3),
                            selectedColor: pack.color,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_iconForPack(pack.icon), size: 16),
                                const SizedBox(width: 6),
                                Text(pack.title),
                              ],
                            ),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2F3A4A),
                            ),
                            onSelected: (_) {
                              setState(() => _selectedPackId = pack.id);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        itemCount: shapes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.08,
                            ),
                        itemBuilder: (context, index) {
                          final shape = shapes[index];
                          return _ShapeCard(
                            shape: shape,
                            onTap: () {
                              context.push(
                                '/draw-with-me/trace/${shape.packId}/${shape.id}?difficulty=${_difficulty.name}',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  IconData _iconForPack(String iconId) {
    switch (iconId) {
      case 'pets':
        return Icons.pets_rounded;
      case 'toys':
        return Icons.toys_rounded;
      default:
        return Icons.draw_rounded;
    }
  }
}

class _ShapeCard extends StatelessWidget {
  const _ShapeCard({required this.shape, required this.onTap});

  final TraceShape shape;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFE7F0FA),
                ),
                child: Center(
                  child: Text(
                    shape.thumbnailEmoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                shape.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${shape.segments.length} trace steps',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PWColors.navy.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              'Could not load trace packs',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
