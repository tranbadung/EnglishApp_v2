import 'package:speak_up/domain/entities/quiz/quiz.dart';

import '../../domain/entities/flash_card/flash_card.dart';

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

final Map<int, String> correctAnswers = {
  0: 'B',
  1: 'C',
  2: 'F',
  3: 'D',
  4: 'E',
  5: 'A',
};

final Map<int, String> correctSummaryAnswers = {
  0: 'safety',
  1: 'traffic',
  2: 'road',
  3: 'mobile',
  4: 'dangerous',
  5: 'communities',
  6: 'efficient',
};

final List<Map<String, String>> parts = [
  {
    "part": "Part 1",
    "question": "Tell me about your hometown.",
  },
  {
    "part": "Part 2",
    "question": "Describe an event you have recently attended.",
  },
  {
    "part": "Part 3",
    "question": "Discuss the advantages and disadvantages of online shopping.",
  },
];
final List<Map<String, dynamic>> writingTasks = [
  {
    'taskNumber': '1',
    'prompt':
        'The graph below shows the number of tourists visiting a particular Caribbean island between 2010 and 2017. Summarize the information by selecting and reporting the main features, and make comparisons where relevant.',
    'imageAsset': 'assets/audios/test/image.png',
    'minWords': 150,
  },
  {
    'taskNumber': '2',
    'prompt':
        'In the future, nobody will buy printed books or newspapers because they will be able to read everything they want online without paying. To what extent do you agree or disagree with this statement?',
    'imageAsset': '',
    'minWords': 250,
  },
];
final List<String> conversationImages = [
  'assets/images/fitness.jpg',
  'assets/images/cooking.jpg',
  'assets/images/account.jpg',
];
const String _imagesPath = 'assets/images';

final List<String> imagePaths = [
  '$_imagesPath/banner.png',
  '$_imagesPath/banner1.png',
  '$_imagesPath/banner2.png',
  '$_imagesPath/banner3.png',
  '$_imagesPath/banner4.png',
];
List<Quiz> createSampleQuiz() {
  return [
    Quiz(
      question: 'What is the capital of France?',
      answers: ['Paris', 'London', 'Berlin', 'Madrid'],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'What is 2 + 2?',
      answers: ['3', '4', '5', '6'],
      correctAnswerIndex: 1,
    ),
    Quiz(
      question: 'Who wrote "Hamlet"?',
      answers: ['Shakespeare', 'Dickens', 'Hemingway', 'Tolkien'],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'What is the largest planet in our Solar System?',
      answers: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
      correctAnswerIndex: 2,
    ),
  ];
}
  List<FlashCard> getSampleFlashCards() {
    return [
      FlashCard(
        userID: "",
        flashcardID: 1,
        frontText: 'Hello',
        backText: 'Xin chào',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 2,
        frontText: 'Goodbye',
        backText: 'Tạm biệt',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 3,
        frontText: 'Thank you',
        backText: 'Cảm ơn',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 4,
        frontText: 'Yes',
        backText: 'Vâng',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 5,
        frontText: 'No',
        backText: 'Không',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 6,
        frontText: 'Perseverance',
        backText: 'Kiên trì',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 7,
        frontText: 'Euphoria',
        backText: 'Hạnh phúc tột độ',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 8,
        frontText: 'Serendipity',
        backText: 'Điều may mắn tình cờ',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 9,
        frontText: 'Ephemeral',
        backText: 'Nhất thời',
        backTranslation: 'Vietnamese',
      ),
      FlashCard(
        userID: "",
        flashcardID: 10,
        frontText: 'Ineffable',
        backText: 'Không thể diễn tả',
        backTranslation: 'Vietnamese',
      ),
    ];
  }