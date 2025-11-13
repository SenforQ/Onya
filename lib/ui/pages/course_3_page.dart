import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Course3Page extends StatelessWidget {
  const Course3Page({super.key});

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
                          'Family Music Communication: Building Musical Bonds',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Effective communication about music between parents and children is essential for fostering a child\'s musical growth. When parents take the time to understand and engage with their child\'s musical interests, they create a supportive foundation that encourages exploration and learning.',
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
                            'assets/Course_3.webp',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Parents who actively communicate with their children about music help them develop a deeper appreciation for the art form. By asking questions, listening to music together, and discussing what they hear, parents can guide their children\'s musical understanding and help them articulate their thoughts and feelings about music.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'This open dialogue about music also helps children feel valued and understood. When parents show genuine interest in their child\'s musical journey, it boosts the child\'s confidence and motivation to continue learning. Children are more likely to practice and explore music when they know their efforts are recognized and appreciated.',
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

