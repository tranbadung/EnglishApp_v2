import 'package:dio/dio.dart';
import 'package:speak_up/data/remote/open_ai_client/open_ai_client.dart';
import 'package:speak_up/domain/entities/message/message.dart';
import 'package:speak_up/data/models/open_ai/open_ai_message_response.dart';

class OpenAIRepository {
  final OpenAIClient _openAIClient;

  OpenAIRepository(this._openAIClient);

  Future<Message> getMessage(List<Map<String, String>> messages) async {
    final body = {
      "model": "gpt-3.5-turbo",
      "messages": messages,
    };

    const int maxRetries = 5; // Số lần thử lại tối đa
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final response = await _openAIClient.getMessage(body);
        return Message(
          role: response.choices[0].message.role,
          content: response.choices[0].message.content,
        );
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 429) {
          // Kiểm tra Retry-After trong header (nếu có)
          var retryAfter = e.response?.headers.value('retry-after');
          int delay = retryAfter != null
              ? int.parse(retryAfter) * 1000
              : 10000 *
                  retryCount; // 10s nhân với retryCount nếu không có Retry-After

          print('Received status code 429. Retrying after $delay ms...');

          retryCount++;
          await Future.delayed(
              Duration(milliseconds: delay)); // Chờ trước khi thử lại
        } else {
          // Xử lý các lỗi khác
          print('Error fetching message: $e');
          throw Exception('Failed to fetch message');
        }
      }
    }

    throw Exception('Max retries reached. Failed to fetch message.');
  }
}
