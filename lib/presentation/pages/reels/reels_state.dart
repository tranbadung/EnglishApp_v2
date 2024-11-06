import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:speak_up/domain/entities/youtube_video/youtube_video.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';

part 'reels_state.freezed.dart';

@freezed
class ReelsState with _$ReelsState {
  const factory ReelsState({
    @Default([]) List<YoutubeVideo> youtubeVideos,
    @Default([]) List<String> localVideos, // Thêm trường cho video local
    @Default([]) List<String> videoThumbnails, // Thêm trường cho thumbnail
    @Default(false)
    bool isUsingLocalVideos, // Flag để biết đang dùng loại video nào
    @Default(LoadingStatus.initial) LoadingStatus loadingStatus,
  }) = _ReelsState;
}
