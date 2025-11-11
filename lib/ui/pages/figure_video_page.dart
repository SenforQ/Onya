import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/figure_model.dart';

class FigureVideoPage extends StatefulWidget {
  const FigureVideoPage({super.key, required this.figure});

  final FigureModel figure;

  @override
  State<FigureVideoPage> createState() => _FigureVideoPageState();
}

class _FigureVideoPageState extends State<FigureVideoPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  int _remainingSeconds = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startPlayback();
    _startCountdown();
  }

  Future<void> _startPlayback() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('onya_call_video.mp3'));
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }
  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = 30;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        Navigator.of(context).pop();
      } else {
        setState(() {
          _remainingSeconds -= 1;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final String backgroundImage = widget.figure.showPhotoArray.isNotEmpty
        ? widget.figure.showPhotoArray.first
        : widget.figure.userIcon;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: <Widget>[
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            CupertinoIcons.back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Video Call · ${widget.figure.figureName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.figure.userIcon,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.figure.figureName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connecting video call...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Call ends in $_remainingSeconds s',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(width: 24),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            CupertinoIcons.phone_down_fill,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

