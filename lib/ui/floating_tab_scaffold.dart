import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/activity_page.dart';
import 'pages/dynamic_page.dart';
import 'pages/mine_page.dart';

class FloatingTabScaffold extends StatefulWidget {
  const FloatingTabScaffold({super.key});

  @override
  State<FloatingTabScaffold> createState() => _FloatingTabScaffoldState();
}

class _FloatingTabScaffoldState extends State<FloatingTabScaffold> {
  int _currentIndex = 0;

  final List<_TabItemData> _items = const <_TabItemData>[
    _TabItemData(
      title: 'Home',
      iconAsset: 'assets/tab_home.webp',
    ),
    _TabItemData(
      title: 'Activity',
      iconAsset: 'assets/tab_activity.webp',
    ),
    _TabItemData(
      title: 'Dynamic',
      iconAsset: 'assets/tab_dynamic.webp',
    ),
    _TabItemData(
      title: 'Me',
      iconAsset: 'assets/tab_me.webp',
    ),
  ];

  late final List<Widget> _pages = <Widget>[
    const HomePage(),
    const ActivityPage(),
    const DynamicPage(),
    const MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double itemWidth = size.width / _items.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0138),
      extendBody: true,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: size.width,
                height: 64,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/tab_content_bg.webp'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(_items.length, (int index) {
                      final bool isSelected = index == _currentIndex;
                      final _TabItemData item = _items[index];
                      return GestureDetector(
                        onTap: () {
                          if (_currentIndex != index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          }
                        },
                        behavior: HitTestBehavior.translucent,
                        child: SizedBox(
                          width: itemWidth,
                          height: 64,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              if (isSelected)
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/tab_Select.webp',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: Image.asset(
                                  item.iconAsset,
                                  width: 56,
                                  height: 56,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItemData {
  const _TabItemData({required this.title, required this.iconAsset});

  final String title;
  final String iconAsset;
}

