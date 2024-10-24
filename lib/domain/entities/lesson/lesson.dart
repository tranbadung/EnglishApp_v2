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
