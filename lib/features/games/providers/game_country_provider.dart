import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../world_explorer/data/world_data.dart';

/// Tracks which country is selected in the centralized Games Hub.
///
/// Defaults to 'ghana'. The Games Hub country picker updates this.
final selectedGameCountryProvider =
    NotifierProvider<SelectedGameCountryNotifier, String>(
        SelectedGameCountryNotifier.new);

class SelectedGameCountryNotifier extends Notifier<String> {
  @override
  String build() => 'ghana';

  void select(String countryId) => state = countryId;
}

/// Returns all unlocked countries (for the country picker chips).
List<({String id, String name, String flag})> get unlockedCountries {
  return worldContinents
      .expand((c) => c.countries)
      .where((c) => c.isUnlocked)
      .map((c) => (id: c.id, name: c.name, flag: c.flagEmoji))
      .toList();
}
