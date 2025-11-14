import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/figure_model.dart';

class DynamicCommentPage extends StatefulWidget {
  const DynamicCommentPage({super.key});

  @override
  State<DynamicCommentPage> createState() => _DynamicCommentPageState();
}

class _DynamicCommentPageState extends State<DynamicCommentPage> {
  final List<CommentEntry> _allComments = <CommentEntry>[];
  final Map<String, String> _figureIconMap = <String, String>{};
  final Map<String, String> _figureMottoMap = <String, String>{};
  static const String _commentsStorageKey = 'dynamic_comments';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadFiguresData();
    if (mounted) {
      await _loadComments();
    }
  }

  Future<void> _loadFiguresData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/figures_data.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      for (final dynamic json in jsonList) {
        final FigureModel figure =
            FigureModel.fromJson(json as Map<String, dynamic>);
        _figureIconMap[figure.figureName] = figure.userIcon;
        _figureMottoMap[figure.figureName] = figure.showMotto;
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadComments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? commentsJson = prefs.getString(_commentsStorageKey);
    if (!mounted) {
      return;
    }
    if (commentsJson != null) {
      try {
        final Map<String, dynamic> commentsMap =
            json.decode(commentsJson) as Map<String, dynamic>;
        setState(() {
          _allComments.clear();
          commentsMap.forEach((String figureName, dynamic value) {
            final List<CommentEntry> comments = (value as List<dynamic>)
                .map((dynamic e) {
                  final Map<String, dynamic> commentJson = e as Map<String, dynamic>;
                  // If figureIcon is not in the comment, try to get it from figure data
                  if (commentJson['figureIcon'] == null) {
                    // Try to resolve figure icon from figureName
                    // This is a fallback for old comments
                    commentJson['figureIcon'] = _resolveFigureIcon(figureName);
                  }
                  // If figureMotto is not in the comment, try to get it from figure data
                  if (commentJson['figureMotto'] == null) {
                    commentJson['figureMotto'] = _resolveFigureMotto(figureName);
                  }
                  return CommentEntry.fromJson(commentJson);
                })
                .toList();
            _allComments.addAll(comments);
          });
          // Sort by timestamp if available, newest first
          _allComments.sort((CommentEntry a, CommentEntry b) {
            // Since CommentEntry doesn't have timestamp, we'll keep original order
            return 0;
          });
        });
      } catch (_) {
        // ignore malformed data
      }
    }
  }

  String _resolveFigureIcon(String figureName) {
    // Try to find figure icon from loaded figure data
    return _figureIconMap[figureName] ?? 'assets/figure/1/figure_1_img_1.webp';
  }

  String _resolveFigureMotto(String figureName) {
    // Try to find figure motto from loaded figure data
    return _figureMottoMap[figureName] ?? '';
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
                'My Comment',
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
            child: _allComments.isEmpty
                ? const Center(
                    child: Text(
                      'No Comments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _allComments.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CommentEntry comment = _allComments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _CommentAvatar(avatarPath: comment.avatarPath),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    comment.userName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    comment.content,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (comment.figureIcon != null && comment.figureIcon!.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              if (comment.figureMotto != null && comment.figureMotto!.isNotEmpty)
                                Container(
                                  width: 60,
                                  height: 60,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    comment.figureMotto!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF666666),
                                      height: 1.2,
                                    ),
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  comment.figureIcon!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context, Object _, StackTrace? __) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({required this.avatarPath});

  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final Widget avatarWidget;
    if (avatarPath != null &&
        avatarPath!.isNotEmpty &&
        File(avatarPath!).existsSync()) {
      avatarWidget = Image.file(
        File(avatarPath!),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      );
    } else {
      avatarWidget = Image.asset(
        'assets/user_default_headericon.webp',
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF5F5F5),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarWidget,
    );
  }
}

class CommentEntry {
  const CommentEntry({
    required this.userName,
    required this.content,
    this.avatarPath,
    this.figureIcon,
    this.figureMotto,
  });

  factory CommentEntry.fromJson(Map<String, dynamic> json) {
    return CommentEntry(
      userName: json['userName'] as String? ?? 'Onya',
      content: json['content'] as String? ?? '',
      avatarPath: json['avatarPath'] as String?,
      figureIcon: json['figureIcon'] as String?,
      figureMotto: json['figureMotto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userName': userName,
      'content': content,
      'avatarPath': avatarPath,
      'figureIcon': figureIcon,
      'figureMotto': figureMotto,
    };
  }

  final String userName;
  final String content;
  final String? avatarPath;
  final String? figureIcon;
  final String? figureMotto;
}

