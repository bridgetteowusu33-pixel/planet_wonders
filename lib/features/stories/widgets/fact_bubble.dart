import 'package:flutter/material.dart';

import '../../../core/theme/pw_theme.dart';

/// A "Did You Know?" bubble that slides in when tapped.
///
/// Designed to be light and optional — kids can read it or skip it.
class FactBubble extends StatefulWidget {
  const FactBubble({
    super.key,
    required this.fact,
    this.category,
  });

  final String fact;
  final String? category;

  @override
  State<FactBubble> createState() => _FactBubbleState();
}

class _FactBubbleState extends State<FactBubble> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: PWColors.mint.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PWColors.mint.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — always visible
            Row(
              children: [
                const Text('\u{1F4A1}', style: TextStyle(fontSize: 18)), // 💡
                const SizedBox(width: 8),
                Text(
                  'Did You Know?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PWColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: PWColors.navy,
                ),
              ],
            ),

            // Fact text — shown when expanded
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: PWColors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.category!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: PWColors.navy.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    Text(
                      widget.fact,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
