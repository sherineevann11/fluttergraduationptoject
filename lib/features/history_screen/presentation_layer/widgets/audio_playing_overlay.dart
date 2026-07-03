import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduationproject/core/style/app_assets.dart';

class AudioPlayingOverlay extends StatefulWidget {
  const AudioPlayingOverlay({super.key});

  @override
  State<AudioPlayingOverlay> createState() => _AudioPlayingOverlayState();
}

class _AudioPlayingOverlayState extends State<AudioPlayingOverlay>
    with TickerProviderStateMixin {
  static const int _barsPerSide = 5;
  static const Color _accentColor = Color(0xFF30BBF9);

  late final AnimationController _pulseController;
  late final List<AnimationController> _barControllers;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _barControllers = List.generate(_barsPerSide * 2, (index) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350 + (index % 5) * 90),
      );
      Future.delayed(Duration(milliseconds: index * 60), () {
        if (mounted) controller.repeat(reverse: true);
      });
      return controller;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    for (final c in _barControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildBar(int index) {
    return AnimatedBuilder(
      animation: _barControllers[index],
      builder: (context, child) {
        final value = _barControllers[index].value;
        final height = 10.0 + value * 26.0;
        return Container(
          width: 4,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFF1A156C).withOpacity(0.55 + value * 0.45),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }

  Widget _buildMicCircle() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final t = _pulseController.value;
        final scale = 1.0 + t * 0.10;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1.0 + t * 0.55,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A156C).withOpacity(0.18 * (1 - t)),
                ),
              ),
            ),
            Transform.scale(
              scale: scale,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1A156C).withOpacity(0.95),
                      const Color(0xFF1A156C).withOpacity(0.55),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A156C).withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.MicVoice,
                    width: 70,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1A156C), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...List.generate(_barsPerSide, _buildBar),
              const SizedBox(width: 14),
              _buildMicCircle(),
              const SizedBox(width: 14),
              ...List.generate(
                _barsPerSide,
                (i) => _buildBar(i + _barsPerSide),
              ),
            ],
          ),
        ),
      ),
    );
  }
}