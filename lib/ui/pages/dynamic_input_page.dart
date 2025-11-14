import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicInputPage extends StatefulWidget {
  const DynamicInputPage({super.key});

  @override
  State<DynamicInputPage> createState() => _DynamicInputPageState();
}

class _DynamicInputPageState extends State<DynamicInputPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String? _selectedMusicStyle;
  bool _hasInstrument = false;

  final List<String> _musicStyles = <String>[
    'Pop',
    'Rock',
    'Jazz',
    'Classical',
    'Electronic',
    'Hip-Hop',
    'Country',
    'Folk',
    'Blues',
    'Soul',
    'Indie',
    'Ambient',
    'Dance',
    'Acoustic',
    'Soft Rock',
  ];

  static const String _activityJoinedKey = 'activity_joined';

  @override
  void dispose() {
    _nicknameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your nickname'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your contact information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMusicStyle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a music style'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save form data
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('activity_nickname', _nicknameController.text.trim());
    await prefs.setString('activity_contact', _contactController.text.trim());
    await prefs.setString('activity_music_style', _selectedMusicStyle!);
    await prefs.setBool('activity_has_instrument', _hasInstrument);
    await prefs.setBool(_activityJoinedKey, true);

    if (mounted) {
      Navigator.of(context).pop(true); // Return true to indicate success
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
            child: const Center(
              child: Text(
                'Activity Registration',
                style: TextStyle(
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTextField(
                    controller: _nicknameController,
                    label: 'Nickname',
                    hint: 'Enter your nickname',
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _contactController,
                    label: 'Ins/WhatsApp Contact',
                    hint: 'Enter your contact information',
                  ),
                  const SizedBox(height: 24),
                  _buildMusicStyleSelector(),
                  const SizedBox(height: 24),
                  _buildInstrumentSelector(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B24FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF999999),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111111),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMusicStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Favorite Music Style',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _musicStyles.map((String style) {
            final bool isSelected = _selectedMusicStyle == style;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMusicStyle = style;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7B24FF)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF7B24FF)
                        : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  style,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInstrumentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Do you play any instruments?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  _hasInstrument = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _hasInstrument
                      ? const Color(0xFF7B24FF)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _hasInstrument
                        ? const Color(0xFF7B24FF)
                        : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _hasInstrument = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: !_hasInstrument
                      ? const Color(0xFF7B24FF)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: !_hasInstrument
                        ? const Color(0xFF7B24FF)
                        : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'No',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

