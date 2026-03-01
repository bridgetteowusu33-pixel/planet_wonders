import '../../cooking_game/v2/widgets/chef_avatar.dart';

/// Maps the controller's string mood to [ChefAvatarMood].
ChefAvatarMood moodFromString(String mood) => switch (mood) {
      'excited' => ChefAvatarMood.excited,
      'proud' => ChefAvatarMood.proud,
      'thinking' => ChefAvatarMood.thinking,
      _ => ChefAvatarMood.happy,
    };
