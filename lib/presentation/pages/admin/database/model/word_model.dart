class Word {
  final int? wordID;
  final String word;
  final String pronunciation;
  final String phoneticComponents;
  final int phoneticID;
  final String translation;

  Word({
    this.wordID,
    required this.word,
    required this.pronunciation,
    required this.phoneticComponents,
    required this.phoneticID,
    required this.translation,
  });

  Map<String, dynamic> toMap() {
    return {
      'WordID': wordID,
      'Word': word,
      'Pronunciation': pronunciation,
      'PhoneticComponents': phoneticComponents,
      'PhoneticID': phoneticID,
      'Translation': translation,
    };
  }

  static Word fromMap(Map<String, dynamic> map) {
    return Word(
      wordID: map['WordID'],
      word: map['Word'] ?? '',
      pronunciation: map['Pronunciation'] ?? '',
      phoneticComponents: map['PhoneticComponents'] ?? '',
      phoneticID: map['PhoneticID'] ?? 0,
      translation: map['Translation'] ?? '',
    );
  }
}
