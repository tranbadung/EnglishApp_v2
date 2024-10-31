import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/data/repositories/chat_gpt/chat_gpt_repository.dart';

import '../../../data/models/test.dart';
import '../../../data/repositories/open_ai/open_ai_test.dart';

class WritingTestPage extends StatefulWidget {
  final String level;

  const WritingTestPage({
    required this.level,
    Key? key,
    required String skillName,
  }) : super(key: key);

  @override
  _WritingTestPageState createState() => _WritingTestPageState();
}

class _WritingTestPageState extends State<WritingTestPage> {
  final TextEditingController _essayController1 = TextEditingController();
  final TextEditingController _essayController2 = TextEditingController();
  Duration _timeRemaining = Duration(minutes: 60);
  bool isTestCompleted = false;
  Timer? _timer;
  int _wordCount1 = 0;
  int _wordCount2 = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadSavedProgress();
    _essayController1.addListener(() => _updateWordCount(1));
    _essayController2.addListener(() => _updateWordCount(2));
  }

  void _updateWordCount(int taskNumber) {
    setState(() {
      if (taskNumber == 1) {
        _wordCount1 = _countWords(_essayController1.text);
      } else {
        _wordCount2 = _countWords(_essayController2.text);
      }
    });
  }

  int _countWords(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining.inSeconds > 0) {
          _timeRemaining = _timeRemaining - Duration(seconds: 1);
        } else {
          _timer?.cancel();
          if (!isTestCompleted) {
            _submitTest();
          }
        }
      });
    });
  }

  Future<void> _loadSavedProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEssay1 = prefs.getString('saved_essay_1');
    String? savedEssay2 = prefs.getString('saved_essay_2');

    setState(() {
      if (savedEssay1 != null) _essayController1.text = savedEssay1;
      if (savedEssay2 != null) _essayController2.text = savedEssay2;
    });
  }

  Future<void> _saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_essay_1', _essayController1.text);
    await prefs.setString('saved_essay_2', _essayController2.text);
  }

  void _submitTest() async {
    setState(() {
      isTestCompleted = true;
    });
    await _saveProgress();

     String feedback1 =
        await getEssayFeedback(_essayController1.text, widget.level);
    String feedback2 =
        await getEssayFeedback(_essayController2.text, widget.level);

 
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WritingResultScreen(
            feedback1: feedback1,
            feedback2: feedback2,
            wordCount1: _wordCount1,
            wordCount2: _wordCount2,
          ),
        ));
  }

  Widget _buildTimerDisplay() {
    Color timerColor = _timeRemaining.inMinutes < 10 ? Colors.red : Colors.blue;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: timerColor),
          SizedBox(width: 8),
          Text(
            '${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCounter(int taskNumber) {
    int wordCount = taskNumber == 1 ? _wordCount1 : _wordCount2;
    int minWords = taskNumber == 1 ? 150 : 250;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: wordCount >= minWords ? Colors.green[100] : Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_size,
            color: wordCount >= minWords ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 8),
          Text(
            'Words: $wordCount/$minWords',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: wordCount >= minWords ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection(int taskNumber) {
    Map<String, dynamic> task = writingTasks[taskNumber - 1];
    TextEditingController controller =
        taskNumber == 1 ? _essayController1 : _essayController2;

    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Writing Task $taskNumber',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildWordCounter(taskNumber),
              ],
            ),
          ),

           if (task['imageAsset'] != '')
            Image.asset(
              task['imageAsset'],
              fit: BoxFit.contain,
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              task['prompt'],
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Write your response here...',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('IELTS Writing Test'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProgress,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: _buildTimerDisplay(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTaskSection(1),
                  _buildTaskSection(2),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitTest,
        label: Text('Submit Test'),
        icon: Icon(Icons.check),
      ),
    );
  }

  Widget _buildResultScreen(String feedback1, String feedback2) {
    bool task1Passed = _wordCount1 >= 150;
    bool task2Passed = _wordCount2 >= 250;
    bool overallPassed = task1Passed && task2Passed;

    return Scaffold(
      appBar: AppBar(title: Text('Test Results')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Completed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      overallPassed
                          ? 'Congratulations! You passed both tasks.'
                          : 'You didn\'t meet the word requirement for one or both tasks.',
                      style: TextStyle(
                        fontSize: 16,
                        color: overallPassed ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

             ...[1, 2].map((taskNum) {
              int wordCount = taskNum == 1 ? _wordCount1 : _wordCount2;
              int minWords = taskNum == 1 ? 150 : 250;
              bool passed = wordCount >= minWords;
              String feedback = taskNum == 1 ? feedback1 : feedback2;

              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Writing Task $taskNum',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Words: $wordCount/$minWords',
                        style: TextStyle(
                          fontSize: 16,
                          color: passed ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        passed
                            ? 'You met the word count requirement!'
                            : 'Word count requirement not met.',
                        style: TextStyle(
                          fontSize: 16,
                          color: passed ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Feedback:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        feedback,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

             SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                   },
                  child: Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                        context, ModalRoute.withName('/main_menu'));
                  },
                  child: Text('Back to Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isTestCompleted ? _buildResultScreen('', '') : _buildTestScreen();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _essayController1.dispose();
    _essayController2.dispose();
    super.dispose();
  }
}
