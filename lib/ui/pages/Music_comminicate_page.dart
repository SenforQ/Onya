import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/figure_model.dart';
import 'figure_detail_page.dart';
import 'report_detail_page.dart';

class MusicComminicatePage extends StatefulWidget {
  const MusicComminicatePage({super.key});

  @override
  State<MusicComminicatePage> createState() => _MusicComminicatePageState();
}

class _MusicComminicatePageState extends State<MusicComminicatePage> {
  List<FigureModel> _allFigures = <FigureModel>[];
  List<FigureModel> _figures = <FigureModel>[];
  final Set<String> _likedFigureIds = <String>{};
  final Map<String, List<CommentEntry>> _comments =
      <String, List<CommentEntry>>{};
  final Set<String> _blockedFigureIds = <String>{};
  final Set<String> _mutedFigureIds = <String>{};

  String? _userAvatarPath;
  String _userNickname = 'Onya';

  static const String _likedStorageKey = 'dynamic_liked_figures';
  static const String _commentsStorageKey = 'dynamic_comments';
  static const String _likeMessagesStorageKey = 'dynamic_like_messages';
  static const String _avatarStorageKey = 'avatar_path';
  static const String _nicknameStorageKey = 'nickname';
  static const String _blockedStorageKey = 'dynamic_blocked_figures';
  static const String _mutedStorageKey = 'dynamic_muted_figures';

  @override
  void initState() {
    super.initState();
    _loadBlockAndMuteSettings();
    _loadFiguresData();
    _loadLikedFigureIds();
    _loadComments();
    _loadUserProfile();
  }

  Future<void> _loadFiguresData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/figures_data.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final List<FigureModel> fetchedFigures = jsonList
          .map((dynamic json) =>
              FigureModel.fromJson(json as Map<String, dynamic>))
          .toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _allFigures = fetchedFigures;
        _figures = _filterFigures(fetchedFigures);
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadLikedFigureIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? storedIds = prefs.getStringList(_likedStorageKey);
    if (!mounted) {
      return;
    }
    if (storedIds != null) {
      setState(() {
        _likedFigureIds
          ..clear()
          ..addAll(storedIds);
      });
    }
  }

  Future<void> _toggleLike(FigureModel figure) async {
    final String figureId = figure.figureName;
    final bool willLike = !_likedFigureIds.contains(figureId);

    setState(() {
      if (willLike) {
        _likedFigureIds.add(figureId);
      } else {
        _likedFigureIds.remove(figureId);
      }
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_likedStorageKey, _likedFigureIds.toList());
    
    // Save like message
    await _saveLikeMessage(figure, willLike);
  }

  Future<void> _saveLikeMessage(FigureModel figure, bool isLiked) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString(_likeMessagesStorageKey);
    final List<Map<String, dynamic>> messages = messagesJson != null
        ? (json.decode(messagesJson) as List<dynamic>)
            .map((dynamic e) => e as Map<String, dynamic>)
            .toList()
        : <Map<String, dynamic>>[];

    messages.add(<String, dynamic>{
      'figureName': figure.figureName,
      'figureIcon': figure.userIcon,
      'isLiked': isLiked,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await prefs.setString(_likeMessagesStorageKey, json.encode(messages));
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
      _figures = _filterFigures(_allFigures);
    });
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
    await _loadFiguresData();
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
    await _loadFiguresData();
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
          _comments.clear();
          commentsMap.forEach((String key, dynamic value) {
            _comments[key] = (value as List<dynamic>)
                .map((dynamic e) =>
                    CommentEntry.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        });
      } catch (_) {
        // ignore malformed data
      }
    }
  }

  Future<void> _saveComments() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encodableMap = _comments.map(
      (String key, List<CommentEntry> value) => MapEntry(
        key,
        value.map((CommentEntry e) => e.toJson()).toList(),
      ),
    );
    await prefs.setString(_commentsStorageKey, json.encode(encodableMap));
  }

  Future<void> _loadUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _userAvatarPath = prefs.getString(_avatarStorageKey);
      _userNickname = prefs.getString(_nicknameStorageKey) ?? 'Onya';
    });
  }

  Future<CommentEntry> _addComment(FigureModel figure, String content) async {
    final CommentEntry entry = CommentEntry(
      userName: _userNickname,
      content: content,
      avatarPath: _userAvatarPath,
      figureIcon: figure.userIcon,
      figureMotto: figure.showMotto,
    );

    setState(() {
      _comments.putIfAbsent(figure.figureName, () => <CommentEntry>[]);
      _comments[figure.figureName]!.add(entry);
    });

    await _saveComments();
    await _loadComments();

    return entry;
  }

  void _showCommentDialog(FigureModel figure) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => _CommentDialog(
        figure: figure,
        comments: List<CommentEntry>.from(
          _comments[figure.figureName] ?? <CommentEntry>[],
        ),
        onCommentAdded: (String comment) => _addComment(figure, comment),
      ),
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
                'Music Comminicate',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 24,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(
                top: 44 + 24,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _figures.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildCell(
                    context,
                    _figures[index],
                    screenSize.width - 40,
                    index,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    FigureModel figure,
    double cellWidth,
    int index,
  ) {
    final bool isLiked = _likedFigureIds.contains(figure.figureName);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<FigureDetailPage>(
            builder: (BuildContext context) => FigureDetailPage(figure: figure),
          ),
        );
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: cellWidth,
        height: 426,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(
                      height: 320,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _toggleLike(figure);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Image.asset(
                              isLiked
                                  ? 'assets/dynamic_like_pre.webp'
                                  : 'assets/dynamic_like_nor.webp',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              _showCommentDialog(figure);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Image.asset(
                              'assets/dynamic_comment.webp',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              _showReportActionSheet(figure);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Image.asset(
                              'assets/dynamic_report.webp',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        figure.showPhotoArray.isNotEmpty
                            ? figure.showPhotoArray[0]
                            : figure.userIcon,
                        height: 320,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF2ED0),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            figure.userIcon,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        figure.figureName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      figure.showMotto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentDialog extends StatefulWidget {
  const _CommentDialog({
    required this.figure,
    required this.comments,
    required this.onCommentAdded,
  });

  final FigureModel figure;
  final List<CommentEntry> comments;
  final Future<CommentEntry> Function(String) onCommentAdded;

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final List<CommentEntry> _commentItems =
      List<CommentEntry>.from(widget.comments);

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final CommentEntry entry = await widget.onCommentAdded(text);
    _textController.clear();
    setState(() {
      _commentItems.add(entry);
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double dialogHeight = screenSize.height * 0.7;

    return Container(
      height: dialogHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E5E5),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Comment',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    CupertinoIcons.xmark,
                    size: 20,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _commentItems.isEmpty
                ? const Center(
                    child: Text(
                      'No comments yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF999999),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _commentItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CommentEntry entry = _commentItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                _CommentAvatar(avatarPath: entry.avatarPath),
                                const SizedBox(height: 6),
                                Text(
                                  entry.userName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  entry.content,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E5E5),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CupertinoTextField(
                    controller: _textController,
                    placeholder: 'Add a comment...',
                    placeholderStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 15,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
                const SizedBox(width: 12),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: _sendComment,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B24FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_up,
                      size: 20,
                      color: Colors.white,
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
        width: 36,
        height: 36,
        fit: BoxFit.cover,
      );
    } else {
      avatarWidget = Image.asset(
        'assets/user_default_headericon.webp',
        width: 36,
        height: 36,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 36,
      height: 36,
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

