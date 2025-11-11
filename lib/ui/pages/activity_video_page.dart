import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/figure_model.dart';

class ActivityVideoPage extends StatefulWidget {
  const ActivityVideoPage({
    super.key,
    required this.figure,
    required this.videoPath,
  });

  final FigureModel figure;
  final String videoPath;

  @override
  State<ActivityVideoPage> createState() => _ActivityVideoPageState();
}

class _ActivityVideoPageState extends State<ActivityVideoPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitialized = true;
      });
      _controller.setLooping(true);
      _controller.play();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasError = true;
      });
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            if (_hasError)
              const Center(
                child: Text(
                  'Failed to load video',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else if (!_isInitialized)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            if (_isInitialized)
              Positioned.fill(
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IgnorePointer(
                        ignoring: false,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!_isInitialized)
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

