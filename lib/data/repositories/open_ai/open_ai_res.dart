import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getSpeakingFeedback(String transcript, String part) async {
  const apiKey =
      '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';
  const apiUrl = 'https://api.openai.com/v1/chat/completions';

  if (apiKey.isEmpty) {
    throw Exception('API key is missing');
  }

  String systemPrompt =
      '''You are an IELTS speaking examiner. Evaluate the following Part $part speaking response and provide:
1. Overall Band Score: [0-9]
2. Individual scores for:
   - Fluency and Coherence: [0-9]
   - Pronunciation: [0-9]
   - Lexical Resource: [0-9]
   - Grammatical Range and Accuracy: [0-9]
3. Detailed feedback including:
   - Natural flow of speech and use of cohesive devices
   - Pronunciation clarity, intonation, and stress patterns
   - Vocabulary range and appropriateness
   - Grammar accuracy and complexity
   - Specific examples from the speech
   - Strengths and areas for improvement

Format the response as:
Band Score: [score]
Fluency: [score]
Pronunciation: [score]
Lexical Resource: [score]
Grammatical Range: [score]

Detailed Feedback:
[Comprehensive analysis of speaking performance]

Strengths:
- [Key strength 1]
- [Key strength 2]
- [Key strength 3]

Areas for Improvement:
- [Area 1]
- [Area 2]
- [Area 3]

Examples from Speech:
[2-3 specific examples with analysis]

Recommendations:
[Specific advice for improvement]''';

  if (part == '1') {
    systemPrompt += '''\nFor Part 1:
- Evaluate ability to answer direct questions about familiar topics
- Check appropriate use of present and past tenses
- Assess basic communication skills''';
  } else if (part == '2') {
    systemPrompt += '''\nFor Part 2:
- Evaluate ability to speak at length
- Check organization and coherence of the long turn
- Assess use of appropriate tenses and time markers
- Consider the completeness of the response to all parts of the cue card''';
  } else if (part == '3') {
    systemPrompt += '''\nFor Part 3:
- Evaluate ability to discuss abstract ideas
- Check use of complex language and sophisticated vocabulary
- Assess ability to develop arguments and express opinions
- Consider depth of discussion and analysis''';
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
          'content': systemPrompt,
        },
        {
          'role': 'user',
          'content': '''Here is the speaking transcript for Part $part:
$transcript

Please provide a detailed assessment following the format specified above.''',
        }
      ],
      'max_tokens': 1500,
      'temperature': 0.7,
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

Future<Map<String, String>> getFullSpeakingAssessment({
  required String part1Transcript,
  required String part2Transcript,
  required String part3Transcript,
}) async {
  try {
    final part1Feedback = await getSpeakingFeedback(part1Transcript, '1');
    final part2Feedback = await getSpeakingFeedback(part2Transcript, '2');
    final part3Feedback = await getSpeakingFeedback(part3Transcript, '3');

    return {
      'part1': part1Feedback,
      'part2': part2Feedback,
      'part3': part3Feedback,
    };
  } catch (e) {
    throw Exception('Error getting full speaking assessment: $e');
  }
}

// Hàm mới để tính toán điểm trung bình tổng thể
Future<double> calculateOverallScore(Map<String, String> feedback) async {
  double totalBandScore = 0.0;
  int count = 0;

  for (String partFeedback in feedback.values) {
    final bandScoreMatch =
        RegExp(r'Band Score: (\d(\.\d)?)').firstMatch(partFeedback);
    if (bandScoreMatch != null) {
      totalBandScore += double.parse(bandScoreMatch.group(1)!);
      count++;
    }
  }

  if (count == 0) {
    throw Exception('No valid band scores found in feedback');
  }

  return totalBandScore / count;
}
