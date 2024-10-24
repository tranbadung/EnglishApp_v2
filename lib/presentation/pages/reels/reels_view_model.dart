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
   void _loadLocalVideos() {
  
     state = state.copyWith(
      loadingStatus: LoadingStatus.success,
      localVideos: _localVideoPaths,  
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
