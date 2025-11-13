import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Course4Page extends StatelessWidget {
  const Course4Page({super.key});

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
                          'The Importance of Music Teachers in Early Education',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Music teachers play an indispensable role in a child\'s musical education and development. They are not just instructors who teach notes and techniques; they are mentors who inspire, guide, and nurture a child\'s musical journey from the very beginning.',
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
                            'assets/Course_4.webp',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'A skilled music teacher understands that every child learns differently and adapts their teaching methods accordingly. They create a safe and encouraging environment where children feel comfortable making mistakes, asking questions, and exploring their musical creativity. This personalized approach is essential for effective music education.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Music teachers also serve as role models, demonstrating passion, dedication, and discipline. Children observe how their teachers approach music, practice, and overcome challenges, learning valuable life lessons that extend far beyond the music room. The relationship between a student and their music teacher can be transformative, shaping not just musical skills but also character and confidence.',
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

