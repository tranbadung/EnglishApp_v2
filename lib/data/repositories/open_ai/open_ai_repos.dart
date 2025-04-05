import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getSpeakingFeedback(String transcript, String part) async {
  const apiKey =
      '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';
  const apiUrl = 'https://api.openai.com/v1/chat/completions';

  if (apiKey.isEmpty) {
    throw Exception('API key is missing');
  }

  // Tạo prompt dựa trên phần speaking được đánh giá
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

  // Thêm hướng dẫn cụ thể cho từng phần
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

// Helper function để đánh giá toàn bộ bài thi speaking
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
Future<double> calculateOverallScore(Map<String, String> feedback) async {
  double totalBandScore = 0.0;
  int count = 0;

  // Regular expression để tìm Band Score trong feedback
  final RegExp scoreRegex = RegExp(r'Band Score:\s*(\d+\.?\d*)');

  // Duyệt qua feedback của từng phần
  for (String partFeedback in feedback.values) {
    final match = scoreRegex.firstMatch(partFeedback);
    if (match != null) {
      try {
        double score = double.parse(match.group(1)!);
        totalBandScore += score;
        count++;
      } catch (e) {
        print('Error parsing score: ${match.group(1)}');
      }
    }
  }

  // Nếu không tìm thấy điểm nào
  if (count == 0) {
    throw Exception('No valid band scores found in feedback');
  }

  // Làm tròn đến 0.5 gần nhất theo chuẩn IELTS
  double averageScore = totalBandScore / count;
  return (averageScore * 2).round() / 2;
}