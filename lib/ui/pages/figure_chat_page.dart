import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/figure_model.dart';

class FigureChatPage extends StatefulWidget {
  const FigureChatPage({super.key, required this.figure});

  final FigureModel figure;

  @override
  State<FigureChatPage> createState() => _FigureChatPageState();
}

class _FigureChatPageState extends State<FigureChatPage> {
  static const String _apiKey =
      '72c2921fbdcc4d4a8e6a0e6cb447e6ee.FEli4FrumBlPKnSh';
  static const String _apiUrl =
      'https://open.bigmodel.cn/api/paas/v4/chat/completions';

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        role: 'assistant',
        content:
            "Hello, I'm ${widget.figure.figureName}. How can I help you today?",
      ),
    );
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
    await _scrollToBottom();

    try {
      final List<Map<String, String>> requestMessages =
          <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content':
              'You are ${widget.figure.figureName}, a friendly voice actor who loves storytelling. Reply in English and keep responses concise.',
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
                          'Chat with ${widget.figure.figureName}',
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
                      return Align(
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                          ),
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
}

