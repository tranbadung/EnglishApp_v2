class Word {
  int? wordID;
  String word;
  String pronunciation;
  Map<String, int> phoneticComponents;
  int phoneticID;
  String translation;

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
      'PhoneticComponents': phoneticComponents.toString(),
      'PhoneticID': phoneticID,
      'Translation': translation,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    Map<String, int> phoneticComponents = {};
    try {
      String phoneticStr = map['PhoneticComponents'] as String? ?? '{}';
      if (phoneticStr.startsWith('{') && phoneticStr.endsWith('}')) {
        phoneticStr = phoneticStr.substring(1, phoneticStr.length - 1);
        List<String> pairs = phoneticStr.split(',');
        for (String pair in pairs) {
          if (pair.trim().isNotEmpty) {
            List<String> keyValue = pair.split(':');
            if (keyValue.length == 2) {
              String key = keyValue[0].trim().replaceAll('"', '');
              int value = int.tryParse(keyValue[1].trim()) ?? 0;
              phoneticComponents[key] = value;
            }
          }
        }
      }
    } catch (e) {
      phoneticComponents = {'default': 1};
    }

    return Word(
      wordID: map['WordID'] as int?,
      word: map['Word'] as String? ?? '',
      pronunciation: map['Pronunciation'] as String? ?? '',
      phoneticComponents: phoneticComponents,
      phoneticID: map['PhoneticID'] as int? ?? 0,
      translation: map['Translation'] as String? ?? '',
    );
  }
}
