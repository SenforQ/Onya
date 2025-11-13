import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'activity_chat_page.dart';

class ActivityTeacherPage extends StatelessWidget {
  const ActivityTeacherPage({
    super.key,
    required this.teacherIndex,
    required this.teacherName,
    required this.teacherAvatar,
    required this.teacherSayhi,
    required this.teacherMotto,
    required this.teacherMusicStyles,
  });

  final int teacherIndex;
  final String teacherName;
  final String teacherAvatar;
  final String teacherSayhi;
  final String teacherMotto;
  final List<String> teacherMusicStyles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: SafeArea(
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
                  Expanded(
                    child: Text(
                      teacherName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 32),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF2ED0),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          teacherAvatar,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      teacherName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Music Styles',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: teacherMusicStyles
                            .map(
                              (String style) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B24FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  style,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'About Me',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        teacherMotto,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B24FF),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute<ActivityChatPage>(
                                builder: (BuildContext context) =>
                                    ActivityChatPage(
                                  teacherName: teacherName,
                                  teacherAvatar: teacherAvatar,
                                  teacherSayhi: teacherSayhi,
                                  teacherMotto: teacherMotto,
                                  teacherMusicStyles: teacherMusicStyles,
                                ),
                              ),
                          );
                        },
                        child: const Text(
                          'Free Chat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
    );
  }
}

