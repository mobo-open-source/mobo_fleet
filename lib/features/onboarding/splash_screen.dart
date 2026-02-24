import 'package:flutter/material.dart';
import 'package:mobo_projects/features/onboarding/get_started_carousal.dart';
import 'package:mobo_projects/app_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.asset('assets/splashVideo/fleet_splash.mp4')
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
          });
    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          _controller.value.position >= _controller.value.duration &&
          !_controller.value.isPlaying &&
          !_navigated) {
        _navigated = true;
        goNext();
      }
    });
  }

  Future<void> goNext() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenGetStarted = prefs.getBool('hasSeenGetStarted') ?? false;
    if (!hasSeenGetStarted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => GetStartedScreen()),
            (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AppEntry()),
            (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(),
    );
  }
}
