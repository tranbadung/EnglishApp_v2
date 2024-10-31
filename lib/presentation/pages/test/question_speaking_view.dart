import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speak_up/data/repositories/chat_gpt/chargpt_repository.dart';
import 'package:speak_up/data/repositories/open_ai/open_ai_repos.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../data/models/test.dart';

class IELTSSpeakingTestPage extends StatefulWidget {
  const IELTSSpeakingTestPage(
      {Key? key, required String skillName, required String level})
      : super(key: key);

  @override
  _IELTSSpeakingTestPageState createState() => _IELTSSpeakingTestPageState();
}

class _IELTSSpeakingTestPageState extends State<IELTSSpeakingTestPage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  List<String> _recognizedSentences = [];
  int _currentPartIndex = 0;
  String _lastRecognizedWords = '';
  Timer? _timer;
  int _remainingSeconds = 0;
  Map<String, String> _partTranscripts = {
    'part1': '',
    'part2': '',
    'part3': '',
  };
  void _startTimer(int durationInSeconds) {
    _remainingSeconds = durationInSeconds;
    _timer?.cancel();  
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopListening();  
        timer.cancel();
        _nextPart();  
      }
    });
  }

  Map<String, Duration> _partDurations = {
    'Part 1': Duration.zero,
    'Part 2': Duration.zero,
    'Part 3': Duration.zero,
  };

  DateTime? _partStartTime;

 

  @override
  void initState() {
    super.initState();
    _initSpeech();

     if (_currentPartIndex == 0) {
      _startTimer(180);  
    }
  }

  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _requestMicPermission();
    _partStartTime = DateTime.now();

     int timeLimit =
        _currentPartIndex == 0 ? 180 : (_currentPartIndex == 1 ? 120 : 300);

     _startTimer(timeLimit);

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(minutes: 20),
      pauseFor: Duration(seconds: 10),
      localeId: 'en_US',
    );
    setState(() {});  
  }

  void _stopListening() async {
    _timer?.cancel(); 

    await _speechToText.stop();
    if (_partStartTime != null) {
      final duration = DateTime.now().difference(_partStartTime!);
      _partDurations[parts[_currentPartIndex]["part"]!] = duration;
    }
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      if (result.recognizedWords != _lastRecognizedWords &&
          result.confidence > 0.8) {
        _recognizedSentences.add(result.recognizedWords);
        _lastRecognizedWords = result.recognizedWords;

         _partTranscripts['part${_currentPartIndex + 1}'] =
            _recognizedSentences.join('. ');
      }
    });
  }

  Future<void> _nextPart() async {
    _stopListening();

    if (_currentPartIndex < parts.length - 1) {
      setState(() {
        _currentPartIndex++;
        _recognizedSentences.clear();
        _lastRecognizedWords = '';
        _partStartTime = null;
      });

       _startListening();
    } else {
       try {
        final assessment = await getFullSpeakingAssessment(
          part1Transcript: _partTranscripts['part1'] ?? '',
          part2Transcript: _partTranscripts['part2'] ?? '',
          part3Transcript: _partTranscripts['part3'] ?? '',
        );

        final feedback = assessment['part3'] ?? 'No feedback available';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpeakingResultScreen(
              feedback: feedback,
              partDurations: _partDurations,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting feedback: $e')),
        );
      }
    }
  }

   String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Speaking Test'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _formatTime(_remainingSeconds),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],  
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${parts[_currentPartIndex]["part"]}: ${parts[_currentPartIndex]["question"]}',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _recognizedSentences.join('. ') + '.',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _speechToText.isNotListening
                    ? _startListening
                    : _stopListening,
                child: Text(
                  _speechToText.isNotListening
                      ? "Start Speaking"
                      : "Stop Speaking",
                ),
              ),
              ElevatedButton(
                onPressed: _nextPart,
                child: const Text("Next Part"),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: _speechToText.isNotListening ? 'Start' : 'Stop',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
