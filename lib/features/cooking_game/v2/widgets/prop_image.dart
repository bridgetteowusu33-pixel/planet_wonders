import 'package:flutter/material.dart';

/// Renders an illustrated prop PNG for the given country,
/// falling back to an emoji when the asset is missing.
class PropImage extends StatelessWidget {
  const PropImage({
    super.key,
    required this.countryId,
    required this.propName,
    required this.fallbackEmoji,
    this.size = 64,
  });

  final String countryId;
  final String propName;
  final String fallbackEmoji;
  final double size;

  String get _assetPath =>
      'assets/cooking/v2/$countryId/props/$propName.webp';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      cacheWidth: (size * 2).toInt(),
      errorBuilder: (_, _, _) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            fallbackEmoji,
            style: TextStyle(fontSize: size * 0.7),
          ),
        ),
      ),
    );
  }
}
