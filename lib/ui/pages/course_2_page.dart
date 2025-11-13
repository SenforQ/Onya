import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Course2Page extends StatelessWidget {
  const Course2Page({super.key});

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
                          'The Impact of Music Communities on Learning',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/Course_2.webp',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Music communities play a crucial role in helping children learn and grow musically. These communities provide a supportive environment where young musicians can share their passion, learn from each other, and develop their skills together.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'In a music community, children are exposed to diverse musical styles and perspectives. They learn to appreciate different genres, understand various cultural musical traditions, and develop a broader understanding of what music can be. This exposure enriches their musical education and helps them become well-rounded musicians.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Collaboration is another key benefit of music communities. When children work together in ensembles, bands, or choirs, they learn important social skills like communication, teamwork, and mutual respect. These experiences teach them how to listen to others, adapt their playing, and contribute to a collective musical goal.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Music communities also provide motivation and accountability. When children see their peers practicing and improving, they are inspired to work harder themselves. Regular performances and group activities give them goals to work toward and celebrate achievements together.',
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

