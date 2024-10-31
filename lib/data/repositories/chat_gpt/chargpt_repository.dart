import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class SpeakingResultScreen extends StatelessWidget {
  final String feedback;
  final Map<String, Duration> partDurations;

  const SpeakingResultScreen({
    Key? key,
    required this.feedback,
    required this.partDurations,
  }) : super(key: key);

  // Parse GPT response to extract score and feedback
  Map<String, dynamic> _parseGPTFeedback(String feedback) {
    // Sử dụng try-catch để xử lý lỗi khi định dạng không đúng
    try {
      RegExp scoreRegex = RegExp(r'(?:Band Score:|Score:)\s*(\d+\.?\d*)');
      var scoreMatch = scoreRegex.firstMatch(feedback);
      double score =
          scoreMatch != null ? double.parse(scoreMatch.group(1)!) : 0.0;

      return {
        'score': score,
        'feedback': feedback,
        'criteriaScores': _extractCriteriaScores(feedback),
      };
    } catch (e) {
      print("Error parsing feedback: $e");
      return {
        'score': 0.0,
        'feedback': "Error in feedback format",
        'criteriaScores': {},
      };
    }
  }

  // Extract individual criteria scores for Speaking
  Map<String, double> _extractCriteriaScores(String feedback) {
    Map<String, double> scores = {
      'Fluency and Coherence': 0.0,
      'Lexical Resource': 0.0,
      'Grammatical Range': 0.0,
      'Pronunciation': 0.0,
    };

    for (var criterion in scores.keys) {
      RegExp regex = RegExp('$criterion:?\\s*(\\d+(?:\\.\\d+)?)');
      var match = regex.firstMatch(feedback);
      if (match != null) {
        scores[criterion] = double.parse(match.group(1) ?? "0.0");
      }
    }

    return scores;
  }

  Widget _buildScoreCard(String title, double score) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getScoreColor(score),
              ),
              child: Center(
                child: Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 7.0) return Colors.green;
    if (score >= 6.0) return Colors.blue;
    if (score >= 5.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCriteriaSection(String title, Map<String, double> scores) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            ...scores.entries
                .map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: entry.value / 9,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(entry.value),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            entry.value.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(entry.value),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPartDurations() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speaking Parts Duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            ...partDurations.entries.map((entry) {
              final duration = entry.value;
              final minutes = duration.inMinutes;
              final seconds = duration.inSeconds % 60;
              final durationText =
                  '$minutes:${seconds.toString().padLeft(2, '0')}';

              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Part ${entry.key}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      durationText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(String title, String feedback) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              feedback,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _parseGPTFeedback(feedback);
    final score = results['score'];

    return Scaffold(
      appBar: AppBar(
        title: Text('IELTS Speaking Results'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Column(
                children: [
                  Text(
                    'Speaking Band Score',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildScoreCard('Overall', score),
                ],
              ),
            ),
            _buildPartDurations(),
            _buildCriteriaSection(
              'Speaking Criteria Scores',
              results['criteriaScores'],
            ),
            _buildFeedbackSection('Chargpt Feedback', results['feedback']),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName('/main_menu'),
                      );
                    },
                    icon: Icon(Icons.home),
                    label: Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
