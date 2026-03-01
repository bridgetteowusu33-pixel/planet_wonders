import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/pw_theme.dart';
import '../../world_explorer/data/world_data.dart';
import '../providers/sticker_provider.dart';
import 'sticker_cell.dart';
import 'sticker_detail_sheet.dart';

/// Full-screen page showing the player's sticker collection.
class StickerAlbumScreen extends ConsumerWidget {
  const StickerAlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stickerProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    // Mark all collected stickers as "seen" when the album is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stickerProvider.notifier).markAllSeen();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        title: Text(
          'My Sticker Album',
          style: GoogleFonts.baloo2(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: PWColors.navy,
      ),
      body: SafeArea(
        child: state.loading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, ref, state, isTablet),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    StickerState state,
    bool isTablet,
  ) {
    // Show "general" section first, then per-country sections.
    final countryIds = [
      if (state.countryIds.contains('general')) 'general',
      ...state.countryIds.where((id) => id != 'general'),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 20,
        vertical: 8,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 700 : 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress summary
              _ProgressCard(
                collected: state.collectedCount,
                total: state.totalCount,
                isTablet: isTablet,
              ),
              const SizedBox(height: 24),

              // Per-country sections
              for (final countryId in countryIds) ...[
                _CountrySection(
                  countryId: countryId,
                  state: state,
                  isTablet: isTablet,
                  onStickerTap: (sticker) {
                    if (state.isCollected(sticker.id)) {
                      ref.read(stickerProvider.notifier).markSeen(sticker.id);
                      showStickerDetailSheet(context, sticker: sticker);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.collected,
    required this.total,
    this.isTablet = false,
  });

  final int collected;
  final int total;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? collected / total : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PWColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Collected $collected of $total',
            style: TextStyle(
              fontSize: isTablet ? 18 : 15,
              fontWeight: FontWeight.w700,
              color: PWColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: isTablet ? 10 : 8,
              backgroundColor: PWColors.navy.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(PWColors.yellow),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CountrySection extends StatelessWidget {
  const _CountrySection({
    required this.countryId,
    required this.state,
    required this.onStickerTap,
    this.isTablet = false,
  });

  final String countryId;
  final StickerState state;
  final ValueChanged<dynamic> onStickerTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final isGeneral = countryId == 'general';
    final country = isGeneral ? null : findCountryById(countryId);
    final countryName = isGeneral
        ? 'Explorer Stickers'
        : (country?.name ??
            (countryId[0].toUpperCase() + countryId.substring(1)));
    final flag = isGeneral ? '\u{1F31F}' : (country?.flagEmoji ?? '\u{1F30D}');
    final stickers = state.stickersForCountry(countryId);
    final isUnlocked = isGeneral || (country?.isUnlocked ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country header
        Row(
          children: [
            Text(flag, style: TextStyle(fontSize: isTablet ? 28 : 24)),
            const SizedBox(width: 8),
            Text(
              countryName,
              style: TextStyle(
                fontSize: isTablet ? 20 : 17,
                fontWeight: FontWeight.w800,
                color: PWColors.navy,
              ),
            ),
            if (!isUnlocked) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.lock_rounded,
                size: 16,
                color: PWColors.navy.withValues(alpha: 0.3),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Sticker grid
        if (!isUnlocked)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: PWColors.navy.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PWColors.navy.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              'Explore $countryName to unlock stickers!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 15 : 13,
                fontWeight: FontWeight.w600,
                color: PWColors.navy.withValues(alpha: 0.4),
              ),
            ),
          )
        else
          Wrap(
            spacing: isTablet ? 16 : 12,
            runSpacing: isTablet ? 16 : 12,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              for (final sticker in stickers)
                StickerCell(
                  sticker: sticker,
                  isCollected: state.isCollected(sticker.id),
                  isNew: state.isNew(sticker.id),
                  isTablet: isTablet,
                  onTap: () => onStickerTap(sticker),
                ),
            ],
          ),
      ],
    );
  }
}
