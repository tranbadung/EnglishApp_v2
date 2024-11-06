import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_up/presentation/pages/reels/reels_state.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';

class ReelsViewModel extends StateNotifier<ReelsState> {
  ReelsViewModel() : super(const ReelsState()) {
    _loadLocalVideos();
  }

  final List<String> _localVideoPaths = [
    'assets/reels/hoc-tieng-anh-video-ngan-1.mp4',
    'assets/reels/hoc-tieng-anh-video-ngan-2.mp4',
    'assets/reels/hoc-tieng-anh-video-ngan-3.mp4',
    'assets/reels/hoc-tieng-anh-video-ngan-4.mp4',
  ];

  // Danh sách các hình ảnh cho video
  final List<String> _videoThumbnails = [
    'assets/images/thumbnail1.jpg',
    'assets/images/thumbnail2.jpg',
    'assets/images/thumbnail3.jpg',
    'assets/images/thumbnail4.jpg',
  ];

  void _loadLocalVideos() {
    state = state.copyWith(
      loadingStatus: LoadingStatus.success,
      localVideos: _localVideoPaths,
      videoThumbnails: _videoThumbnails, // Gán danh sách hình ảnh cho video
      isUsingLocalVideos: true,
    );
  }
}

final reelsViewModelProvider =
    StateNotifierProvider<ReelsViewModel, ReelsState>(
  (ref) {
    return ReelsViewModel();
  },
);
