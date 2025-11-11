import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'privacy_policy_page.dart';
import 'terms_page.dart';
import 'about_us.page.dart';
import 'settings_page.dart';
import 'vip_page.dart';
import 'wallet_page.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  String? _avatarPath;
  String _nickname = 'Onya';
  String _signature = 'Join us and play music';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString('avatar_path');
      _nickname = prefs.getString('nickname') ?? 'Onya';
      _signature = prefs.getString('signature') ?? 'Join us and play music';
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double topImageHeight = 250.0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/mine_bg.webp',
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.cover,
            ),
          ),
          CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Stack(
                  children: <Widget>[
                    SizedBox(
                      width: screenSize.width,
                      height: topImageHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.asset(
                            'assets/me_header_top_bg.webp',
                            width: screenSize.width,
                            height: topImageHeight,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Colors.transparent,
                                    const Color(0xFF1A0138),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: <Widget>[
                            ClipOval(
                              child: _avatarPath != null && File(_avatarPath!).existsSync()
                                  ? Image.file(
                                      File(_avatarPath!),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/user_default_headericon.webp',
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    _nickname,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A0138),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _signature,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final bool? result = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute<bool>(
                                    builder: (BuildContext context) => const SettingsPage(),
                                  ),
                                );
                                if (result == true) {
                                  _loadUserInfo();
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.settings,
                                  color: Color(0xFF1A0138),
                                  size: 20,
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: <Widget>[
                      _buildMenuItem(
                        iconAsset: 'assets/me_wallet.webp',
                        title: 'Wallet',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<WalletPage>(
                              builder: (BuildContext context) => const WalletPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        iconAsset: 'assets/me_vip.webp',
                        title: 'Vip',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<VipPage>(
                              builder: (BuildContext context) => const VipPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        iconAsset: 'assets/me_contract.webp',
                        title: 'User Contract',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<TermsPage>(
                              builder: (BuildContext context) => const TermsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        iconAsset: 'assets/me_policy.webp',
                        title: 'Privacy Policy',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<PrivacyPolicyPage>(
                              builder: (BuildContext context) => const PrivacyPolicyPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMenuItem(
                        iconAsset: 'assets/me_us.webp',
                        title: 'About us',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<AboutUsPage>(
                              builder: (BuildContext context) => const AboutUsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 66),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconAsset,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A0F4F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Image.asset(
              iconAsset,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

