import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/figure_model.dart';
import '../../services/coin_service.dart';
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

  static const String _blockedStorageKey = 'activity_blocked_figures';
  static const String _mutedStorageKey = 'activity_muted_figures';
  static const int _unlockCost = 200;

  @override
  void initState() {
    super.initState();
    _loadBlockAndMuteSettings();
    _loadFigures();
    // 每次进入页面时清除解锁状态
    _unlockedFigureIds.clear();
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
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                topSafe + 32,
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final FigureModel figure = _figures[index];
                    final String coverPath = _resolveCoverPath(figure);
                    final String videoPath = _resolveVideoPath(figure);
                    final bool isUnlocked = _unlockedFigureIds.contains(figure.figureName);
                    return Container(
                    height: 200,
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                      child: GestureDetector(
                        onTap: () async {
                          if (isUnlocked) {
                            Navigator.of(context).push(
                              MaterialPageRoute<ActivityVideoPage>(
                                builder: (BuildContext context) => ActivityVideoPage(
                                  figure: figure,
                                  videoPath: videoPath,
                                ),
                              ),
                            );
                          } else {
                            await _unlockVideo(figure);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      Image.asset(
                                        coverPath,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context, Object _, StackTrace? __) {
                                          final String fallback = figure.showPhotoArray.isNotEmpty
                                              ? figure.showPhotoArray.first
                                              : figure.userIcon;
                                          return Image.asset(
                                            fallback,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      if (!isUnlocked)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      if (isUnlocked)
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: Icon(
                                            Icons.play_circle_filled,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                        ),
                                      if (!isUnlocked)
                                        Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: <Color>[Color(0xFFFFD700), Color(0xFFFFA500)],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.monetization_on,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '$_unlockCost',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            _showReportActionSheet(figure);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.more_vert,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                figure.figureName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _figures.length,
                ),
              ),
            ),
            if (_figures.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
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
