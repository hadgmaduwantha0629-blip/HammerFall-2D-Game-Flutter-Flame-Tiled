import 'package:flutter/material.dart';

import 'audio_service.dart';
import 'game_settings.dart';

// Main widget for the sound controls panel section.
class SoundControlsPanel extends StatefulWidget {
  const SoundControlsPanel({super.key, this.dense = false});

  final bool dense;

  @override
  // Creates the state object for this widget.
  State<SoundControlsPanel> createState() => _SoundControlsPanelState();
}

// State for the sound controls panel widget.
class _SoundControlsPanelState extends State<SoundControlsPanel> {
  late bool muted;
  late double volume;
  late bool uiTapSoundEnabled;

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    muted = AudioService.isMuted;
    volume = AudioService.masterVolume;
    uiTapSoundEnabled = GameSettings.uiTapSoundEnabled;
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    final sliderActive = !muted;

    return Container(
      margin: EdgeInsets.symmetric(vertical: widget.dense ? 4 : 8),
      padding: EdgeInsets.symmetric(
        horizontal: widget.dense ? 8 : 12,
        vertical: widget.dense ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Sound',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch(
                value: !muted,
                onChanged: (enabled) {
                  setState(() {
                    muted = !enabled;
                  });
                  AudioService.setMuted(muted);
                  GameSettings.persistAudioSettings(
                    muted: muted,
                    volume: volume,
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.volume_down, color: Colors.white70, size: 18),
              Expanded(
                child: Slider(
                  min: 0,
                  max: 1,
                  divisions: 10,
                  value: volume,
                  label: '${(volume * 100).round()}%',
                  onChanged: sliderActive
                      ? (v) {
                          setState(() {
                            volume = v;
                          });
                          AudioService.setMasterVolume(v);
                          GameSettings.persistAudioSettings(
                            muted: muted,
                            volume: v,
                          );
                        }
                      : null,
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white70, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.touch_app, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'UI Tap Sound',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: uiTapSoundEnabled,
                onChanged: (enabled) {
                  setState(() {
                    uiTapSoundEnabled = enabled;
                  });
                  GameSettings.setUiTapSoundEnabled(enabled);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
