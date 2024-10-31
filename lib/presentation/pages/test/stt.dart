import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecorder extends StatefulWidget {
  final Function(String) onTextRecognized;
  
  const SpeechRecorder({
    Key? key,
    required this.onTextRecognized,
  }) : super(key: key);

  @override
  _SpeechRecorderState createState() => _SpeechRecorderState();
}

class _SpeechRecorderState extends State<SpeechRecorder> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = "";

  Future<void> _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          print('Error: $errorNotification');
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
              widget.onTextRecognized(_spokenText);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleListening,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? Colors.red : Colors.blue,
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isListening ? 'Tap to stop' : 'Tap to speak',
          style: TextStyle(
            color: _isListening ? Colors.red : Colors.blue,
          ),
        ),
      ],
    );
  }
}