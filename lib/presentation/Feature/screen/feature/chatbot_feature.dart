import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/chat_controller.dart';
import '../../helper/global.dart';
import '../../widget/message_card.dart';
import '../../widget/AnimatedModel.dart';  // Import widget AnimatedModel

class ChatBotFeature extends StatefulWidget {
  const ChatBotFeature({super.key});

  @override
  State<ChatBotFeature> createState() => _ChatBotFeatureState();
}

class _ChatBotFeatureState extends State<ChatBotFeature> {
  final _c = ChatController();

  @override
  Widget build(BuildContext context) {
    initMQ(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI Assistant'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          // Text input field
          Expanded(
            child: TextFormField(
              controller: _c.textC,
              textAlign: TextAlign.center,
              onTapOutside: (e) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  filled: true,
                  isDense: true,
                  hintText: 'Ask me anything you want...',
                  hintStyle: const TextStyle(fontSize: 14),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)))),
            ),
          ),
          const SizedBox(width: 8),

          // Microphone button
          Obx(() => CircleAvatar(
            radius: 24,
            backgroundColor: _c.isListening.value
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
            child: IconButton(
              onPressed: _c.isListening.value
                  ? _c.stopListening
                  : _c.startListening,
              icon: Icon(
                _c.isListening.value
                    ? Icons.mic_off
                    : Icons.mic_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          )),
          const SizedBox(width: 8),

          // Send button
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              onPressed: _c.askQuestion,
              icon: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ]),
      ),
      body: Column(
        children: [
          // Mô hình nhân vật
          Obx(() {
            return AnimatedModel(isSpeaking: _c.isSpeaking.value); // Chuyển trạng thái
          }),  // Thêm mô hình nhân vật vào
          Expanded(
            child: Obx(
                  () => ListView(
                physics: const BouncingScrollPhysics(),
                controller: _c.scrollC,
                padding: EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .1),
                children: _c.list.map((e) => MessageCard(message: e)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}