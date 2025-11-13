import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/figure_model.dart';

class FigureImageDetailPage extends StatefulWidget {
  const FigureImageDetailPage({
    super.key,
    required this.figure,
    required this.imagePath,
    required this.imageList,
    required this.initialIndex,
  });

  final FigureModel figure;
  final String imagePath;
  final List<String> imageList;
  final int initialIndex;

  @override
  State<FigureImageDetailPage> createState() => _FigureImageDetailPageState();
}

class _FigureImageDetailPageState extends State<FigureImageDetailPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageList.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.asset(
                      widget.imageList[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            if (widget.imageList.length > 1)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageList.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

