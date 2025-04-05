import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:speak_up/domain/entities/youtube_video/youtube_video.dart';
import 'package:speak_up/presentation/pages/reels/reels_view_model.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ReelsView extends ConsumerStatefulWidget {
  const ReelsView({super.key});

  @override
  ConsumerState<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends ConsumerState<ReelsView> {
  late final PreloadPageController preloadPageController;
  late List<String> videoList;
  late int initialIndex;

  @override
  void initState() {
    super.initState();
    preloadPageController = PreloadPageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    videoList = args['videos'] as List<String>;
    initialIndex = args['initialIndex'] as int;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (preloadPageController.hasClients) {
        preloadPageController.jumpToPage(initialIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          if (videoList.isNotEmpty)
            PreloadPageView.builder(
              controller: preloadPageController,
              preloadPagesCount: 1,
              scrollDirection: Axis.vertical,
              itemCount: videoList.length,
              itemBuilder: (context, index) {
                final videoPath = videoList[index];
                return VideoPlayerWidget(videoPath: videoPath);
              },
            )
          else
            const Center(
              child: Text(
                'No videos available',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 32,
            left: 10,
            child: Padding(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(16)),
              child: CircleAvatar(
                radius: ScreenUtil().setHeight(22),
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: ScreenUtil().setHeight(20),
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    preloadPageController.dispose();
    super.dispose();
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  VideoPlayerWidget({required this.videoPath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath.startsWith('assets/')) {
      _controller = VideoPlayerController.asset(widget.videoPath);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.play();
    });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: FittedBox(
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height * 2,
                    child: VideoPlayer(_controller),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading video: ${snapshot.error}'),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
