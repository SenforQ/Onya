import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/figure_model.dart';
import 'figure_chat_page.dart';
import 'figure_image_detail_page.dart';
import 'figure_video_detail_page.dart';
import 'figure_video_page.dart';

class FigureDetailPage extends StatelessWidget {
  const FigureDetailPage({super.key, required this.figure});

  final FigureModel figure;

  bool _isVideoFile(String path) {
    return path.toLowerCase().endsWith('.mp4') ||
        path.toLowerCase().endsWith('.mov') ||
        path.toLowerCase().endsWith('.avi');
  }

  bool _isVideoCover(String path) {
    // 检查路径是否包含 video_cover
    if (path.contains('video_cover')) {
      return true;
    }
    
    // 根据 figure 的 userIcon 路径生成视频封面路径并比较
    final String iconPath = figure.userIcon;
    final int lastSlash = iconPath.lastIndexOf('/');
    if (lastSlash != -1) {
      final String directory = iconPath.substring(0, lastSlash);
      final RegExp idReg = RegExp(r'figure_(\d+)_');
      final Match? match = idReg.firstMatch(iconPath);
      final String id =
          match != null ? match.group(1)! : directory.split('/').last;
      final String videoCoverPath = '$directory/figure_${id}_video_cover.jpg';
      return path == videoCoverPath;
    }
    
    return false;
  }

  String _resolveVideoPath(FigureModel figure) {
    final String iconPath = figure.userIcon;
    final int lastSlash = iconPath.lastIndexOf('/');
    if (lastSlash == -1) {
      return iconPath;
    }
    final String directory = iconPath.substring(0, lastSlash);
    final RegExp idReg = RegExp(r'figure_(\d+)_');
    final Match? match = idReg.firstMatch(iconPath);
    final String id =
        match != null ? match.group(1)! : directory.split('/').last;
    return '$directory/figure_${id}_video.mp4';
  }

  String _resolveVideoCoverPath(FigureModel figure) {
    final String iconPath = figure.userIcon;
    final int lastSlash = iconPath.lastIndexOf('/');
    if (lastSlash == -1) {
      return iconPath;
    }
    final String directory = iconPath.substring(0, lastSlash);
    final RegExp idReg = RegExp(r'figure_(\d+)_');
    final Match? match = idReg.firstMatch(iconPath);
    final String id =
        match != null ? match.group(1)! : directory.split('/').last;
    return '$directory/figure_${id}_video_cover.jpg';
  }

  void _handleGalleryItemTap(BuildContext context, String itemPath, int index) {
    if (_isVideoFile(itemPath)) {
      // 如果是视频文件，直接跳转到视频详情页
      Navigator.of(context).push(
        MaterialPageRoute<FigureVideoDetailPage>(
          builder: (BuildContext context) => FigureVideoDetailPage(
            figure: figure,
            videoPath: itemPath,
          ),
        ),
      );
    } else {
      // 如果是图片，检查是否是视频封面图
      final String iconPath = figure.userIcon;
      final int lastSlash = iconPath.lastIndexOf('/');
      if (lastSlash != -1) {
        final String directory = iconPath.substring(0, lastSlash);
        final RegExp idReg = RegExp(r'figure_(\d+)_');
        final Match? match = idReg.firstMatch(iconPath);
        final String id =
            match != null ? match.group(1)! : directory.split('/').last;
        final String videoCoverPath = '$directory/figure_${id}_video_cover.jpg';
        
        // 如果点击的是视频封面图，跳转到视频页面
        if (itemPath == videoCoverPath || itemPath.contains('video_cover')) {
          final String videoPath = _resolveVideoPath(figure);
          Navigator.of(context).push(
            MaterialPageRoute<FigureVideoDetailPage>(
              builder: (BuildContext context) => FigureVideoDetailPage(
                figure: figure,
                videoPath: videoPath,
              ),
            ),
          );
          return;
        }
      }
      
      // 否则跳转到图片详情页
      final List<String> photos = figure.showPhotoArray.isNotEmpty
          ? figure.showPhotoArray
          : <String>[figure.userIcon];
      Navigator.of(context).push(
        MaterialPageRoute<FigureImageDetailPage>(
          builder: (BuildContext context) => FigureImageDetailPage(
            figure: figure,
            imagePath: itemPath,
            imageList: photos,
            initialIndex: index,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final List<String> photos = figure.showPhotoArray.isNotEmpty
        ? figure.showPhotoArray
        : <String>[figure.userIcon];

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          figure.figureName,
                          style: const TextStyle(
                            fontSize: 22,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFF2ED0),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  figure.userIcon,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    figure.figureName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    figure.showMotto,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7B24FF),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<FigureChatPage>(
                                      builder: (BuildContext context) =>
                                          FigureChatPage(figure: figure),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Chat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<FigureVideoPage>(
                                      builder: (BuildContext context) =>
                                          FigureVideoPage(figure: figure),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Video Call',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7B24FF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Video',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            final String videoPath = _resolveVideoPath(figure);
                            Navigator.of(context).push(
                              MaterialPageRoute<FigureVideoDetailPage>(
                                builder: (BuildContext context) =>
                                    FigureVideoDetailPage(
                                  figure: figure,
                                  videoPath: videoPath,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: <Widget>[
                                Image.asset(
                                  _resolveVideoCoverPath(figure),
                                  width: double.infinity,
                                  height: screenSize.width * 0.6,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (BuildContext context, Object _,
                                          StackTrace? __) {
                                    final String fallback =
                                        figure.showPhotoArray.isNotEmpty
                                            ? figure.showPhotoArray.first
                                            : figure.userIcon;
                                    return Image.asset(
                                      fallback,
                                      width: double.infinity,
                                      height: screenSize.width * 0.6,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Center(
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.play_circle_fill,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Gallery',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: photos
                              .asMap()
                              .entries
                              .map(
                                (MapEntry<int, String> entry) => GestureDetector(
                                  onTap: () {
                                    _handleGalleryItemTap(
                                      context,
                                      entry.value,
                                      entry.key,
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: <Widget>[
                                        Image.asset(
                                          entry.value,
                                          width: (screenSize.width - 16 * 2 - 24) / 3,
                                          height: (screenSize.width - 16 * 2 - 24) /
                                              3,
                                          fit: BoxFit.cover,
                                        ),
                                        if (_isVideoCover(entry.value))
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  CupertinoIcons.play_circle_fill,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                      ],
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

