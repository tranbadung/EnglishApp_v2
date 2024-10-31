import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getEssayFeedback(String essay, String level) async {
  const apiKey =
      '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';
  const apiUrl = 'https://api.openai.com/v1/chat/completions';

  if (apiKey.isEmpty) {
    throw Exception('API key is missing');
  }

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              '''You are an IELTS writing examiner. Evaluate the following essay and provide:
1. Overall Band Score: [0-9]
2. Individual scores for:
   - Task Achievement: [0-9]
   - Coherence and Cohesion: [0-9]
   - Lexical Resource: [0-9]
   - Grammatical Range: [0-9]
3. Detailed feedback including:
   - Strengths
   - Areas for improvement
   - Specific examples from the text
Format the response as:
Band Score: [score]
Task Achievement: [score]
Coherence and Cohesion: [score]
Lexical Resource: [score]
Grammatical Range: [score]
Feedback:
[detailed feedback]''',
        },
        {
          'role': 'user',
          'content': essay,
        }
      ],
      'max_tokens': 1000,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['choices']?[0]?['message']?['content'];
    if (content != null) {
      return content;
    } else {
      throw Exception('Unexpected response format');
    }
  } else {
    print('Error response: ${response.body}');
    throw Exception('Failed to get feedback: ${response.reasonPhrase}');
  }
}
