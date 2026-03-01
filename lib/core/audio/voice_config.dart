/// Configuration for ElevenLabs voice mapping per country character.
class VoiceConfig {
  const VoiceConfig({
    required this.voiceId,
    required this.voiceName,
    required this.description,
  });

  /// ElevenLabs voice ID.
  final String voiceId;

  /// Display name shown in UI (e.g. "Afia").
  final String voiceName;

  /// Short description of the voice character.
  final String description;
}

/// Per-country voice mapping. Update voice IDs after selecting voices
/// in the ElevenLabs dashboard.
const countryVoices = <String, VoiceConfig>{
  'ghana': VoiceConfig(
    voiceId: 'TBD',
    voiceName: 'Afia',
    description: 'Young Ghanaian storyteller',
  ),
  'usa': VoiceConfig(
    voiceId: 'TBD',
    voiceName: 'Ava',
    description: 'Young American storyteller',
  ),
  'nigeria': VoiceConfig(
    voiceId: 'TBD',
    voiceName: 'Adetutu',
    description: 'Young Nigerian storyteller',
  ),
  'uk': VoiceConfig(
    voiceId: 'TBD',
    voiceName: 'Narrator',
    description: 'British storyteller for twins',
  ),
};
