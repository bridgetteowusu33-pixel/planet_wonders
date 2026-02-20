import 'package:flutter/material.dart';

class HintButton extends StatelessWidget {
  const HintButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    required this.used,
    this.remaining = 0,
  });

  final bool enabled;
  final bool used;
  final int remaining;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final baseColor = used ? const Color(0xFF9FA8B7) : const Color(0xFF6F56E8);
    final label = used ? 'Hint Used' : 'Hint ($remaining)';

    return Semantics(
      button: true,
      label: 'Hint',
      child: SizedBox(
        height: 44,
        child: ElevatedButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: const Icon(Icons.lightbulb_rounded, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: baseColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }
}
