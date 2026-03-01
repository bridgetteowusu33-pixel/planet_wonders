import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/drawing_state.dart';
import '../providers/drawing_provider.dart';

class BrushTypeSelector extends ConsumerWidget {
  const BrushTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(drawingProvider.select((s) => s.currentBrushType));

    final chips = <Widget>[
      _BrushChip(
        label: 'Marker',
        active: current == BrushType.marker,
        onTap: () => ref.read(drawingProvider.notifier).setBrushType(BrushType.marker),
      ),
      _BrushChip(
        label: 'Crayon',
        active: current == BrushType.crayon,
        onTap: () => ref.read(drawingProvider.notifier).setBrushType(BrushType.crayon),
      ),
      _BrushChip(
        label: 'Soft',
        active: current == BrushType.softBrush,
        onTap: () => ref.read(drawingProvider.notifier).setBrushType(BrushType.softBrush),
      ),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }
}

class _BrushChip extends StatelessWidget {
  const _BrushChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? PWColors.blue.withValues(alpha: 0.18) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? PWColors.blue : PWColors.navy.withValues(alpha: 0.14),
            width: active ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? PWColors.blue : PWColors.navy,
          ),
        ),
      ),
    );
  }
}

