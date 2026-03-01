import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';
import '../models/pack_item.dart';

/// Suitcase DragTarget — items are dropped here.
///
/// Shows an open-state illustration during gameplay, closed on success.
/// Packed item emojis appear inside the suitcase.
class SuitcaseWidget extends StatefulWidget {
  const SuitcaseWidget({
    super.key,
    required this.isOpen,
    required this.packedItems,
    required this.onAcceptItem,
    this.isTablet = false,
  });

  final bool isOpen;
  final List<PackItem> packedItems;
  final ValueChanged<String> onAcceptItem;
  final bool isTablet;

  @override
  State<SuitcaseWidget> createState() => _SuitcaseWidgetState();
}

class _SuitcaseWidgetState extends State<SuitcaseWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) {
          setState(() => _isHovering = true);
          return true;
        },
        onLeave: (_) => setState(() => _isHovering = false),
        onAcceptWithDetails: (details) {
          setState(() => _isHovering = false);
          widget.onAcceptItem(details.data);
        },
        builder: (context, candidateData, rejectedData) {
          final t = widget.isTablet;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: t ? 300 : 220,
            height: t ? 270 : 200,
            decoration: BoxDecoration(
              color: _isHovering
                  ? PWColors.yellow.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovering
                    ? PWColors.yellow
                    : PWColors.navy.withValues(alpha: 0.15),
                width: _isHovering ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovering
                      ? PWColors.yellow.withValues(alpha: 0.3)
                      : PWColors.navy.withValues(alpha: 0.08),
                  blurRadius: _isHovering ? 18 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Suitcase emoji / image
                _buildSuitcaseImage(),
                if (widget.isOpen && widget.packedItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Drag items here!',
                      style: TextStyle(
                        fontSize: widget.isTablet ? 16 : 13,
                        fontWeight: FontWeight.w600,
                        color: PWColors.navy.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                if (widget.packedItems.isNotEmpty) _buildPackedItems(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuitcaseImage() {
    final asset = widget.isOpen
        ? 'assets/games/pack_suitcase/ui/suitcase_open.png'
        : 'assets/games/pack_suitcase/ui/suitcase_closed.png';

    final imgSize = widget.isTablet ? 110.0 : 80.0;
    return Image.asset(
      asset,
      width: imgSize,
      height: imgSize,
      errorBuilder: (_, _, _) => Text(
        widget.isOpen ? '\u{1F9F3}' : '\u{1F4BC}', // 🧳 or 💼
        style: TextStyle(fontSize: widget.isTablet ? 72 : 54),
      ),
    );
  }

  Widget _buildPackedItems() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        alignment: WrapAlignment.center,
        children: widget.packedItems
            .map((item) => Text(
                  item.emoji,
                  style: TextStyle(fontSize: widget.isTablet ? 26 : 20),
                ))
            .toList(),
      ),
    );
  }
}
