import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart' as rive;

/// Renders a Rive (`.riv`) animation if one exists at [asset], and falls
/// back to [fallback] otherwise.
///
/// No `.riv` file ships with this project by default — hand-authoring a
/// binary Rive file outside the Rive editor isn't something that can be
/// done reliably, so every animated scene in the app (bees, honeycomb
/// fill, breathing flower) has a fully-functional Flutter-native
/// implementation as its [fallback]. Once you export real animations from
/// https://rive.app, drop them at the paths below and they'll be picked
/// up automatically with zero code changes elsewhere:
///
///   assets/rive/bee_flight.riv       — looping bee flight/wing flutter
///   assets/rive/honeycomb_fill.riv   — state-machine driven honey fill
///   assets/rive/breathing_flower.riv — inhale/exhale bloom cycle
///
/// Remember to also list the exact file in `pubspec.yaml` under
/// `flutter: assets:` (the `assets/rive/` directory is already declared).
class RiveOrFallback extends StatefulWidget {
  const RiveOrFallback({
    super.key,
    required this.asset,
    required this.fallback,
    this.stateMachineName,
    this.artboard,
  });

  final String asset;
  final Widget fallback;
  final String? stateMachineName;
  final String? artboard;

  @override
  State<RiveOrFallback> createState() => _RiveOrFallbackState();
}

class _RiveOrFallbackState extends State<RiveOrFallback> {
  late final Future<bool> _availability;

  @override
  void initState() {
    super.initState();
    _availability = _checkAsset();
  }

  Future<bool> _checkAsset() async {
    try {
      await rootBundle.load(widget.asset);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _availability,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return rive.RiveAnimation.asset(
            widget.asset,
            stateMachines: widget.stateMachineName != null ? [widget.stateMachineName!] : const [],
            artboard: widget.artboard,
            fit: BoxFit.contain,
          );
        }
        return widget.fallback;
      },
    );
  }
}
