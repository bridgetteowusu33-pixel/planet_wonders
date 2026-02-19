import 'package:flutter/material.dart';

import '../../../../core/theme/pw_theme.dart';

class CulturePanel extends StatefulWidget {
  const CulturePanel({super.key, required this.fact});

  final String fact;

  @override
  State<CulturePanel> createState() => _CulturePanelState();
}

class _CulturePanelState extends State<CulturePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant CulturePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fact != oldWidget.fact) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = _factIcon(widget.fact);

    return RepaintBoundary(
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(
          opacity: _controller,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFFFF6DF), Color(0xFFFFEDCA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PWColors.yellow.withValues(alpha: 0.6)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: PWColors.yellow.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  alignment: Alignment.center,
                  child: Text(icon, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '🇬🇭 Did you know?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: PWColors.coral.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.fact,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _factIcon(String fact) {
    final lower = fact.toLowerCase();
    if (lower.contains('family')) return '👨‍👩‍👧‍👦';
    if (lower.contains('rice')) return '🍚';
    if (lower.contains('spice') || lower.contains('pepper')) return '🌶️';
    if (lower.contains('steam') || lower.contains('cook')) return '♨️';
    return '💡';
  }
}
