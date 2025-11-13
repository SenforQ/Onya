import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Course5Page extends StatelessWidget {
  const Course5Page({super.key});

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
                          'The Impact of Music on the Brain and Body',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Music has profound effects on the human brain, creating neural pathways and connections that enhance cognitive function, memory, and emotional well-being. Research has shown that engaging with music activates multiple areas of the brain simultaneously, making it one of the most comprehensive brain exercises available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'When children learn music, their brains develop stronger connections between the left and right hemispheres. This enhanced connectivity improves problem-solving abilities, creativity, and the ability to process complex information. Musical training has been linked to better academic performance, particularly in mathematics and language skills.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Beyond cognitive benefits, music also has significant physical health advantages. Playing musical instruments improves fine motor skills, hand-eye coordination, and posture. The rhythmic nature of music can help regulate heart rate and breathing, reducing stress and promoting relaxation.',
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
                            'assets/Course_5.webp',
                            width: double.infinity,
                            fit: BoxFit.cover,
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

