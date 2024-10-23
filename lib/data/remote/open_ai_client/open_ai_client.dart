import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:speak_up/data/models/open_ai/open_ai_message_response.dart';

part 'open_ai_client.g.dart';

@RestApi(baseUrl: 'https://api.openai.com/v1/chat/completions')
abstract class OpenAIClient {
  factory OpenAIClient(Dio dio, {String baseUrl}) = _OpenAIClient;

  @POST('')
  Future<OpenAIMessageResponse> getMessage(
    @Body() Map<String, dynamic> bot,
  );
}

 Dio dioSetup(String apiKey) {
  final dio = dioSetup(
      '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');
  final openAIClient = OpenAIClient(dio);

   dio.options.headers['Authorization'] =
      'Bearer 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';

   dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print("Sending request to ${options.uri}");
      return handler.next(options); // Tiếp tục gửi request
    },
    onError: (DioError error, handler) async {
      // Log error
      print("Error: ${error.response?.statusCode} - ${error.message}");
      if (error.response?.statusCode == 429) {
        // Xử lý lỗi 429 (quá giới hạn)
        var retryAfter = error.response?.headers.value('retry-after');
        int delay = retryAfter != null
            ? int.parse(retryAfter) * 1000
            : 10000;  
        print("Received status code 429. Retrying after $delay ms...");
        await Future.delayed(Duration(milliseconds: delay));
        return handler.resolve(await dio.request(error.requestOptions.path,
            options: Options(
                method: error.requestOptions.method)));  
      }
      return handler.next(error);  
    },
  ));

  return dio;
}
