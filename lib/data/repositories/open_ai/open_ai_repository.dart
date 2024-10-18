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
          print('Received status code 429. Retrying after delay...');
          retryCount++;
          // Đặt khoảng thời gian chờ trước khi thử lại
          await Future.delayed(
              Duration(seconds: 10 * retryCount)); // Tăng dần thời gian chờ
        } else {
          // Xử lý lỗi khác
          print('Error fetching message: $e');
          throw Exception('Failed to fetch message');
        }
      }
    }

    throw Exception('Max retries reached. Failed to fetch message.');
  }
}
