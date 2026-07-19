import 'package:audioplayers/audioplayers.dart';

/// Central place for every sound the hive makes.
///
/// Two independent players are used on purpose: [_sfxPlayer] fires short,
/// low-latency one-shot effects (taps, chimes, honey drips) without
/// interrupting [_musicPlayer], which loops a soothing ambient focus track
/// in the background for as long as the user has it enabled.
///
/// All sample files are bundled under `assets/sounds/` — see the README
/// for how to swap in your own licensed music/SFX.
class AudioService {
  AudioService() {
    _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _musicPlaying = false;
  bool get isMusicPlaying => _musicPlaying;

  Future<void> _playSfx(String fileName, {double volume = 0.8}) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/$fileName'), volume: volume);
    } catch (_) {
      // Audio is a nice-to-have — never let a playback failure interrupt focus.
    }
  }

  Future<void> playTap() => _playSfx('tap.wav', volume: 0.5);
  Future<void> playSuccess() => _playSfx('success.wav', volume: 0.85);
  Future<void> playFail() => _playSfx('fail.wav', volume: 0.7);
  Future<void> playHoneyDrop() => _playSfx('honey_drop.wav', volume: 0.6);
  Future<void> playNotification() => _playSfx('notification.wav', volume: 0.7);
  Future<void> playBreatheIn() => _playSfx('breathe_in.wav', volume: 0.5);
  Future<void> playBreatheOut() => _playSfx('breathe_out.wav', volume: 0.5);

  /// Starts (or swaps to) the given ambient track by id, looping.
  /// Shared by the Focus timer's ambient music and the Mind Relax
  /// soundscape library, since both are just "loop this file quietly".
  Future<void> startAmbient(String trackId, {double volume = 0.85}) async {
    final fileName = _ambientFile(trackId);
    if (_musicPlaying && _currentTrackId == trackId) {
      await setMusicVolume(volume);
      return;
    }
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setVolume(volume);
      await _musicPlayer.play(AssetSource('sounds/$fileName'));
      _musicPlaying = true;
      _currentTrackId = trackId;
    } catch (_) {
      // Ignore — ambient music is optional atmosphere, not core functionality.
    }
  }

  Future<void> startFocusMusic({double volume = 0.85}) => startAmbient('focus', volume: volume);

  Future<void> stopFocusMusic() => stopAmbient();

  Future<void> stopAmbient() async {
    if (!_musicPlaying) return;
    await _musicPlayer.stop();
    _musicPlaying = false;
    _currentTrackId = null;
  }

  Future<void> setMusicVolume(double volume) async {
    await _musicPlayer.setVolume(volume);
  }

  String? _currentTrackId;
  String? get currentTrackId => _currentTrackId;

  String _ambientFile(String trackId) {
    switch (trackId) {
      case 'focus':
        return 'focus_ambient_loop.wav';
      case 'rain':
        return 'ambient_rain.wav';
      case 'ocean':
        return 'ambient_ocean.wav';
      case 'forest':
        return 'ambient_forest.wav';
      default:
        return 'focus_ambient_loop.wav';
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}

/// Static catalogue of ambient soundscapes available in the Mind Relax
/// library and the Focus timer's background music picker.
class AmbientTrack {
  final String id;
  final String name;
  final String emoji;

  const AmbientTrack({required this.id, required this.name, required this.emoji});

  static const List<AmbientTrack> all = [
    AmbientTrack(id: 'focus', name: 'Hive Hum', emoji: '🐝'),
    AmbientTrack(id: 'rain', name: 'Soft Rain', emoji: '🌧️'),
    AmbientTrack(id: 'ocean', name: 'Ocean Waves', emoji: '🌊'),
    AmbientTrack(id: 'forest', name: 'Forest Morning', emoji: '🌲'),
  ];
}
