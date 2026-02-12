import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/world_data.dart';
import '../data/game_break_registry.dart';
import '../providers/memory_match_provider.dart';
import '../widgets/flip_card.dart';
import '../widgets/game_break_end_card.dart';

/// Full-screen Memory Match game.
///
/// 8 cards (4 pairs), country-themed emojis, calm animations.
/// Ends with a gentle "Nice break!" dialog — no scores, no pressure.
class MemoryMatchScreen extends ConsumerStatefulWidget {
  const MemoryMatchScreen({super.key, required this.countryId});

  final String countryId;

  @override
  ConsumerState<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends ConsumerState<MemoryMatchScreen> {
  bool _endShown = false;

  @override
  void initState() {
    super.initState();
    // Schedule setup for after the first frame so the provider is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memoryMatchProvider.notifier).setup(widget.countryId);
    });
  }

  Future<void> _showEndAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    showGameBreakEndCard(context);
  }

  String get _countryLabel {
    final country = findCountryById(widget.countryId);
    return country?.name ??
        (widget.countryId[0].toUpperCase() + widget.countryId.substring(1));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoryMatchProvider);
    final data =
        findMemoryMatchData(widget.countryId) ?? fallbackMemoryMatch;

    // Show end card once when completed.
    if (state.completed && !_endShown) {
      _endShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEndAfterDelay();
      });
    }

    return Scaffold(
      backgroundColor: data.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Top bar ──
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  ),
                  Expanded(
                    child: Text(
                      '$_countryLabel \u{00B7} Memory Match',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // balance the back button
                ],
              ),

              const SizedBox(height: 16),

              // ── Instructions ──
              Text(
                'Tap cards to find matching pairs!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PWColors.navy.withValues(alpha: 0.6),
                    ),
              ),

              const SizedBox(height: 20),

              // ── Card grid ──
              Expanded(
                child: state.cards.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.85,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final card in state.cards)
                            FlipCard(
                              card: card,
                              isRevealed:
                                  state.revealedIds.contains(card.id),
                              isMatched:
                                  state.matchedPairIds.contains(card.pairId),
                              onTap: () => ref
                                  .read(memoryMatchProvider.notifier)
                                  .flipCard(card.id),
                            ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
