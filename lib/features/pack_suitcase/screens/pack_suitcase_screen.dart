import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../achievements/providers/achievement_provider.dart';
import '../../learning_report/models/learning_stats.dart';
import '../../learning_report/providers/learning_stats_provider.dart';
import '../../stickers/providers/sticker_provider.dart';
import '../data/pack_catalog_loader.dart';
import '../models/pack_difficulty.dart';
import '../models/pack_suitcase_state.dart';
import '../models/suitcase_pack.dart';
import '../providers/pack_suitcase_controller.dart';
import 'pack_gate_screen.dart';
import 'pack_gameplay_screen.dart';
import 'pack_retry_screen.dart';
import 'pack_success_screen.dart';

/// Top-level shell for Pack the Suitcase.
///
/// Flow: gate → playing → success / timeUp.
class PackSuitcaseScreen extends ConsumerStatefulWidget {
  const PackSuitcaseScreen({
    super.key,
    required this.countryId,
    this.packId,
  });

  final String countryId;
  final String? packId;

  @override
  ConsumerState<PackSuitcaseScreen> createState() => _PackSuitcaseScreenState();
}

class _PackSuitcaseScreenState extends ConsumerState<PackSuitcaseScreen> {
  SuitcasePack? _pack;
  PackDifficulty _selectedDifficulty = PackDifficulty.easy;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPack();
  }

  Future<void> _loadPack() async {
    SuitcasePack? found;

    if (widget.packId != null) {
      found = await PackCatalogLoader.findPack(widget.packId!);
    }

    found ??= (await PackCatalogLoader.packsForCountry(widget.countryId))
        .firstOrNull;

    if (mounted) {
      setState(() {
        _pack = found;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pack = _pack;
    if (pack == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No packs found for ${widget.countryId}.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    final state = ref.watch(packSuitcaseProvider);

    // Log achievement + learning report on success.
    ref.listen(packSuitcaseProvider, (prev, next) {
      if (prev?.phase != PackPhase.success &&
          next.phase == PackPhase.success) {
        ref.read(achievementProvider.notifier).markPackSuitcaseCompleted(
              countryId: pack.countryId,
              packId: pack.packId,
              wrongDrops: next.wrongDropCount,
            );
        ref.read(learningStatsProvider.notifier).logActivity(
              ActivityLogEntry(
                id: '${DateTime.now().millisecondsSinceEpoch}',
                type: ActivityType.game,
                label: 'Pack Suitcase: ${pack.destination}',
                countryId: pack.countryId,
                timestamp: DateTime.now(),
                emoji: '\u{1F9F3}', // 🧳
              ),
            );
        ref.read(stickerProvider.notifier).checkAndAward(
              conditionType: 'pack_suitcase_completed',
              countryId: pack.countryId,
            );
      }
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF8EDBFF),
              Color(0xFFBDEBFF),
              Color(0xFFE6F9FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Phase content.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _buildPhase(state, pack),
            ),

            // Back button.
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase(PackSuitcaseState state, SuitcasePack pack) {
    return switch (state.phase) {
      PackPhase.gate => PackGateScreen(
          key: const ValueKey<PackPhase>(PackPhase.gate),
          pack: pack,
          difficulty: _selectedDifficulty,
          onDifficultyChanged: (d) =>
              setState(() => _selectedDifficulty = d),
          onStart: () {
            ref
                .read(packSuitcaseProvider.notifier)
                .startGame(pack, _selectedDifficulty);
          },
        ),
      PackPhase.playing => PackGameplayScreen(
          key: const ValueKey<PackPhase>(PackPhase.playing),
          countryId: widget.countryId,
        ),
      PackPhase.success => PackSuccessScreen(
          key: const ValueKey<PackPhase>(PackPhase.success),
          pack: pack,
          wrongDropCount: state.wrongDropCount,
        ),
      PackPhase.timeUp => PackRetryScreen(
          key: const ValueKey<PackPhase>(PackPhase.timeUp),
          pack: pack,
          onRetry: () {
            ref.read(packSuitcaseProvider.notifier).retry();
          },
        ),
    };
  }
}
