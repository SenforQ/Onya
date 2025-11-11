import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/vip_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _avatarPath;
  String _nickname = 'Onya';
  String _signature = 'Join us and play music';
  String _gender = 'Male';
  String _musicTag = 'Pop, Rock, Jazz';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString('avatar_path');
      _nickname = prefs.getString('nickname') ?? 'Onya';
      _signature = prefs.getString('signature') ?? 'Join us and play music';
      _gender = prefs.getString('gender') ?? 'Male';
      _musicTag = prefs.getString('music_tag') ?? 'Pop, Rock, Jazz';
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = '${appDocDir.path}/$fileName';
        final File savedImage = await File(image.path).copy(filePath);

        setState(() {
          _avatarPath = savedImage.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    // 检测是否为会员
    final bool isVipActive = await VipService.isVipActive();
    final bool isVipExpired = await VipService.isVipExpired();
    final bool isVip = isVipActive && !isVipExpired;

    if (!isVip) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VIP membership required to save settings'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      
      String? relativePath;
      if (_avatarPath != null) {
        final File avatarFile = File(_avatarPath!);
        if (avatarFile.existsSync()) {
          final String fileName = avatarFile.path.split('/').last;
          final String targetPath = '${appDocDir.path}/$fileName';
          
          if (avatarFile.path != targetPath) {
            final File savedFile = await avatarFile.copy(targetPath);
            relativePath = savedFile.path;
          } else {
            relativePath = _avatarPath;
          }
        }
      }

      await prefs.setString('avatar_path', relativePath ?? '');
      await prefs.setString('nickname', _nickname);
      await prefs.setString('signature', _signature);
      await prefs.setString('gender', _gender);
      await prefs.setString('music_tag', _musicTag);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF7B24FF),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Image.asset(
              'assets/mine_bg.webp',
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: statusBarHeight + 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: <Widget>[
                              ClipOval(
                                child: _avatarPath != null && File(_avatarPath!).existsSync()
                                    ? Image.file(
                                        File(_avatarPath!),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/user_default_headericon.webp',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF7B24FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInfoItem(
                          label: 'Nickname',
                          value: _nickname,
                          onTap: () {
                            _showEditDialog('Nickname', _nickname, (String value) {
                              setState(() {
                                _nickname = value;
                              });
                            });
                          },
                        ),
                        const Divider(height: 1),
                        _buildInfoItem(
                          label: 'Signature',
                          value: _signature,
                          onTap: () {
                            _showEditDialog('Signature', _signature, (String value) {
                              setState(() {
                                _signature = value;
                              });
                            });
                          },
                        ),
                        const Divider(height: 1),
                        _buildInfoItem(
                          label: 'Gender',
                          value: _gender,
                          onTap: () {
                            _showGenderPicker();
                          },
                        ),
                        const Divider(height: 1),
                        _buildInfoItem(
                          label: 'Music Tag',
                          value: _musicTag,
                          onTap: () {
                            _showEditDialog('Music Tag', _musicTag, (String value) {
                              setState(() {
                                _musicTag = value;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B24FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/nav_back.webp',
                        fit: BoxFit.contain,
                      ),
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

  Widget _buildInfoItem({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A0138),
              ),
            ),
            const Spacer(),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF999999),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String title, String initialValue, ValueChanged<String> onSave) {
    final TextEditingController controller = TextEditingController(text: initialValue);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showGenderPicker() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Gender'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Male'),
                onTap: () {
                  setState(() {
                    _gender = 'Male';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Female'),
                onTap: () {
                  setState(() {
                    _gender = 'Female';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Other'),
                onTap: () {
                  setState(() {
                    _gender = 'Other';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
