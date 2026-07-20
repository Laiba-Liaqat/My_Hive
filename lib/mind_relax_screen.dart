import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'services/audio_service.dart';
import 'theme/app_theme.dart';
import 'widgets/glass_container.dart';

enum BreathPhase { inhale, hold, exhale, rest }

class MindRelaxScreen extends StatefulWidget {
  const MindRelaxScreen({super.key});
  
  @override
  State<MindRelaxScreen> createState() => _MindRelaxScreenState();
}

class _MindRelaxScreenState extends State<MindRelaxScreen> {
  String? _playingTrack;
  late final AudioService _audioService;

  @override
  void initState() {
    super.initState();
    // Grab the audio service safely when the screen loads for safe disposal
    _audioService = context.read<AudioService>();
  }

  @override
  void dispose() {
    // Safely stop audio without relying on the current context tree
    if (_playingTrack != null) {
      _audioService.stopAmbient();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Mind Relax', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
          const Text(
            'A quiet corner of the hive, just for breathing.',
            style: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                BreathingFlower(reduceMotion: settings.reduceMotion, soundOn: settings.soundEffects),
                const SizedBox(height: 16),
                const Text(
                  'Follow the bloom — in as it opens, out as it closes.',
                  style: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w600, fontSize: 12.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Ambient Soundscapes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Play something soft in the background — stays on only in this space.',
            style: TextStyle(color: HiveColors.wilted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          
          // Updated Volume Card with stop controls
          _VolumeCard(
            settings: settings,
            isPlaying: _playingTrack != null,
            onStop: _stopTrack,
          ),
          
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.35,
            children: [
              for (final track in AmbientTrack.all)
                _TrackTile(
                  track: track,
                  playing: _playingTrack == track.id,
                  onTap: () => _toggleTrack(track.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTrack(String id) async {
    final audio = context.read<AudioService>();
    final settings = context.read<SettingsProvider>();
    
    if (_playingTrack == id) {
      await audio.stopAmbient();
      setState(() => _playingTrack = null);
    } else {
      await audio.startAmbient(id, volume: settings.musicVolume);
      setState(() => _playingTrack = id);
    }
  }

  Future<void> _stopTrack() async {
    await _audioService.stopAmbient();
    setState(() => _playingTrack = null);
  }
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard({
    required this.settings,
    required this.isPlaying,
    required this.onStop,
  });
  
  final SettingsProvider settings;
  final bool isPlaying;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          const Text('🔈', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Slider(
              value: settings.musicVolume,
              activeColor: HiveColors.honeyGold,
              inactiveColor: HiveColors.combCream,
              onChanged: (v) {
                settings.setMusicVolume(v);
                context.read<AudioService>().setMusicVolume(v);
              },
            ),
          ),
          const Text('🔊', style: TextStyle(fontSize: 16)),
          
          // Stop Button animations
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isPlaying
                ? Row(
                    children: [
                      const SizedBox(width: 8),
                      Container(width: 1.5, height: 24, color: HiveColors.combCream),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.stop_circle_rounded, size: 28),
                        color: Colors.redAccent.withOpacity(0.8),
                        onPressed: onStop,
                        tooltip: 'Stop Ambient Sound',
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.track, required this.playing, required this.onTap});
  
  final AmbientTrack track;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: playing ? null : Theme.of(context).cardTheme.color,
          gradient: playing ? const LinearGradient(colors: [HiveColors.honeyGold, HiveColors.honeyDeep]) : null,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: playing ? HiveColors.honeyGold : Colors.transparent, width: 3.5),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(track.emoji, style: const TextStyle(fontSize: 22)),
                  Text(track.name, style: TextStyle(fontWeight: FontWeight.w800, color: playing ? Colors.white : null)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreathingFlower extends StatefulWidget {
  const BreathingFlower({super.key, this.reduceMotion = false, this.soundOn = true});
  
  final bool reduceMotion;
  final bool soundOn;
  
  @override
  State<BreathingFlower> createState() => _BreathingFlowerState();
}

class _BreathingFlowerState extends State<BreathingFlower> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  BreathPhase _phase = BreathPhase.inhale;
  bool _running = false;
  static const _pattern = [4, 4, 6, 2];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _running = true);
    _runPhase(BreathPhase.inhale);
  }

  void _stop() {
    _controller.stop();
    setState(() => _running = false);
  }

  void _runPhase(BreathPhase phase) {
    if (!mounted || !_running) return;
    setState(() => _phase = phase);
    final seconds = _pattern[phase.index];
    _controller.duration = Duration(seconds: widget.reduceMotion ? (seconds * 0.6).round() : seconds);
    
    if (phase == BreathPhase.inhale) {
      _controller.forward(from: 0);
    } else if (phase == BreathPhase.exhale) {
      _controller.reverse(from: 1);
    }

    Future.delayed(Duration(seconds: seconds), () {
      if (!mounted || !_running) return;
      _runPhase(BreathPhase.values[(phase.index + 1) % BreathPhase.values.length]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final scale = 0.6 + (_controller.value * 0.55);
            return Transform.scale(
              scale: scale,
              child: const Text('🌸', style: TextStyle(fontSize: 90)),
            );
          },
        ),
        ElevatedButton(
          onPressed: _running ? _stop : _start,
          child: Text(_running ? 'Stop Session' : 'Start Breathing'),
        ),
      ],
    );
  }
}