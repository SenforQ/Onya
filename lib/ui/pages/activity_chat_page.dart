import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivityChatPage extends StatefulWidget {
  const ActivityChatPage({
    super.key,
    required this.teacherName,
    required this.teacherAvatar,
    required this.teacherSayhi,
    required this.teacherMotto,
    required this.teacherMusicStyles,
  });

  final String teacherName;
  final String teacherAvatar;
  final String teacherSayhi;
  final String teacherMotto;
  final List<String> teacherMusicStyles;

  @override
  State<ActivityChatPage> createState() => _ActivityChatPageState();
}

class _ActivityChatPageState extends State<ActivityChatPage> {
  static const String _apiKey =
      '72c2921fbdcc4d4a8e6a0e6cb447e6ee.FEli4FrumBlPKnSh';
  static const String _apiUrl =
      'https://open.bigmodel.cn/api/paas/v4/chat/completions';

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];

  bool _isSending = false;
  String? _userAvatarPath;

  String get _chatStorageKey => 'activity_chat_${widget.teacherName}';

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
    _loadChatHistory();
  }

  Future<void> _loadUserAvatar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? avatarPath = prefs.getString('avatar_path');
    if (mounted) {
      setState(() {
        _userAvatarPath = avatarPath;
      });
    }
  }

  Future<void> _loadChatHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? chatHistoryJson = prefs.getString(_chatStorageKey);
    
    if (chatHistoryJson != null && chatHistoryJson.isNotEmpty) {
      try {
        final List<dynamic> messagesJson = json.decode(chatHistoryJson) as List<dynamic>;
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(
              messagesJson.map(
                (dynamic json) => _ChatMessage.fromJson(json as Map<String, dynamic>),
              ),
            );
          });
          await _scrollToBottom();
        }
      } catch (e) {
        // 如果加载失败，使用默认的打招呼消息
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.add(
              _ChatMessage(
                role: 'assistant',
                content: widget.teacherSayhi,
              ),
            );
          });
        }
      }
    } else {
      // 如果没有保存的聊天记录，使用默认的打招呼消息
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              role: 'assistant',
              content: widget.teacherSayhi,
            ),
          );
        });
      }
    }
  }

  Future<void> _saveChatHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, String>> messagesJson = _messages
        .map((_ChatMessage msg) => <String, String>{
              'role': msg.role,
              'content': msg.content,
            })
        .toList();
    await prefs.setString(_chatStorageKey, json.encode(messagesJson));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _inputController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    final _ChatMessage userMessage =
        _ChatMessage(role: 'user', content: text);
    setState(() {
      _messages.add(userMessage);
      _isSending = true;
    });
    _inputController.clear();
    await _saveChatHistory();
    await _scrollToBottom();

    try {
      final String musicStylesStr = widget.teacherMusicStyles.join(', ');
      final List<Map<String, String>> requestMessages =
          <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are ${widget.teacherName}, a music teacher. ${widget.teacherMotto} You love ${musicStylesStr} music. Reply in English and keep responses concise and helpful.',
        },
        for (final _ChatMessage message in _messages)
          <String, String>{
            'role': message.role,
            'content': message.content,
          },
      ];

      final http.Response response = await http.post(
        Uri.parse(_apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(<String, dynamic>{
          'model': 'glm-4-flash',
          'messages': requestMessages,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> choices = data['choices'] as List<dynamic>;
        final Map<String, dynamic> message =
            choices.first['message'] as Map<String, dynamic>;
        final String reply = message['content'] as String? ?? '';

        if (reply.isNotEmpty) {
          setState(() {
            _messages.add(
              _ChatMessage(role: 'assistant', content: reply),
            );
          });
          await _saveChatHistory();
        }
      } else {
        setState(() {
          _messages.add(
            _ChatMessage(
              role: 'assistant',
              content:
                  'Sorry, I had trouble reaching the server. Please try again later.',
            ),
          );
        });
        await _saveChatHistory();
      }
    } catch (error) {
      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            content:
                'An error occurred while processing your request. Please try again.',
          ),
        );
      });
      await _saveChatHistory();
    } finally {
      setState(() {
        _isSending = false;
      });
      await _scrollToBottom();
    }
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/dynamic_base_bg.webp',
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          'Chat with ${widget.teacherName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final _ChatMessage message = _messages[index];
                      final bool isUser = message.role == 'user';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            if (!isUser) ...[
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFF2ED0),
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    widget.teacherAvatar,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: screenSize.width * 0.72,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF7B24FF)
                                      : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                                    bottomRight: Radius.circular(isUser ? 4 : 18),
                                  ),
                                ),
                                child: Text(
                                  message.content,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isUser ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF7B24FF),
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _userAvatarPath != null &&
                                          File(_userAvatarPath!).existsSync()
                                      ? Image.file(
                                          File(_userAvatarPath!),
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: const Color(0xFF7B24FF),
                                          child: const Icon(
                                            CupertinoIcons.person_fill,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  color: Colors.black26,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _isSending ? null : _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isSending
                                ? Colors.white24
                                : const Color(0xFF7B24FF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  CupertinoIcons.arrow_up,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
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

class _ChatMessage {
  const _ChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, String> toJson() => <String, String>{
        'role': role,
        'content': content,
      };

  factory _ChatMessage.fromJson(Map<String, dynamic> json) {
    return _ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}

