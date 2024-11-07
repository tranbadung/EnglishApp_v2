class CommonWord {
  final int id;
  final String word;
  final String translation;
  final String partOfSpeech;
  final String level;
  final int type;

  CommonWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.partOfSpeech,
    required this.level,
    required this.type,
  });

  // Phương thức để tạo instance từ JSON
  factory CommonWord.fromJson(Map<String, dynamic> json) {
    return CommonWord(
      id: json['id'],
      word: json['word'],
      translation: json['translation'],
      partOfSpeech: json['partOfSpeech'],
      level: json['level'],
      type: json['type'],
    );
  }

  // Phương thức để chuyển đổi instance thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'partOfSpeech': partOfSpeech,
      'level': level,
      'type': type,
    };
  }
}

List<CommonWord> commonWordList = [
  CommonWord(
      id: 1,
      word: "a",
      translation: "một",
      partOfSpeech: "indefinite article",
      level: "A1",
      type: 1),
  CommonWord(
      id: 2,
      word: "abandon",
      translation: "bỏ rơi",
      partOfSpeech: "v.",
      level: "B2",
      type: 1),
  CommonWord(
      id: 3,
      word: "ability",
      translation: "khả năng",
      partOfSpeech: "n.",
      level: "A2",
      type: 1),
  CommonWord(
      id: 4,
      word: "able",
      translation: "có thể",
      partOfSpeech: "adj.",
      level: "A2",
      type: 1),
  CommonWord(
      id: 5,
      word: "about",
      translation: "về",
      partOfSpeech: "prep., adv.",
      level: "A1",
      type: 1),
  CommonWord(
      id: 6,
      word: "above",
      translation: "bên trên",
      partOfSpeech: "prep., adv.",
      level: "A1",
      type: 1),
  CommonWord(
      id: 7,
      word: "abroad",
      translation: "ở nước ngoài",
      partOfSpeech: "adv.",
      level: "A2",
      type: 1),
  CommonWord(
      id: 8,
      word: "absolute",
      translation: "tuyệt đối",
      partOfSpeech: "adj.",
      level: "B2",
      type: 1),
  CommonWord(
      id: 9,
      word: "absolutely",
      translation: "tuyệt đối",
      partOfSpeech: "adv.",
      level: "B1",
      type: 1),
  CommonWord(
      id: 10,
      word: "academic",
      translation: "học thuật",
      partOfSpeech: "adj., n.",
      level: "B2",
      type: 1),
];
