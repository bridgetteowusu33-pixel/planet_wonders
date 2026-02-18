import 'package:flutter/foundation.dart';

@immutable
class CookingBadge {
  const CookingBadge({
    required this.id,
    required this.title,
    required this.country,
    required this.iconAsset,
  });

  final String id;
  final String title;
  final String country;
  final String iconAsset;
}
