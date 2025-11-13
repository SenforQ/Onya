import 'package:flutter/material.dart';

import 'home_study_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _handleStartExercising() {
    Navigator.of(context).push(
      MaterialPageRoute<HomeStudyPage>(
        builder: (BuildContext context) => const HomeStudyPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double topSafe = MediaQuery.of(context).padding.top;
    final double imageWidth = 375 - 80;
    final double imageHeight = imageWidth * 0.98;
    final double imageY = screenSize.height - imageHeight - 86;
    final double imageX = (screenSize.width - imageWidth) / 2;
    
    final double topImageWidth = screenSize.width - 40;
    final double topImageTop = topSafe + 12;
    final double topImageHeight = imageY - topImageTop - 12;
    final double topImageLeft = (screenSize.width - topImageWidth) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/mine_bg.webp',
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: topImageLeft,
            top: topImageTop,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: topImageWidth,
                height: topImageHeight,
                child: Stack(
                  children: <Widget>[
                    Image.asset(
                      'assets/home_top_bg.webp',
                      width: topImageWidth,
                      height: topImageHeight,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFF1C0325),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF68B6FF),
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Music Teacher',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'Some music theory knowledge requires spending Coins to unlock',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Got it',
                                      style: TextStyle(
                                        color: Color(0xFF68B6FF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Stack(
                        children: <Widget>[
                          Image.asset(
                            'assets/home_topimg_cover.webp',
                            width: topImageWidth,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            top: 0,
                            child: Center(
                              child: ElevatedButton(
                                onPressed: _handleStartExercising,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    side: const BorderSide(
                                      color: Color(0xFF4E096A),
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Learn Music Theory',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: imageX,
            top: imageY,
            child: Image.asset(
              'assets/home_music_bottom.webp',
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

