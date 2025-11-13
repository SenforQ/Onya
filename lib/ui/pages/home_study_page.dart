import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/coin_service.dart';
import 'course_1_page.dart';
import 'course_2_page.dart';
import 'course_3_page.dart';
import 'course_4_page.dart';
import 'course_5_page.dart';

class HomeStudyPage extends StatefulWidget {
  const HomeStudyPage({super.key});

  @override
  State<HomeStudyPage> createState() => _HomeStudyPageState();
}

class _HomeStudyPageState extends State<HomeStudyPage> {
  final Set<int> _unlockedCourseIndices = <int>{};
  static const String _unlockedCoursesKey = 'home_study_unlocked_courses';
  static const int _unlockCost = 200;

  @override
  void initState() {
    super.initState();
    _loadUnlockedCourses();
  }

  Future<void> _loadUnlockedCourses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> unlockedIndices =
        prefs.getStringList(_unlockedCoursesKey) ?? <String>[];
    if (!mounted) {
      return;
    }
    setState(() {
      _unlockedCourseIndices.clear();
      _unlockedCourseIndices.addAll(
        unlockedIndices.map((String index) => int.parse(index)),
      );
    });
  }

  bool _isCourseLocked(int index) {
    // 课程 4 和 5（索引 3 和 4）需要解锁
    return (index == 3 || index == 4) &&
        !_unlockedCourseIndices.contains(index);
  }

  Future<void> _unlockCourse(int index) async {
    final int currentCoins = await CoinService.getCurrentCoins();
    if (currentCoins < _unlockCost) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient coins. You need $_unlockCost coins to unlock this course.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final bool success = await CoinService.spendCoins(_unlockCost);
    if (success) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _unlockedCourseIndices.add(index);
      });
      await prefs.setStringList(
        _unlockedCoursesKey,
        _unlockedCourseIndices.map((int i) => i.toString()).toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unlocked course ${index + 1} for $_unlockCost coins',
            ),
            backgroundColor: const Color(0xFF7B24FF),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unlock course. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleCourseTap(int index) {
    if (_isCourseLocked(index)) {
      _unlockCourse(index);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => _coursePages[index](),
        ),
      );
    }
  }

  List<Widget Function()> get _coursePages => <Widget Function()>[
        () => const Course1Page(),
        () => const Course2Page(),
        () => const Course3Page(),
        () => const Course4Page(),
        () => const Course5Page(),
      ];

  final List<Map<String, String>> _courses = const <Map<String, String>>[
    <String, String>{
      'image': 'assets/Course_1.webp',
      'title': 'Learning Music Theory with Children: A Journey of Discovery',
      'content':
          'Learning music theory with children is one of the most rewarding experiences a parent or educator can have. It opens up a world of creativity, expression, and cognitive development that benefits children in countless ways.',
    },
    <String, String>{
      'image': 'assets/Course_2.webp',
      'title': 'The Impact of Music Communities on Learning',
      'content':
          'Music communities play a crucial role in helping children learn and grow musically. These communities provide a supportive environment where young musicians can share their passion, learn from each other, and develop their skills together.',
    },
    <String, String>{
      'image': 'assets/Course_3.webp',
      'title': 'Family Music Communication: Building Musical Bonds',
      'content':
          'Effective communication about music between parents and children is essential for fostering a child\'s musical growth. When parents take the time to understand and engage with their child\'s musical interests, they create a supportive foundation.',
    },
    <String, String>{
      'image': 'assets/Course_4.webp',
      'title': 'The Importance of Music Teachers in Early Education',
      'content':
          'Music teachers play an indispensable role in a child\'s musical education and development. They are not just instructors who teach notes and techniques; they are mentors who inspire, guide, and nurture a child\'s musical journey.',
    },
    <String, String>{
      'image': 'assets/Course_5.webp',
      'title': 'The Impact of Music on the Brain and Body',
      'content':
          'Music has profound effects on the human brain, creating neural pathways and connections that enhance cognitive function, memory, and emotional well-being. Research has shown that engaging with music activates multiple areas of the brain simultaneously.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

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
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Music Theory Courses',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _courses.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, String> course = _courses[index];
                      final bool isLocked = _isCourseLocked(index);
                      return GestureDetector(
                        onTap: () {
                          _handleCourseTap(index);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      course['image'] as String,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          course['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          course['content'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                            height: 1.5,
                                          ),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isLocked)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.lock_fill,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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

