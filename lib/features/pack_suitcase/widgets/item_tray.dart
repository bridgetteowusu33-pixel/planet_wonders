import 'package:flutter/material.dart';

import '../models/pack_item.dart';
import 'pack_item_card.dart';

/// Horizontal scrolling tray of [PackItemCard]s.
class ItemTray extends StatelessWidget {
  const ItemTray({
    super.key,
    required this.items,
    required this.packedIds,
    required this.onTapItem,
    this.isTablet = false,
  });

  final List<PackItem> items;
  final Set<String> packedIds;
  final ValueChanged<String> onTapItem;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: isTablet ? 150 : 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
          itemCount: items.length,
          separatorBuilder: (_, _) => SizedBox(width: isTablet ? 14 : 8),
          itemBuilder: (_, index) {
            final item = items[index];
            final packed = packedIds.contains(item.id);
            return PackItemCard(
              item: item,
              isPacked: packed,
              isTablet: isTablet,
              onTap: packed ? null : () => onTapItem(item.id),
            );
          },
        ),
      ),
    );
  }
}
