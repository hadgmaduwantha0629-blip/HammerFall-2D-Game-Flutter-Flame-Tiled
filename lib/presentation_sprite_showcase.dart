//to run this file :flutter run -d chrome -t lib/presentation_sprite_showcase.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const SpriteShowcaseApp());
}

class SpriteShowcaseApp extends StatelessWidget {
  const SpriteShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HammerFall Sprite Showcase',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF4A300),
          brightness: Brightness.dark,
        ),
        textTheme: base.textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const SpriteShowcasePage(),
    );
  }
}

class SpriteShowcasePage extends StatefulWidget {
  const SpriteShowcasePage({super.key});

  @override
  State<SpriteShowcasePage> createState() => _SpriteShowcasePageState();
}

class _SpriteShowcasePageState extends State<SpriteShowcasePage> {
  static final Map<String, List<SpriteShowcaseEntry>> _catalog = {
    'King Human': [
      SpriteShowcaseEntry(
        label: 'Idle',
        assetPath: 'assets/images/01-King Human/Idle (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFFF4A300),
      ),
      SpriteShowcaseEntry(
        label: 'Run',
        assetPath: 'assets/images/01-King Human/Run (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFF3DD9B8),
      ),
      SpriteShowcaseEntry(
        label: 'Attack',
        assetPath: 'assets/images/01-King Human/Attack (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFFFF6B6B),
      ),
      SpriteShowcaseEntry(
        label: 'Jump',
        assetPath: 'assets/images/01-King Human/Jump (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFF6EC6FF),
      ),
      SpriteShowcaseEntry(
        label: 'Fall',
        assetPath: 'assets/images/01-King Human/Fall (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFF8FA6FF),
      ),
      SpriteShowcaseEntry(
        label: 'Hit',
        assetPath: 'assets/images/01-King Human/Hit (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFFE57373),
      ),
      SpriteShowcaseEntry(
        label: 'Dead',
        assetPath: 'assets/images/01-King Human/Dead (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFFB0BEC5),
      ),
      SpriteShowcaseEntry(
        label: 'Door In',
        assetPath: 'assets/images/01-King Human/Door In (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFFAB47BC),
      ),
      SpriteShowcaseEntry(
        label: 'Door Out',
        assetPath: 'assets/images/01-King Human/Door Out (78x58).png',
        frameWidth: 78,
        frameHeight: 58,
        accent: Color(0xFFCE93D8),
      ),
    ],
    'King Pig': [
      SpriteShowcaseEntry(
        label: 'Idle',
        assetPath: 'assets/images/02-King Pig/Idle (38x28).png',
        frameWidth: 38,
        frameHeight: 28,
        accent: Color(0xFFFFB74D),
      ),
      SpriteShowcaseEntry(
        label: 'Run',
        assetPath: 'assets/images/02-King Pig/Run (38x28).png',
        frameWidth: 38,
        frameHeight: 28,
        accent: Color(0xFF81C784),
      ),
      SpriteShowcaseEntry(
        label: 'Attack',
        assetPath: 'assets/images/02-King Pig/Attack (38x28).png',
        frameWidth: 38,
        frameHeight: 28,
        accent: Color(0xFFEF5350),
      ),
      SpriteShowcaseEntry(
        label: 'Jump',
        assetPath: 'assets/images/02-King Pig/Jump (38x28).png',
        frameWidth: 38,
        frameHeight: 28,
        accent: Color(0xFF64B5F6),
      ),
      SpriteShowcaseEntry(
        label: 'Fall',
        assetPath: 'assets/images/02-King Pig/Fall (38x28).png',
        frameWidth: 38,
        frameHeight: 28,
        accent: Color(0xFF90CAF9),
      ),
      SpriteShowcaseEntry(
        label: 'Hit',
        assetPath: 'assets/images/02-King Pig/Hit (38x28).png',
        frameWidth: 38,
        frameHeight: 28,
        accent: Color(0xFFE57373),
      ),
      SpriteShowcaseEntry(
        label: 'Dead',
        assetPath: 'assets/images/02-King Pig/Dead (38x28).png',
        frameWidth: 38,
        frameHeight: 28,
        accent: Color(0xFFB0BEC5),
      ),
    ],
    'Pig': [
      SpriteShowcaseEntry(
        label: 'Idle',
        assetPath: 'assets/images/03-Pig/Idle (34x28).png',
        frameWidth: 34,
        frameHeight: 28,
        accent: Color(0xFFFFCC80),
      ),
      SpriteShowcaseEntry(
        label: 'Run',
        assetPath: 'assets/images/03-Pig/Run (34x28).png',
        frameWidth: 34,
        frameHeight: 28,
        accent: Color(0xFF4DB6AC),
      ),
      SpriteShowcaseEntry(
        label: 'Attack',
        assetPath: 'assets/images/03-Pig/Attack (34x28).png',
        frameWidth: 34,
        frameHeight: 28,
        accent: Color(0xFFFF8A65),
      ),
      SpriteShowcaseEntry(
        label: 'Jump',
        assetPath: 'assets/images/03-Pig/Jump (34x28).png',
        frameWidth: 34,
        frameHeight: 28,
        accent: Color(0xFF64B5F6),
      ),
      SpriteShowcaseEntry(
        label: 'Fall',
        assetPath: 'assets/images/03-Pig/Fall (34x28).png',
        frameWidth: 34,
        frameHeight: 28,
        accent: Color(0xFF90CAF9),
      ),
      SpriteShowcaseEntry(
        label: 'Hit',
        assetPath: 'assets/images/03-Pig/Hit (34x28).png',
        frameWidth: 34,
        frameHeight: 28,
        accent: Color(0xFFE57373),
      ),
      SpriteShowcaseEntry(
        label: 'Dead',
        assetPath: 'assets/images/03-Pig/Dead (34x28).png',
        frameWidth: 34,
        frameHeight: 28,
        accent: Color(0xFFB0BEC5),
      ),
    ],
    'Pig Throwing Box': [
      SpriteShowcaseEntry(
        label: 'Idle',
        assetPath: 'assets/images/04-Pig Throwing a Box/Idle (26x30).png',
        frameWidth: 26,
        frameHeight: 30,
        accent: Color(0xFFFFCC80),
      ),
      SpriteShowcaseEntry(
        label: 'Run',
        assetPath: 'assets/images/04-Pig Throwing a Box/Run (26x30).png',
        frameWidth: 26,
        frameHeight: 30,
        accent: Color(0xFF80CBC4),
      ),
      SpriteShowcaseEntry(
        label: 'Picking Box',
        assetPath:
            'assets/images/04-Pig Throwing a Box/Picking Box (26x30).png',
        frameWidth: 26,
        frameHeight: 30,
        accent: Color(0xFF9575CD),
      ),
      SpriteShowcaseEntry(
        label: 'Throwing Box',
        assetPath:
            'assets/images/04-Pig Throwing a Box/Throwing Box (26x30).png',
        frameWidth: 26,
        frameHeight: 30,
        accent: Color(0xFFFF7043),
      ),
    ],
    'Pig Throwing Bomb': [
      SpriteShowcaseEntry(
        label: 'Idle',
        assetPath: 'assets/images/05-Pig Thowing a Bomb/Idle (26x26).png',
        frameWidth: 26,
        frameHeight: 26,
        accent: Color(0xFFFFCC80),
      ),
      SpriteShowcaseEntry(
        label: 'Run',
        assetPath: 'assets/images/05-Pig Thowing a Bomb/Run (26x26).png',
        frameWidth: 26,
        frameHeight: 26,
        accent: Color(0xFF80CBC4),
      ),
      SpriteShowcaseEntry(
        label: 'Picking Bomb',
        assetPath:
            'assets/images/05-Pig Thowing a Bomb/Picking Bomb (26x26).png',
        frameWidth: 26,
        frameHeight: 26,
        accent: Color(0xFF9575CD),
      ),
      SpriteShowcaseEntry(
        label: 'Throwing Boom',
        assetPath:
            'assets/images/05-Pig Thowing a Bomb/Throwing Boom (26x26).png',
        frameWidth: 26,
        frameHeight: 26,
        accent: Color(0xFFFF7043),
      ),
    ],
    'Pig Hide in Box': [
      SpriteShowcaseEntry(
        label: 'Looking Out',
        assetPath:
            'assets/images/06-Pig Hide in the Box/Looking Out (26x20).png',
        frameWidth: 26,
        frameHeight: 20,
        accent: Color(0xFF4FC3F7),
      ),
      SpriteShowcaseEntry(
        label: 'Jump Anticipation',
        assetPath:
            'assets/images/06-Pig Hide in the Box/Jump Anticipation (26x20).png',
        frameWidth: 26,
        frameHeight: 20,
        accent: Color(0xFF81C784),
      ),
      SpriteShowcaseEntry(
        label: 'Jump',
        assetPath: 'assets/images/06-Pig Hide in the Box/Jump (26x20).png',
        frameWidth: 26,
        frameHeight: 20,
        accent: Color(0xFF64B5F6),
      ),
      SpriteShowcaseEntry(
        label: 'Fall',
        assetPath: 'assets/images/06-Pig Hide in the Box/Fall (26x20).png',
        frameWidth: 26,
        frameHeight: 20,
        accent: Color(0xFF90CAF9),
      ),
      SpriteShowcaseEntry(
        label: 'Ground',
        assetPath:
            'assets/images/06-Pig Hide in the Box/Ground (26x20).png',
        frameWidth: 26,
        frameHeight: 20,
        accent: Color(0xFFA1887F),
      ),
    ],
    'Pig With Match': [
      SpriteShowcaseEntry(
        label: 'Match On',
        assetPath: 'assets/images/07-Pig With a Match/Match On (26x18).png',
        frameWidth: 26,
        frameHeight: 18,
        accent: Color(0xFFFFCA28),
      ),
      SpriteShowcaseEntry(
        label: 'Lighting the Match',
        assetPath:
            'assets/images/07-Pig With a Match/Lighting the Match (26x18).png',
        frameWidth: 26,
        frameHeight: 18,
        accent: Color(0xFFFF8A65),
      ),
      SpriteShowcaseEntry(
        label: 'Lighting the Cannon',
        assetPath:
            'assets/images/07-Pig With a Match/Lighting the Cannon (26x18).png',
        frameWidth: 26,
        frameHeight: 18,
        accent: Color(0xFFEF5350),
      ),
    ],
  };

  late String _selectedCharacter;
  late SpriteShowcaseEntry _selectedEntry;
  bool _autoCycle = true;
  Timer? _autoCycleTimer;

  @override
  void initState() {
    super.initState();
    _selectedCharacter = _catalog.keys.first;
    _selectedEntry = _catalog[_selectedCharacter]!.first;
    _syncTimer();
  }

  @override
  void dispose() {
    _autoCycleTimer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    _autoCycleTimer?.cancel();
    if (!_autoCycle) return;
    _autoCycleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final entries = _catalog[_selectedCharacter]!;
      final currentIndex = entries.indexOf(_selectedEntry);
      final nextIndex = (currentIndex + 1) % entries.length;
      setState(() {
        _selectedEntry = entries[nextIndex];
      });
    });
  }

  void _selectCharacter(String character) {
    setState(() {
      _selectedCharacter = character;
      _selectedEntry = _catalog[character]!.first;
    });
    _syncTimer();
  }

  void _selectEntry(SpriteShowcaseEntry entry) {
    setState(() {
      _selectedEntry = entry;
    });
    _syncTimer();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _catalog[_selectedCharacter]!;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1020), Color(0xFF16213A), Color(0xFF27193D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 1180;
              final sidePanel = _CharacterRail(
                characters: _catalog.keys.toList(growable: false),
                selected: _selectedCharacter,
                onSelected: _selectCharacter,
              );

              final content = Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderBar(
                      selectedEntry: _selectedEntry,
                      autoCycle: _autoCycle,
                      onAutoCycleChanged: (value) {
                        setState(() {
                          _autoCycle = value;
                        });
                        _syncTimer();
                      },
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: compact
                          ? Column(
                              children: [
                                SizedBox(height: 72, child: sidePanel),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: _ShowcaseBody(
                                    entry: _selectedEntry,
                                    entries: entries,
                                    onEntrySelected: _selectEntry,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(width: 250, child: sidePanel),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _ShowcaseBody(
                                    entry: _selectedEntry,
                                    entries: entries,
                                    onEntrySelected: _selectEntry,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              );

              return content;
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.selectedEntry,
    required this.autoCycle,
    required this.onAutoCycleChanged,
  });

  final SpriteShowcaseEntry selectedEntry;
  final bool autoCycle;
  final ValueChanged<bool> onAutoCycleChanged;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
    );
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 16,
      spacing: 18,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HammerFall Sprite Showcase', style: titleStyle),
            const SizedBox(height: 6),
            Text(
              'Standalone presentation screen for recording movement, walking, attack, jump, and reaction animations.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selectedEntry.accent.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Auto cycle',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(value: autoCycle, onChanged: onAutoCycleChanged),
            ],
          ),
        ),
      ],
    );
  }
}

class _CharacterRail extends StatelessWidget {
  const _CharacterRail({
    required this.characters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> characters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = constraints.maxWidth > constraints.maxHeight;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: ListView.separated(
            scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
            itemCount: characters.length,
            separatorBuilder: (_, _) => SizedBox(
              width: isHorizontal ? 10 : 0,
              height: isHorizontal ? 0 : 10,
            ),
            itemBuilder: (context, index) {
              final character = characters[index];
              final isSelected = character == selected;
              return ChoiceChip(
                label: Text(character),
                selected: isSelected,
                onSelected: (_) => onSelected(character),
                selectedColor: const Color(0xFFF4A300),
                backgroundColor: Colors.white.withOpacity(0.08),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ShowcaseBody extends StatelessWidget {
  const _ShowcaseBody({
    required this.entry,
    required this.entries,
    required this.onEntrySelected,
  });

  final SpriteShowcaseEntry entry;
  final List<SpriteShowcaseEntry> entries;
  final ValueChanged<SpriteShowcaseEntry> onEntrySelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;
        return Column(
          children: [
            Expanded(
              child: stacked
                  ? Column(
                      children: [
                        Expanded(flex: 3, child: _PreviewStage(entry: entry)),
                        const SizedBox(height: 20),
                        Expanded(flex: 2, child: _InfoPanel(entry: entry)),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: _PreviewStage(entry: entry),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: _InfoPanel(entry: entry),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 156,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = entries[index];
                  final isSelected = item == entry;
                  return _ActionCard(
                    entry: item,
                    selected: isSelected,
                    onTap: () => onEntrySelected(item),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PreviewStage extends StatefulWidget {
  const _PreviewStage({required this.entry});

  final SpriteShowcaseEntry entry;

  @override
  State<_PreviewStage> createState() => _PreviewStageState();
}

class _PreviewStageState extends State<_PreviewStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: widget.entry.accent.withOpacity(0.35)),
        gradient: LinearGradient(
          colors: [
            widget.entry.accent.withOpacity(0.18),
            const Color(0xFF11192C),
            const Color(0xFF0A0F1C),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AnimatedBuilder(
        animation: _motionController,
        builder: (context, _) {
          final progress = _motionController.value;
          final pingPong = progress < 0.5 ? progress * 2 : (1 - progress) * 2;
          final dx = _horizontalOffset(widget.entry.label, progress, pingPong);
          final dy = _verticalOffset(widget.entry.label, progress, pingPong);
          final mirrored = widget.entry.label.contains('Run') && progress >= 0.5;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackdropPainter(accent: widget.entry.accent),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: AnimatedSpriteSheet(
                    entry: widget.entry,
                    scale: 4.8,
                    mirrored: mirrored,
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.entry.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _horizontalOffset(String label, double progress, double pingPong) {
    if (label.contains('Run')) {
      return -120 + (240 * progress);
    }
    if (label.contains('Attack') || label.contains('Throwing')) {
      return math.sin(progress * math.pi * 6) * 22;
    }
    if (label.contains('Lighting')) {
      return math.sin(progress * math.pi * 4) * 10;
    }
    return math.sin(progress * math.pi * 2) * 6;
  }

  double _verticalOffset(String label, double progress, double pingPong) {
    if (label.contains('Jump')) {
      return 60 - (110 * pingPong);
    }
    if (label.contains('Fall')) {
      return -40 + (100 * pingPong);
    }
    if (label.contains('Hit')) {
      return math.sin(progress * math.pi * 8) * 10;
    }
    return 0;
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.entry});

  final SpriteShowcaseEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recording Notes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _InfoRow(label: 'Animation', value: entry.label),
            _InfoRow(
              label: 'Frame size',
              value: '${entry.frameWidth} x ${entry.frameHeight}',
            ),
            _InfoRow(label: 'Asset', value: entry.assetPath),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const SelectableText(
                'flutter run -d chrome -t lib/presentation_sprite_showcase.dart',
                style: TextStyle(
                  fontFamily: 'Consolas',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final SpriteShowcaseEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 148,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected
              ? entry.accent.withOpacity(0.22)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: selected
                ? entry.accent.withOpacity(0.95)
                : Colors.white.withOpacity(0.10),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AnimatedSpriteSheet(
                  entry: entry,
                  scale: 2.2,
                  mirrored: false,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              entry.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedSpriteSheet extends StatefulWidget {
  const AnimatedSpriteSheet({
    required this.entry,
    required this.scale,
    required this.mirrored,
    super.key,
  });

  final SpriteShowcaseEntry entry;
  final double scale;
  final bool mirrored;

  @override
  State<AnimatedSpriteSheet> createState() => _AnimatedSpriteSheetState();
}

class _AnimatedSpriteSheetState extends State<AnimatedSpriteSheet> {
  _SpriteSheetData? _sheet;
  Timer? _timer;
  int _frame = 0;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadSprite();
  }

  @override
  void didUpdateWidget(covariant AnimatedSpriteSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.assetPath != widget.entry.assetPath) {
      _loadSprite();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSprite() async {
    _timer?.cancel();
    final loadVersion = ++_loadVersion;
    final sheet = await SpriteSheetCache.load(widget.entry);
    if (!mounted || loadVersion != _loadVersion) return;
    setState(() {
      _sheet = sheet;
      _frame = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _sheet == null) return;
      setState(() {
        _frame = (_frame + 1) % _sheet!.frameCount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sheet == null) {
      return SizedBox(
        width: widget.entry.frameWidth * widget.scale,
        height: widget.entry.frameHeight * widget.scale,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return CustomPaint(
      size: Size(
        widget.entry.frameWidth * widget.scale,
        widget.entry.frameHeight * widget.scale,
      ),
      painter: _SpriteSheetPainter(
        image: _sheet!.image,
        frameIndex: _frame,
        frameWidth: widget.entry.frameWidth,
        frameHeight: widget.entry.frameHeight,
        mirrored: widget.mirrored,
      ),
    );
  }
}

class _SpriteSheetPainter extends CustomPainter {
  const _SpriteSheetPainter({
    required this.image,
    required this.frameIndex,
    required this.frameWidth,
    required this.frameHeight,
    required this.mirrored,
  });

  final ui.Image image;
  final int frameIndex;
  final int frameWidth;
  final int frameHeight;
  final bool mirrored;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Rect.fromLTWH(
      frameIndex * frameWidth.toDouble(),
      0,
      frameWidth.toDouble(),
      frameHeight.toDouble(),
    );
    final destination = Offset.zero & size;
    final paint = Paint()..filterQuality = FilterQuality.none;

    if (mirrored) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    canvas.drawImageRect(image, source, destination, paint);

    if (mirrored) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SpriteSheetPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.frameIndex != frameIndex ||
        oldDelegate.mirrored != mirrored;
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [accent.withOpacity(0.35), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.42),
          radius: size.shortestSide * 0.45,
        ),
      );
    canvas.drawRect(Offset.zero & size, glow);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    const spacing = 34.0;
    for (double y = size.height * 0.68; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class SpriteShowcaseEntry {
  const SpriteShowcaseEntry({
    required this.label,
    required this.assetPath,
    required this.frameWidth,
    required this.frameHeight,
    required this.accent,
  });

  final String label;
  final String assetPath;
  final int frameWidth;
  final int frameHeight;
  final Color accent;
}

class _SpriteSheetData {
  const _SpriteSheetData({required this.image, required this.frameCount});

  final ui.Image image;
  final int frameCount;
}

class SpriteSheetCache {
  static final Map<String, Future<_SpriteSheetData>> _cache = {};

  static Future<_SpriteSheetData> load(SpriteShowcaseEntry entry) {
    return _cache.putIfAbsent(entry.assetPath, () async {
      final data = await rootBundle.load(entry.assetPath);
      final buffer = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(buffer);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final frameCount = math.max(1, image.width ~/ entry.frameWidth);
      return _SpriteSheetData(image: image, frameCount: frameCount);
    });
  }
}