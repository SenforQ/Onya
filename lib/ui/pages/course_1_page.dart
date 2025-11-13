import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Course1Page extends StatelessWidget {
  const Course1Page({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double safeAreaTop = MediaQuery.of(context).padding.top;

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
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            CupertinoIcons.back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Learning Music Theory with Children: A Journey of Discovery',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Learning music theory with children is one of the most rewarding experiences a parent or educator can have. It opens up a world of creativity, expression, and cognitive development that benefits children in countless ways.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'When children learn music theory, they are not just memorizing notes and scales. They are developing critical thinking skills, improving their memory, and enhancing their ability to recognize patterns. These skills transfer to other areas of learning, making music theory an invaluable educational tool.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/Course_1.webp',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'The key to successful music theory education with children is making it fun and engaging. Use games, songs, and interactive activities to teach concepts like rhythm, melody, and harmony. Children learn best when they are actively participating and enjoying the process.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'As children progress in their music theory journey, they gain confidence in their musical abilities. This confidence extends beyond music, helping them tackle challenges in other areas of life with a positive attitude and determination.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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

