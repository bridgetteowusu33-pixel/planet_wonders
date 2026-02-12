import 'dart:ui';

/// A single illustrated page inside a story.
class StoryPage {
  final String title;
  final String text;
  final String emoji; // placeholder until real illustrations are added
  final Color bgColor; // tinted background for the illustration area
  final String? fact; // optional "Did You Know?" text
  final String? factCategory; // Culture, History, Language, Art & Symbols

  const StoryPage({
    required this.title,
    required this.text,
    required this.emoji,
    required this.bgColor,
    this.fact,
    this.factCategory,
  });

  bool get hasFact => fact != null;
}

/// A complete country story made of sequential pages.
///
/// Data-driven: add a new Story to the story registry and the UI picks
/// it up — no screen changes needed.
class Story {
  final String countryId;
  final String title;
  final String badgeName; // e.g. "Ghana Story Explorer"
  final List<StoryPage> pages;

  const Story({
    required this.countryId,
    required this.title,
    required this.badgeName,
    required this.pages,
  });

  int get pageCount => pages.length;
}
