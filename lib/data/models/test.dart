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
  'assets/images/active lifestyle app.jpeg',
  'assets/images/Art.jpeg',
  'assets/images/Business.jpeg',
  'assets/images/Comunity.jpeg',
  'assets/images/Dining.jpeg'
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
      question: 'What is the primary purpose of education?',
      answers: [
        'To gain knowledge',
        'To earn a degree',
        'To secure a job',
        'To impress others'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'Which of the following is a key benefit of reading regularly?',
      answers: [
        'Improving physical strength',
        'Developing cognitive skills',
        'Increasing appetite',
        'Enhancing athletic ability'
      ],
      correctAnswerIndex: 1,
    ),
    Quiz(
      question: 'Who is the author of the novel "Pride and Prejudice"?',
      answers: [
        'Jane Austen',
        'Mark Twain',
        'Charles Dickens',
        'George Orwell'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'What is a common reason people travel abroad?',
      answers: [
        'To relax and explore new places',
        'To reduce job opportunities',
        'To avoid learning new cultures',
        'To stay at home'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'What is one major benefit of learning a second language?',
      answers: [
        'Improving communication skills',
        'Becoming less intelligent',
        'Avoiding social interactions',
        'Making fewer friends'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'Which of the following is an effective way to reduce stress?',
      answers: [
        'Getting enough sleep',
        'Working longer hours',
        'Eating junk food',
        'Ignoring problems'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'Why is teamwork important in a professional setting?',
      answers: [
        'It increases individual workload',
        'It helps achieve common goals',
        'It limits personal freedom',
        'It reduces job satisfaction'
      ],
      correctAnswerIndex: 1,
    ),
    Quiz(
      question: 'What is a significant cause of climate change?',
      answers: [
        'Deforestation',
        'Increased literacy',
        'Improved technology',
        'Reduced energy consumption'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'Which of the following is a benefit of regular exercise?',
      answers: [
        'Improves cardiovascular health',
        'Decreases energy levels',
        'Increases risk of illness',
        'Promotes social isolation'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'What is the primary purpose of saving money?',
      answers: [
        'To prepare for future needs',
        'To increase stress levels',
        'To decrease financial stability',
        'To reduce career growth'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'Which factor is most important when choosing a career?',
      answers: [
        'Salary only',
        'Personal interests and skills',
        'Job location',
        'Appearance of the workplace'
      ],
      correctAnswerIndex: 1,
    ),
    Quiz(
      question: 'What is one advantage of volunteering?',
      answers: [
        'It can help develop new skills',
        'It reduces social interaction',
        'It is financially rewarding',
        'It limits career growth'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'Why is it important to maintain a balanced diet?',
      answers: [
        'To enhance mental and physical health',
        'To reduce sleep quality',
        'To decrease physical strength',
        'To limit energy levels'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'Which of the following is a primary reason for urbanization?',
      answers: [
        'Better job opportunities',
        'Lack of education',
        'Improved countryside facilities',
        'Reduced population growth'
      ],
      correctAnswerIndex: 0,
    ),
    Quiz(
      question: 'What is a significant challenge in global healthcare today?',
      answers: [
        'High literacy rates',
        'Increasing disease outbreaks',
        'Decreasing access to technology',
        'Rising personal incomes'
      ],
      correctAnswerIndex: 1,
    ),
  ];
}

List<FlashCard> getSampleFlashCards = [
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
