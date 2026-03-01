/// Playback state for the narration service.
enum NarrationState {
  /// No audio playing.
  idle,

  /// Loading audio asset.
  loading,

  /// Audio is currently playing.
  playing,

  /// An error occurred during playback.
  error,
}
