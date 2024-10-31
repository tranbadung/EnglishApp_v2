import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService {
  static final TtsService _singleton = TtsService._internal();
  factory TtsService() => _singleton;
  TtsService._internal();

  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;
  
  // Configuration values
  double volume = 1.0;
  double pitch = 1.0;
  double speechRate = 0.5;
  String? language = "en-US";

  Future<void> initTts() async {
    flutterTts = FlutterTts();

    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(language!);

    flutterTts.setStartHandler(() {
      print("Playing");
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      print("Complete");
      ttsState = TtsState.stopped;
    });

    flutterTts.setErrorHandler((msg) {
      print("Error: $msg");
      ttsState = TtsState.stopped;
    });
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    var result = await flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
  }

  Future<void> pause() async {
    var result = await flutterTts.pause();
    if (result == 1) ttsState = TtsState.paused;
  }

  void dispose() {
    flutterTts.stop();
  }

  Future<void> setVolume(double value) async {
    volume = value;
    await flutterTts.setVolume(value);
  }

  Future<void> setPitch(double value) async {
    pitch = value;
    await flutterTts.setPitch(value);
  }

  Future<void> setRate(double value) async {
    speechRate = value;
    await flutterTts.setSpeechRate(value);
  }

  Future<void> setLanguage(String lang) async {
    language = lang;
    await flutterTts.setLanguage(lang);
  }
}

class TtsControls extends StatefulWidget {
  final String textToSpeak;
  final bool showSettings;

  const TtsControls({
    Key? key,
    required this.textToSpeak,
    this.showSettings = false,
  }) : super(key: key);

  @override
  _TtsControlsState createState() => _TtsControlsState();
}

class _TtsControlsState extends State<TtsControls> {
  final TtsService tts = TtsService();
  bool isPlaying = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    await tts.initTts();
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed: isInitialized
                  ? () async {
                      if (isPlaying) {
                        await tts.stop();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        await tts.speak(widget.textToSpeak);
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    }
                  : null,
            ),
            if (widget.showSettings) ...[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  showTtsSettings(context);
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  void showTtsSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TTS Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Volume'),
                trailing: Slider(
                  value: tts.volume,
                  min: 0,
                  max: 1,
                  onChanged: (value) async {
                    await tts.setVolume(value);
                    setState(() {});
                  },
                ),
              ),
              ListTile(
                title: Text('Pitch'),
                trailing: Slider(
                  value: tts.pitch,
                  min: 0.5,
                  max: 2,
                  onChanged: (value) async {
                    await tts.setPitch(value);
                    setState(() {});
                  },
                ),
              ),
              ListTile(
                title: Text('Speech Rate'),
                trailing: Slider(
                  value: tts.speechRate,
                  min: 0.1,
                  max: 1,
                  onChanged: (value) async {
                    await tts.setRate(value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tts.dispose();
    super.dispose();
  }
}