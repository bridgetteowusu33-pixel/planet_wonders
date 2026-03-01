/// Typed pot face states for the V2 cooking game.
///
/// Each state maps to both a PNG asset path (for illustrated mode)
/// and a fallback emoji string (for non-illustrated countries).
enum PotFaceState {
  idle('\u{1F60A}'),       // 😊
  happy('\u{1F604}'),      // 😄
  surprised('\u{1F62E}'),  // 😮
  stir('\u{1F606}'),       // 😆
  yum('\u{1F924}'),        // 🤤
  spicy('\u{1F975}'),      // 🥵
  delicious('\u{1F60B}'),  // 😋
  love('\u{1F60D}'),       // 😍
  party('\u{1F973}'),      // 🥳
  worried('\u{1F61F}');    // 😟

  const PotFaceState(this.fallbackEmoji);

  /// Emoji string to show when illustration is unavailable.
  final String fallbackEmoji;

  /// PNG asset path for the given country.
  String assetPath(String countryId) =>
      'assets/cooking/v2/$countryId/pot/pot_$name.webp';
}
