import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/pack_item.dart';
import '../models/pack_suitcase_state.dart';
import '../providers/pack_suitcase_controller.dart';
import '../widgets/item_tray.dart';
import '../widgets/pack_character_bubble.dart';
import '../widgets/pack_progress_bar.dart';
import '../widgets/suitcase_widget.dart';
import 'mood_helper.dart';

/// The active drag-and-drop packing phase.
class PackGameplayScreen extends ConsumerStatefulWidget {
  const PackGameplayScreen({super.key, required this.countryId});

  final String countryId;

  @override
  ConsumerState<PackGameplayScreen> createState() =>
      _PackGameplayScreenState();
}

class _PackGameplayScreenState extends ConsumerState<PackGameplayScreen> {
  late List<PackItem> _shuffledItems;
  bool _hasShuffled = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packSuitcaseProvider);
    final pack = state.pack;
    if (pack == null) return const SizedBox.shrink();

    // Shuffle once.
    if (!_hasShuffled) {
      _shuffledItems = [...pack.correctItems, ...pack.distractors]
        ..shuffle(math.Random());
      _hasShuffled = true;
    }

    // Compute packed items list for the suitcase display.
    final packedItems = pack.correctItems
        .where((i) => state.packedItemIds.contains(i.id))
        .toList(growable: false);

    final hasTimer = state.timerTotalSec > 0;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: isTablet ? 16 : 8),

          // Progress + optional timer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  PackProgressBar(
                    packed: state.packedCount,
                    required_: state.requiredCount,
                    isTablet: isTablet,
                  ),
                  if (hasTimer) ...[
                    const SizedBox(height: 8),
                    _timerBar(state, isTablet),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 12),

          // Suitcase (center)
          Expanded(
            child: Center(
              child: SuitcaseWidget(
                isOpen: true,
                packedItems: packedItems,
                onAcceptItem: (id) =>
                    ref.read(packSuitcaseProvider.notifier).dropItem(id),
                isTablet: isTablet,
              ),
            ),
          ),

          // Character bubble
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: PackCharacterBubble(
                countryId: widget.countryId,
                line: state.characterLine,
                mood: moodFromString(state.characterMood),
                isTablet: isTablet,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 14 : 10),

          // Item tray
          ItemTray(
            items: _shuffledItems,
            packedIds: state.packedItemIds,
            onTapItem: (id) =>
                ref.read(packSuitcaseProvider.notifier).tapToPack(id),
            isTablet: isTablet,
          ),
          SizedBox(height: isTablet ? 16 : 8),
        ],
      ),
    );
  }

  Widget _timerBar(PackSuitcaseState state, bool isTablet) {
    final fraction = state.timerFraction;
    final color = fraction > 0.5
        ? PWColors.mint
        : fraction > 0.25
            ? PWColors.yellow
            : PWColors.coral;

    return Column(
      children: [
        Text(
          '${state.timerRemainingSec}s',
          style: TextStyle(
            fontSize: isTablet ? 16 : 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: isTablet ? 8 : 6,
            backgroundColor: PWColors.navy.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
