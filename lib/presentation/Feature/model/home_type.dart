import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screen/feature/chatbot_feature.dart';

import '../screen/feature/translator_feature.dart';


enum HomeType { aiChatBot, aiTranslator }

extension MyHomeType on HomeType {
  // Title
  String get title => switch (this) {
    HomeType.aiChatBot => 'AI ChatBot',

    HomeType.aiTranslator => 'Language Translator',
  // Title for pronunciation
  };

  // Lottie animation file
  String get lottie => switch (this) {
    HomeType.aiChatBot => 'ai_hand_waving.json',

    HomeType.aiTranslator => 'ai_ask_me.json',
  // Animation for pronunciation
  };

  // For alignment
  bool get leftAlign => switch (this) {
    HomeType.aiChatBot => true,

    HomeType.aiTranslator => true,
   // Example alignment
  };

  // For padding
  EdgeInsets get padding => switch (this) {
    HomeType.aiChatBot => EdgeInsets.zero,

    HomeType.aiTranslator => EdgeInsets.zero,
    // Example padding
  };

  // For navigation
  VoidCallback get onTap => switch (this) {
    HomeType.aiChatBot => () => Get.to(() => const ChatBotFeature()),

    HomeType.aiTranslator => () => Get.to(() => const TranslatorFeature()),
            // Navigation for pronunciation
  };
}
