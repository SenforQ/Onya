import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/figure_model.dart';
import '../../services/coin_service.dart';
import 'activity_teacher_page.dart';
import 'activity_video_page.dart';
import 'report_detail_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<FigureModel> _allFigures = <FigureModel>[];
  List<FigureModel> _figures = <FigureModel>[];
  final Set<String> _blockedFigureIds = <String>{};
  final Set<String> _mutedFigureIds = <String>{};
  final Set<String> _unlockedFigureIds = <String>{};
  final Set<int> _unlockedTeacherIndices = <int>{};
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  static const String _blockedStorageKey = 'activity_blocked_figures';
  static const String _mutedStorageKey = 'activity_muted_figures';
  static const String _unlockedTeachersKey = 'activity_unlocked_teachers';
  static const int _unlockCost = 200;

  final List<String> _musicFigures = <String>[
    'assets/music_figure_1.webp',
    'assets/music_figure_2.webp',
    'assets/music_figure_3.webp',
    'assets/music_figure_4.webp',
    'assets/music_figure_5.webp',
  ];

  final List<String> _teacherNames = <String>[
    'Cat Teacher',
    'Dog Teacher',
    'Chicken Teacher',
    'Duck Teacher',
    'Bear Teacher',
  ];

  final List<List<String>> _teacherMusicStyles = <List<String>>[
    <String>['Jazz', 'Ambient', 'Indie'],
    <String>['Pop', 'Rock', 'Dance'],
    <String>['Pop', 'Electronic', 'Dance'],
    <String>['Folk', 'Acoustic', 'Country'],
    <String>['Rock', 'Blues', 'Soul'],
  ];

  final List<String> _teacherSayhi = <String>[
    'Meow! I\'m Cat Teacher, your elegant music guide. Ready to explore smooth jazz and ambient melodies together? Let\'s create something sophisticated!',
    'Woof! Hey there! I\'m Dog Teacher, your energetic music companion. Ready to rock and dance? Let\'s make some amazing music together!',
    'Cluck cluck! Hi! I\'m Chicken Teacher, your upbeat music friend. Ready to groove to pop and electronic beats? Let\'s have some fun!',
    'Quack! Hello friend! I\'m Duck Teacher, your gentle music mentor. Ready to explore folk and acoustic melodies? Let\'s discover beautiful sounds together!',
    'Growl! Hey! I\'m Bear Teacher, your powerful music guide. Ready to feel the soul and blues? Let\'s create something deep and meaningful!',
  ];

  final List<String> _teacherMotto = <String>[
    'A music teacher who finds elegance in smooth melodies. I love exploring sophisticated sounds and helping students discover the beauty of jazz and ambient music through thoughtful instruction.',
    'A music teacher who brings energy and enthusiasm to every lesson. Life\'s too short for boring music - let\'s make it vibrant and exciting through rock, pop, and dance!',
    'A music teacher passionate about bringing rhythm and joy to every student. I thrive on upbeat melodies and enjoy sharing the excitement of pop and electronic music!',
    'A music teacher who values natural and heartfelt melodies. I enjoy sharing gentle sounds that connect with the soul through folk, acoustic, and country music.',
    'A music teacher driven by powerful emotions and deep connections through music. I love sharing soulful melodies that touch the heart and inspire through rock, blues, and soul.',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBlockAndMuteSettings();
    _loadUnlockedTeachers();
    _loadFigures();
    // 每次进入页面时清除解锁状态
    _unlockedFigureIds.clear();
  }

  Future<void> _loadUnlockedTeachers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> unlockedIndices =
        prefs.getStringList(_unlockedTeachersKey) ?? <String>[];
    if (!mounted) {
      return;
    }
    setState(() {
      _unlockedTeacherIndices.clear();
      _unlockedTeacherIndices.addAll(
        unlockedIndices.map((String index) => int.parse(index)),
      );
    });
  }

  Future<void> _unlockTeacher(int index) async {
    final int currentCoins = await CoinService.getCurrentCoins();
    if (currentCoins < _unlockCost) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient coins. You need $_unlockCost coins to unlock this teacher.',
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
        _unlockedTeacherIndices.add(index);
      });
      await prefs.setStringList(
        _unlockedTeachersKey,
        _unlockedTeacherIndices.map((int i) => i.toString()).toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unlocked ${_teacherNames[index]} for $_unlockCost coins',
            ),
            backgroundColor: const Color(0xFF7B24FF),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unlock teacher. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isTeacherLocked(int index) {
    // 第一个和第二个（索引0和1）是免费的，不需要解锁
    return index >= 2 && !_unlockedTeacherIndices.contains(index);
  }

  Future<void> _loadFigures() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/figures_data.json');
      final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
      if (!mounted) {
        return;
      }
      setState(() {
        _allFigures = data
            .map((dynamic json) =>
                FigureModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _figures = _filterFigures(_allFigures);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _allFigures = <FigureModel>[];
          _figures = <FigureModel>[];
        });
      }
    }
  }

  Future<void> _loadBlockAndMuteSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> blocked =
        prefs.getStringList(_blockedStorageKey) ?? <String>[];
    final List<String> muted =
        prefs.getStringList(_mutedStorageKey) ?? <String>[];
    if (!mounted) {
      return;
    }
    setState(() {
      _blockedFigureIds
        ..clear()
        ..addAll(blocked);
      _mutedFigureIds
        ..clear()
        ..addAll(muted);
    });
  }

  Future<void> _unlockVideo(FigureModel figure) async {
    final int currentCoins = await CoinService.getCurrentCoins();
    if (currentCoins < _unlockCost) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient coins. You need $_unlockCost coins to unlock this video.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final bool success = await CoinService.spendCoins(_unlockCost);
    if (success) {
      setState(() {
        _unlockedFigureIds.add(figure.figureName);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unlocked ${figure.figureName} for $_unlockCost coins'),
            backgroundColor: const Color(0xFF7B24FF),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unlock video. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<FigureModel> _filterFigures(List<FigureModel> source) {
    if (source.isEmpty) {
      return <FigureModel>[];
    }
    return source
        .where((FigureModel figure) =>
            !_blockedFigureIds.contains(figure.figureName) &&
            !_mutedFigureIds.contains(figure.figureName))
        .toList();
  }

  Future<void> _blockFigure(FigureModel figure) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _blockedFigureIds.add(figure.figureName);
      _figures = _filterFigures(_allFigures);
    });
    await prefs.setStringList(
      _blockedStorageKey,
      _blockedFigureIds.toList(),
    );
  }

  Future<void> _muteFigure(FigureModel figure) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _mutedFigureIds.add(figure.figureName);
      _figures = _filterFigures(_allFigures);
    });
    await prefs.setStringList(
      _mutedStorageKey,
      _mutedFigureIds.toList(),
    );
  }

  void _showReportActionSheet(FigureModel figure) {
    final BuildContext rootContext = context;
    showCupertinoModalPopup<void>(
      context: rootContext,
      builder: (BuildContext sheetContext) => CupertinoActionSheet(
        title: const Text('Choose an action'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(rootContext).push(
                MaterialPageRoute<ReportDetailPage>(
                  builder: (BuildContext context) =>
                      ReportDetailPage(figure: figure),
                ),
              );
            },
            child: const Text('Report'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await _blockFigure(figure);
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(
                  content: Text('Blocked ${figure.figureName}.'),
                ),
              );
            },
            child: const Text('Block'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await _muteFigure(figure);
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(
                  content: Text('Muted ${figure.figureName}.'),
                ),
              );
            },
            child: const Text('Mute'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(sheetContext).pop();
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double topSafe = MediaQuery.of(context).padding.top;
    final double topPadding = topSafe + 32;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF4C1BCC),
              Color(0xFF1A0138),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    topPadding,
                    20,
                    24,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/activity_top_mood.webp',
                        width: screenSize.width - 40,
                        height: 141,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              top: topPadding + 24 + 34 + 141,
              width: screenSize.width - 40,
              height: screenSize.height - topPadding - 24 - 34 - 141 - 24 - 64,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Stack(
                  children: <Widget>[
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _musicFigures.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: <Widget>[
                            Image.asset(
                              _musicFigures[index],
                              width: screenSize.width - 40,
                              height: screenSize.height - topPadding - 24 - 34 - 141 - 24 - 64,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              left: 100,
                              right: 100,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6121B3),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Center(
                                  child: Text(
                                    _teacherNames[index],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    if (_isTeacherLocked(_currentPageIndex))
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.lock_fill,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_currentPageIndex > 0)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.chevron_left,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_currentPageIndex < _musicFigures.length - 1)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.chevron_right,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTeacherLocked(_currentPageIndex)
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF7B24FF),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                          onPressed: () {
                            if (_isTeacherLocked(_currentPageIndex)) {
                              _unlockTeacher(_currentPageIndex);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute<ActivityTeacherPage>(
                                  builder: (BuildContext context) =>
                                      ActivityTeacherPage(
                                    teacherIndex: _currentPageIndex,
                                    teacherName: _teacherNames[_currentPageIndex],
                                    teacherAvatar: _musicFigures[_currentPageIndex],
                                    teacherSayhi: _teacherSayhi[_currentPageIndex],
                                    teacherMotto: _teacherMotto[_currentPageIndex],
                                    teacherMusicStyles:
                                        _teacherMusicStyles[_currentPageIndex],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            _isTeacherLocked(_currentPageIndex)
                                ? 'Unlock $_unlockCost Coins'
                                : 'Start Chat',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveCoverPath(FigureModel figure) {
    final String iconPath = figure.userIcon;
    final int lastSlash = iconPath.lastIndexOf('/');
    if (lastSlash == -1) {
      return iconPath;
    }
    final String directory = iconPath.substring(0, lastSlash);
    final RegExp idReg = RegExp(r'figure_(\d+)_');
    final Match? match = idReg.firstMatch(iconPath);
    final String id =
        match != null ? match.group(1)! : directory.split('/').last;
    return '$directory/figure_${id}_video_cover.jpg';
  }

  String _resolveVideoPath(FigureModel figure) {
    final String iconPath = figure.userIcon;
    final int lastSlash = iconPath.lastIndexOf('/');
    if (lastSlash == -1) {
      return iconPath;
    }
    final String directory = iconPath.substring(0, lastSlash);
    final RegExp idReg = RegExp(r'figure_(\d+)_');
    final Match? match = idReg.firstMatch(iconPath);
    final String id =
        match != null ? match.group(1)! : directory.split('/').last;
    return '$directory/figure_${id}_video.mp4';
  }
}
