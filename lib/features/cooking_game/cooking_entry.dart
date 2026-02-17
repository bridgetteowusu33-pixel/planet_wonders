import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/pw_theme.dart';

/// Builds canonical route for the cooking mini-game.
String cookingRoute({
  String source = 'games',
  String view = 'hub',
  String? countryId,
  String? recipeId,
}) {
  final query = <String, String>{
    'source': source,
    'view': view,
  };
  if (countryId != null && countryId.isNotEmpty) {
    query['countryId'] = countryId;
  }
  if (recipeId != null && recipeId.isNotEmpty) {
    query['recipeId'] = recipeId;
  }
  return Uri(path: '/cooking', queryParameters: query).toString();
}

/// Launch helper for the unified cooking hub.
Future<void> openCookingHub(
  BuildContext context, {
  String source = 'games',
  String? countryId,
  String? recipeId,
}) async {
  final route = cookingRoute(
    source: source,
    view: 'hub',
    countryId: countryId,
    recipeId: recipeId,
  );
  context.push(route);
}

/// Launch helper for free-cook gameplay.
Future<void> openCookingGame(
  BuildContext context, {
  String source = 'games',
  String? countryId,
  String? recipeId,
}) async {
  final route = cookingRoute(
    source: source,
    view: 'play',
    countryId: countryId,
    recipeId: recipeId,
  );
  context.push(route);
}

/// Launch helper for recipe story mode.
Future<void> openCookingRecipeStory(
  BuildContext context, {
  String source = 'games',
  String? countryId,
  String? recipeId,
}) async {
  final resolvedCountryId = _resolveCountryId(countryId, recipeId);
  if (resolvedCountryId != null) {
    final storyRecipeId = _normalizeStoryRecipeId(recipeId);
    final path = storyRecipeId == null
        ? '/recipe-story/$resolvedCountryId'
        : '/recipe-story/$resolvedCountryId/$storyRecipeId';
    final route = Uri(
      path: path,
      queryParameters: {'source': source},
    ).toString();
    context.push(route);
    return;
  }

  final route = cookingRoute(
    source: source,
    view: 'story',
    countryId: countryId,
    recipeId: recipeId,
  );
  context.push(route);
}

String? _resolveCountryId(String? countryId, String? recipeId) {
  if (countryId != null && countryId.isNotEmpty) {
    return countryId;
  }
  if (recipeId == null || recipeId.isEmpty) {
    return null;
  }
  final splitIndex = recipeId.indexOf('_');
  if (splitIndex <= 0) {
    return null;
  }
  return recipeId.substring(0, splitIndex);
}

String? _normalizeStoryRecipeId(String? recipeId) {
  if (recipeId == null || recipeId.isEmpty) {
    return null;
  }
  if (recipeId == 'ghana_jollof') {
    return 'ghana_jollof_story';
  }
  if (recipeId.endsWith('_story')) {
    return recipeId;
  }
  final splitIndex = recipeId.indexOf('_');
  if (splitIndex <= 0 || splitIndex + 1 >= recipeId.length) {
    return recipeId;
  }
  return recipeId.substring(splitIndex + 1);
}

/// Entry widget for Food pages.
///
/// Example integration:
/// `CookingEntryButton(recipeId: 'ghana_jollof')`
class CookingEntryButton extends StatelessWidget {
  const CookingEntryButton({
    super.key,
    required this.recipeId,
    this.countryId,
    this.source = 'food',
    this.openView = 'hub',
    this.label = 'COOK IT!',
  });

  final String recipeId;
  final String? countryId;
  final String source;
  final String openView;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        if (openView == 'play') {
          openCookingGame(
            context,
            source: source,
            countryId: countryId,
            recipeId: recipeId,
          );
          return;
        }
        if (openView == 'story') {
          openCookingRecipeStory(
            context,
            source: source,
            countryId: countryId,
            recipeId: recipeId,
          );
          return;
        }
        openCookingHub(
          context,
          source: source,
          countryId: countryId,
          recipeId: recipeId,
        );
      },
      icon: const Icon(Icons.soup_kitchen_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        backgroundColor: PWColors.mint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
