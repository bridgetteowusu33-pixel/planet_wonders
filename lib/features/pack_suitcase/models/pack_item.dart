/// A single item that can be packed (correct or distractor).
class PackItem {
  const PackItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.funFact = '',
    this.assetPath,
  });

  final String id;
  final String name;
  final String emoji;
  final String funFact;
  final String? assetPath;

  factory PackItem.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?)?.trim() ?? '';
    final name = (json['name'] as String?)?.trim() ?? '';
    final emoji = (json['emoji'] as String?)?.trim() ?? '\u{1F4E6}'; // 📦

    assert(id.isNotEmpty, 'PackItem id must not be empty');
    assert(name.isNotEmpty, 'PackItem name must not be empty');

    return PackItem(
      id: id,
      name: name,
      emoji: emoji,
      funFact: (json['funFact'] as String?)?.trim() ?? '',
      assetPath: _optString(json['assetPath']),
    );
  }
}

String? _optString(Object? raw) {
  if (raw is! String) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;
  return value;
}
