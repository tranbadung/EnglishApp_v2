import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../apis/apis.dart';
import '../helper/my_dialog.dart';
import '../model/message.dart';

class ChatController extends GetxController {
  final textC = TextEditingController();
  final scrollC = ScrollController();
  final list = <Message>[Message(msg: 'Hello, How can I help you?', msgType: MessageType.bot)].obs;

  final stt.SpeechToText speech = stt.SpeechToText();
  final isListening = false.obs;
  final FlutterTts flutterTts = FlutterTts();

  // Thêm biến để theo dõi trạng thái AI đang nói
  final isSpeaking = false.obs;

  ChatController() {
    _speak('Hello, How can I help you?'); // Tự động phát âm tin nhắn chào
  }

  Future<void> askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      // User message
      list.add(Message(msg: textC.text, msgType: MessageType.user));
      list.add(Message(msg: '', msgType: MessageType.bot));
      _scrollDown();

      final res = await APIs.getAnswer(textC.text);

      // AI bot response
      list.removeLast();
      list.add(Message(msg: res, msgType: MessageType.bot));
      _scrollDown();

      textC.text = '';

      await _speak(res);
    } else {
      MyDialog.info('Ask Something!');
    }
  }

  Future<void> _speak(String text) async {
    isSpeaking.value = true; // Đặt trạng thái là đang nói
    await flutterTts.setLanguage('en-US'); // Đặt ngôn ngữ tiếng Anh
    await flutterTts.setPitch(1.0); // Điều chỉnh tone giọng
    await flutterTts.speak(text); // Phát âm thanh


    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });
  }

  void _scrollDown() {
    scrollC.animateTo(scrollC.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  Future<void> startListening() async {
    if (await speech.initialize()) {
      isListening.value = true;


      speech.listen(onResult: (result) {
        textC.text = result.recognizedWords;
      });


    } else {
      MyDialog.info('Speech recognition not available.');
    }
  }

  void stopListening() {
    speech.stop();
    isListening.value = false;


  }
}