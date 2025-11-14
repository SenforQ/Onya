import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dynamic_input_page.dart';

class DynamicActivityPage extends StatefulWidget {
  const DynamicActivityPage({super.key});

  @override
  State<DynamicActivityPage> createState() => _DynamicActivityPageState();
}

class _DynamicActivityPageState extends State<DynamicActivityPage> {
  bool _isJoined = false;
  static const String _activityJoinedKey = 'activity_joined';

  @override
  void initState() {
    super.initState();
    _loadJoinedStatus();
  }

  Future<void> _loadJoinedStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool joined = prefs.getBool(_activityJoinedKey) ?? false;
    if (mounted) {
      setState(() {
        _isJoined = joined;
      });
    }
  }

  Future<void> _handleJoinIn() async {
    if (_isJoined) {
      return;
    }

    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const DynamicInputPage(),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _isJoined = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Image.asset(
              'assets/dynamic_base_bg.webp',
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: topPadding + 24,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.arrow_left,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Official Activities',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 24 + 44 + 24,
            left: 20,
            right: 20,
            bottom: 24,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: <Widget>[
                _buildActivityCell(context, screenSize.width - 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCell(BuildContext context, double cellWidth) {
    final double imageHeight = cellWidth * 1.34;

    return Container(
      width: cellWidth,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              left: 12,
              right: 12,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/activity_one.webp',
                width: cellWidth - 24,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Music Lovers Exchange',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    const Icon(
                      CupertinoIcons.location_solid,
                      size: 16,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Los Angeles',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 66,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/app_logo.webp',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        const Text(
                          'Nyme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '2025/11/1-2025/12/24',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isJoined ? null : _handleJoinIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isJoined
                          ? Colors.grey
                          : const Color(0xFF7B24FF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      _isJoined ? 'Joined' : 'Join in',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

