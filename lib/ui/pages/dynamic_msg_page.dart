import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicMsgPage extends StatefulWidget {
  const DynamicMsgPage({super.key});

  @override
  State<DynamicMsgPage> createState() => _DynamicMsgPageState();
}

class _DynamicMsgPageState extends State<DynamicMsgPage> {
  final List<LikeMessage> _likeMessages = <LikeMessage>[];
  static const String _likeMessagesStorageKey = 'dynamic_like_messages';

  @override
  void initState() {
    super.initState();
    _loadLikeMessages();
  }

  Future<void> _loadLikeMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString(_likeMessagesStorageKey);
    if (!mounted) {
      return;
    }
    if (messagesJson != null) {
      try {
        final List<dynamic> messagesList =
            json.decode(messagesJson) as List<dynamic>;
        setState(() {
          _likeMessages.clear();
          _likeMessages.addAll(
            messagesList
                .map((dynamic e) => LikeMessage.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
          // Sort by timestamp, newest first
          _likeMessages.sort((LikeMessage a, LikeMessage b) {
            return b.timestamp.compareTo(a.timestamp);
          });
        });
      } catch (_) {
        // ignore malformed data
      }
    }
  }

  Future<void> _removeMessage(LikeMessage message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString(_likeMessagesStorageKey);
    if (messagesJson != null) {
      try {
        final List<dynamic> messagesList =
            json.decode(messagesJson) as List<dynamic>;
        messagesList.removeWhere((dynamic e) {
          final Map<String, dynamic> msg = e as Map<String, dynamic>;
          return msg['figureName'] == message.figureName &&
              msg['timestamp'] == message.timestamp;
        });
        await prefs.setString(_likeMessagesStorageKey, json.encode(messagesList));
        if (!mounted) {
          return;
        }
        setState(() {
          _likeMessages.removeWhere((LikeMessage m) =>
              m.figureName == message.figureName &&
              m.timestamp == message.timestamp);
        });
      } catch (_) {
        // ignore malformed data
      }
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
                'Like/Unlike History',
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
            child: _likeMessages.isEmpty
                ? const Center(
                    child: Text(
                      'No Messages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _likeMessages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final LikeMessage message = _likeMessages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
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
                                  message.figureIcon,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    message.figureName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.isLiked
                                        ? 'You liked this character'
                                        : 'You unliked this character',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              message.isLiked
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              color: message.isLiked
                                  ? const Color(0xFFFF2ED0)
                                  : const Color(0xFF999999),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: () {
                                _removeMessage(message);
                              },
                              child: const Text(
                                'Know',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7B24FF),
                                ),
                              ),
                            ),
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

class LikeMessage {
  const LikeMessage({
    required this.figureName,
    required this.figureIcon,
    required this.isLiked,
    required this.timestamp,
  });

  factory LikeMessage.fromJson(Map<String, dynamic> json) {
    return LikeMessage(
      figureName: json['figureName'] as String? ?? '',
      figureIcon: json['figureIcon'] as String? ?? '',
      isLiked: json['isLiked'] as bool? ?? false,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  final String figureName;
  final String figureIcon;
  final bool isLiked;
  final int timestamp;
}

