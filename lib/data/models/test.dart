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

List<FlashCard>getSampleFlashCards = [
  FlashCard(
    userID: "",
    flashcardID: 1,
    frontText: 'Abandon',
    backText: 'Bỏ rơi',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 2,
    frontText: 'Benefit',
    backText: 'Lợi ích',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 3,
    frontText: 'Crisis',
    backText: 'Khủng hoảng',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 4,
    frontText: 'Diverse',
    backText: 'Đa dạng',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 5,
    frontText: 'Enhance',
    backText: 'Tăng cường',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 6,
    frontText: 'Fluctuate',
    backText: 'Biến động',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 7,
    frontText: 'Generate',
    backText: 'Tạo ra',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 8,
    frontText: 'Impact',
    backText: 'Tác động',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 9,
    frontText: 'Justify',
    backText: 'Biện minh',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 10,
    frontText: 'Knowledgeable',
    backText: 'Có kiến thức',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 11,
    frontText: 'Monitor',
    backText: 'Giám sát',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 12,
    frontText: 'Negotiate',
    backText: 'Đàm phán',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 13,
    frontText: 'Outcome',
    backText: 'Kết quả',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 14,
    frontText: 'Persuade',
    backText: 'Thuyết phục',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 15,
    frontText: 'Sustainable',
    backText: 'Bền vững',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 16,
    frontText: 'Transform',
    backText: 'Chuyển đổi',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 17,
    frontText: 'Advocate',
    backText: 'Biện hộ',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 18,
    frontText: 'Contribute',
    backText: 'Đóng góp',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 19,
    frontText: 'Distribute',
    backText: 'Phân phối',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 20,
    frontText: 'Exhibit',
    backText: 'Triển lãm',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 21,
    frontText: 'Facilitate',
    backText: 'Tạo điều kiện',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 22,
    frontText: 'Incorporate',
    backText: 'Kết hợp',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 23,
    frontText: 'Mitigate',
    backText: 'Giảm thiểu',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 24,
    frontText: 'Optimize',
    backText: 'Tối ưu hóa',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 25,
    frontText: 'Proficient',
    backText: 'Thành thạo',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 26,
    frontText: 'Reinforce',
    backText: 'Củng cố',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 27,
    frontText: 'Significant',
    backText: 'Quan trọng',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 28,
    frontText: 'Theoretical',
    backText: 'Lý thuyết',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 29,
    frontText: 'Utilize',
    backText: 'Sử dụng',
    backTranslation: 'Vietnamese',
  ),
  FlashCard(
    userID: "",
    flashcardID: 30,
    frontText: 'Visionary',
    backText: 'Có tầm nhìn',
    backTranslation: 'Vietnamese',
  ),
];
