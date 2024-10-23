import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/presentation/pages/lesson/lesson_view.dart';
import 'package:speak_up/presentation/pages/lesson/lessonview.dart';

class TestQuestionlisteningPage extends StatefulWidget {
  final String skillName;
  final String level;

  const TestQuestionlisteningPage(
      {required this.skillName, required this.level, Key? key})
      : super(key: key);

  @override
  _TestQuestionPageState createState() => _TestQuestionPageState();
}

class _TestQuestionPageState extends State<TestQuestionlisteningPage> {
  final _audioPlayer = AudioPlayer();
  List<TextEditingController> _controllers = [];

  final List<Map<String, dynamic>> testQuestions = [
    {'question': 'Address of agency: 497 Eastside, Docklands', 'blank': false},
    {
      'question': 'Name of agent: Becky ',
      'blank': true,
      'answer': '',
      'correctAnswer': 'Smith',
      'hint': 'Write ONE WORD'
    },
    {
      'question': 'Best to call her in the ',
      'blank': true,
      'answer': '',
      'correctAnswer': 'morning',
      'hint': 'Write ONE WORD OR A NUMBER'
    },
    {
      'question': 'Clerical and admin roles, mainly in the finance industry',
      'blank': false
    },
    {
      'question': 'Minimum typing speed required: ',
      'blank': true,
      'answer': '',
      'correctAnswer': '50',
      'hint': 'Write A NUMBER'
    },
    {
      'question': 'Experience needed: ',
      'blank': true,
      'answer': '',
      'correctAnswer': '2 years',
      'hint': 'Write A NUMBER AND A WORD'
    },
    {
      'question': 'Salary range: Starting from £',
      'blank': true,
      'answer': '',
      'correctAnswer': '25000',
      'hint': 'Write A NUMBER'
    },
    {
      'question': 'Type of contract: ',
      'blank': true,
      'answer': '',
      'correctAnswer': 'permanent',
      'hint': 'Write ONE WORD'
    },
  ];

  int _correctAnswers = 0;
  Duration _timeRemaining = Duration(minutes: 90);
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool isPlaying = false;
  bool isTestCompleted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initAudio();
    _startTimer();
    _controllers = List.generate(
      testQuestions.where((q) => q['blank']).length,
      (index) => TextEditingController(),
    );
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

  void _submitTest() {
    int correctCount = 0;
    int controllerIndex = 0;

    for (int i = 0; i < testQuestions.length; i++) {
      var question = testQuestions[i];
      if (question['blank']) {
        String userAnswer =
            _controllers[controllerIndex].text.toLowerCase().trim();
        String correctAnswer = question['correctAnswer'].toLowerCase().trim();
        if (userAnswer == correctAnswer) {
          correctCount++;
        }
        controllerIndex++;
      }
    }

    setState(() {
      _correctAnswers = correctCount;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _buildResultScreen()),
    );
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer
          .setAsset('assets/audios/test/ielts15_test1_audio1.mp3');
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentPosition = position;
        });
      });
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _audioDuration = duration ?? Duration.zero;
        });
      });
    } catch (e) {
      print('Error loading audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Không thể tải âm thanh. Vui lòng thử lại sau.')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> answers = testQuestions
        .where((q) => q['blank'])
        .map((q) => q['answer'] as String)
        .toList();
    await prefs.setStringList('saved_answers', answers);
  }

  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedAnswers = prefs.getStringList('saved_answers');
    if (savedAnswers != null) {
      for (int i = 0; i < testQuestions.length; i++) {
        if (testQuestions[i]['blank']) {
          testQuestions[i]['answer'] = savedAnswers[i];
        }
      }
    }
  }

  Widget _buildAudioPlayerControls() {
    return Column(
      children: [
        Slider(
          value: _currentPosition.inSeconds.toDouble(),
          max: _audioDuration.inSeconds.toDouble(),
          onChanged: (value) {
            _audioPlayer.seek(Duration(seconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_currentPosition)),
              Text(_formatDuration(_audioDuration)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  if (isPlaying) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                  isPlaying = !isPlaying;
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimerDisplay(),
            _buildQuestionCounter(),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            _timeRemaining.inMinutes < 5 ? Colors.red[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: _timeRemaining.inMinutes < 5 ? Colors.red : Colors.blue,
          ),
          SizedBox(width: 8),
          Text(
            'Time remaining: ${_formatDuration(_timeRemaining)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _timeRemaining.inMinutes < 5 ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCounter() {
    int totalQuestions = testQuestions.where((q) => q['blank']).length;
    int answeredQuestions = testQuestions
        .where((q) => q['blank'] && q['answer'].toString().isNotEmpty)
        .length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.question_answer, color: Colors.green),
          SizedBox(width: 8),
          Text(
            'Questions: $answeredQuestions/$totalQuestions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTestScreen() {
    int blankIndex =
        0; // Đặt biến blankIndex ở cấp độ local để theo dõi index của các câu hỏi có chỗ trống

    return Scaffold(
      appBar: AppBar(title: Text('Test Screen')),
      body: Column(
        children: [
          _buildAudioPlayerControls(),
          Expanded(
            child: ListView.builder(
              itemCount: testQuestions.length,
              itemBuilder: (context, index) {
                var questionData = testQuestions[index];
                if (questionData['blank']) {
                  var widget = buildQuestionCard(questionData, blankIndex);
                  blankIndex++; // Tăng blankIndex sau khi hiển thị một câu hỏi có chỗ trống
                  return widget;
                }
                return buildQuestionCard(questionData, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitTest,
        child: Icon(Icons.check),
      ),
    );
  }

  Widget buildQuestionCard(Map<String, dynamic> questionData, int blankIndex) {
    if (questionData['blank']) {
      return Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                questionData['question'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _controllers[blankIndex],
                decoration: InputDecoration(
                  hintText: questionData['hint'],
                  hintStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(16),
                    color: Colors.grey[600],
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    questionData['answer'] = value;
                  });
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                questionData['question'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildResultScreen() {
     int totalQuestions = testQuestions.where((q) => q['blank']).length;
    double percentage = (_correctAnswers / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(title: Text('Test Results')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      'Your Score:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$_correctAnswers/$totalQuestions',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: percentage >= 75
                            ? Colors.green
                            : percentage >= 50
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            // Hiển thị chi tiết đáp án
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Answer Details:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...testQuestions.where((q) => q['blank']).map((q) {
                      String userAnswer = (q['answer'] ?? '').toString();
                      String correctAnswer = q['correctAnswer'].toString();
                      bool isCorrect = userAnswer.toLowerCase().trim() ==
                          correctAnswer.toLowerCase().trim();

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q['question'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text('Your answer: $userAnswer'),
                                SizedBox(width: 8),
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                              ],
                            ),
                            Text('Correct answer: $correctAnswer',
                                style: TextStyle(color: Colors.green)),
                            Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LessonView1()));
              },
              child: Text('Back to Home'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildTestScreen();
  }
}
