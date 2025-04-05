class Lesson {
  final int lessonID;
  final String name;
  final String translation;
  final String description;
  final String descriptionTranslation;
  final String imageURL;
  bool isLearned; // Thêm cờ để kiểm tra nếu bài học đã học

  Lesson({
    required this.lessonID,
    required this.name,
    required this.translation,
    required this.description,
    required this.descriptionTranslation,
    required this.imageURL,
    required this.isLearned,
  });

  factory Lesson.initial() => Lesson(
    lessonID: 0,
    name: '',
    translation: '',
    description: '',
    descriptionTranslation: '',
    imageURL: '',
    isLearned: false,
  );
}

List<Lesson> createSampleLessons() {
  return [
    Lesson(
      lessonID: 1,
      name: 'Common English Phrases, Sentence Patterns',
      translation: 'Cụm từ và mẫu câu Tiếng Anh thông dụng1',
      description:
      'You want to improve your English speaking but don’t know where to start? You know a lot of English words but have a hard time making sentences in English?You know why?The reason is you don’t learn common English phrases and sentence patterns, do you? These phrases and patterns are said as basic units for you to make much more correct sentences in English.Below are 100 common English phrases and sentence patterns that are much used in daily life. Each common English phrase includes real audios and scripts which help you learn sentence structures better, and make sentences in English much more easily.If you master just one common English phrase or sentence pattern, you can make hundreds of correct sentences. This is the easiest way to make sentences in English..',
      descriptionTranslation:
      'Bạn muốn cải thiện khả năng nói tiếng Anh nhưng không biết bắt đầu từ đâu? Bạn biết nhiều từ tiếng Anh nhưng gặp khó khăn trong việc xây dựng câu trong tiếng Anh?Bạn biết tại sao không?Lý do là do bạn không học những cụm từ và mẫu câu tiếng Anh thông dụng. Những cụm từ và mẫu câu này được coi là các đơn vị cơ bản giúp bạn tạo ra nhiều câu chính xác hơn trong tiếng Anh.Dưới đây là 100 cụm từ và mẫu câu tiếng Anh thông dụng trong cuộc sống hàng ngày. Mỗi cụm từ tiếng Anh thông thường đi kèm với âm thanh thật và bản dịch giúp bạn học cấu trúc câu tốt hơn và dễ dàng tạo ra câu tiếng Anh hơn.Nếu bạn nắm vững chỉ một cụm từ hoặc mẫu câu tiếng Anh thông dụng, bạn có thể tạo ra hàng trăm câu đúng. Điều này là cách dễ dàng nhất để xây dựng câu trong tiếng Anh..',
      imageURL: 'assets/images/lessons/phrasalverb.png',
      isLearned: true,
    ),
    Lesson(
      lessonID: 2,
      name: 'Common English Expressions and Daily Use Sentences',
      translation: 'Diễn đạt và câu sử dụng Tiếng Anh thông dụng',
      description:
      'Have you ever felt hopeless getting your message across in communication due to the lack of English expressions? Have you ever been misunderstood because of using wrong English phrases to express your ideas? Have you ever felt bored with using the same expression a thousand times in different contexts?I bet you say yes.Yeah. Here is the solution for all of your problems.If you want to improve your English speaking in a short time, it’s really important to learn common phrases, expressions, anddaily use sentences that native English speakers often use. If you master these everyday English phrases, you will be able to communicate flexibly in your daily life..',
      descriptionTranslation:
      'Bạn đã từng cảm thấy tuyệt vọng khi truyền đạt ý kiến trong giao tiếp do thiếu biểu đạt tiếng Anh? Bạn đã từng bị hiểu lầm vì sử dụng sai cụm từ tiếng Anh để diễn đạt ý tưởng của bạn? Bạn đã từng cảm thấy chán ngấy khi sử dụng cùng một biểu thức hàng nghìn lần trong các ngữ cảnh khác nhau?',
      imageURL: 'assets/images/lessons/pattern.png',
      isLearned: true,
    ),
    Lesson(
      isLearned: true,
      lessonID: 3,
      name: 'Common Phrasal Verbs List',
      translation: 'Cụm động từ Tiếng Anh thông dụng',
      description:
      '“I’ve been learning English for years. I’ve been trying many different ways to improve my speaking. However, it’s still hard for me to sound like a native speaker. What can I do?”Does this sound familiar toyou?Actually, to sound like a native English speaker requires a lot. But, phrasal verbs are probably the most important things you need to get good at in the first place.But why?In daily conversation, native English speakers use phrasal verbs A LOT.  They sound more friendly and are easy to understand. Just listen to native speakers talking, you’ll realize that most of the verbs used in the conversation are phrasal verbs. Therefore, learning phrasal verbs will open up a whole new world of possibilities for speaking English..',
      descriptionTranslation:
      '"Tôi đã học tiếng Anh suốt nhiều năm. Tôi đã thử nhiều cách khác nhau để cải thiện khả năng nói. Tuy nhiên, vẫn còn khó khăn khiến tôi không thể nói như người bản xứ. Tôi phải làm gì?"Có vẻ như câu hỏi này quen thuộc với bạn phải không?Thực tế là, để nói giống như người bản xứ tiếng Anh, bạn cần khá nhiều thứ. Nhưng, cụm động từ có lẽ là những thứ quan trọng nhất bạn cần nắm vững ở giai đoạn đầu.Nhưng tại sao?Trong cuộc hội thoại hàng ngày, người bản ngữ tiếng Anh sử dụng cụm động từ RẤT NHIỀU. Nó giúp giao tiếp có vẻ thân thiện hơn và dễ hiểu hơn. Chỉ cần lắng nghe người bản ngữ nói chuyện, bạn sẽ nhận ra rằng hầu hết các động từ được sử dụng trong cuộc trò chuyện là động từ ghép. Do đó, việc học động từ ghép sẽ mở ra một thế giới mới hoàn toàn của khả năng nói tiếng Anh.".',
      imageURL: 'assets/images/lessons/expression.png',
    ),
    Lesson(
      isLearned: true,
      lessonID: 4,
      name: 'Health Idioms',
      translation: 'Thành ngữ về Sức khỏe',
      description:
      'Explore idioms commonly used to discuss health and well-being.',
      descriptionTranslation:
      'Khám phá các thành ngữ thường dùng để nói về sức khỏe và sự lành mạnh.',
      imageURL: 'assets/images/lessons/tense.png',
    ),
    Lesson(
      isLearned: true,
      lessonID: 5,
      name: 'Idioms about Work',
      translation: 'Thành ngữ về Công việc',
      description: 'Learn idioms that are frequently used in the workplace.',
      descriptionTranslation:
      'Học các thành ngữ thường được sử dụng trong môi trường làm việc.',
      imageURL: 'assets/images/lessons/idiom.png',
    ),
    Lesson(
      isLearned: true,
      lessonID: 6,
      name: 'Idioms about Time',
      translation: 'Thành ngữ về Thời gian',
      description: 'Understand idioms that revolve around the concept of time.',
      descriptionTranslation:
      'Hiểu các thành ngữ xoay quanh khái niệm thời gian.',
      imageURL: 'assets/images/lessons/commonword.png',
    ),
    Lesson(
      isLearned: true,
      lessonID: 7,
      name: 'Idioms about Decisions',
      translation: 'Thành ngữ về Quyết định',
      description:
      'Learn idioms that are used when making decisions or describing choices.',
      descriptionTranslation:
      'Học các thành ngữ được sử dụng khi đưa ra quyết định hoặc mô tả lựa chọn.',
      imageURL: 'assets/images/lessons/commonword.png',
    ),
    Lesson(
      isLearned: true,
      lessonID: 8,
      name: 'Idioms about Friendship',
      translation: 'Thành ngữ về Tình bạn',
      description:
      'Explore idioms that describe relationships and friendships.',
      descriptionTranslation:
      'Khám phá các thành ngữ miêu tả các mối quan hệ và tình bạn.',
      imageURL: 'assets/images/lessons/commonword.png',
    ),
    Lesson(
      isLearned: true,
      lessonID: 9,
      name: 'Idioms about Dreams',
      translation: 'Thành ngữ về Ước mơ',
      description:
      'Understand idioms commonly used to talk about dreams and ambitions.',
      descriptionTranslation:
      'Hiểu các thành ngữ thường dùng để nói về ước mơ và hoài bão.',
      imageURL: 'assets/images/lessons/commonword.png',
    ),
    Lesson(
      isLearned: true,
      lessonID: 10,
      name: 'Travel Idioms',
      translation: 'Thành ngữ về Du lịch',
      description:
      'Learn idioms that are frequently used when talking about travel.',
      descriptionTranslation:
      'Học các thành ngữ thường được sử dụng khi nói về du lịch.',
      imageURL: 'assets/images/lessons/commonword.png',
    ),
  ];
}
