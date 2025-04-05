class Phonetic {
  int? phoneticID;
  String phonetic;
  String youtubeVideoId;
  String example;
  int phoneticType;
  String description;

  Phonetic({
    this.phoneticID,
    required this.phonetic,
    required this.youtubeVideoId,
    required this.example,
    required this.phoneticType,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'PhoneticID': phoneticID,
      'Phonetic': phonetic,
      'YoutubeVideoID': youtubeVideoId,
      'Example': example,
      'PhoneticType': phoneticType,
      'Description': description,
    };
  }

  factory Phonetic.fromMap(Map<String, dynamic> map) {
    return Phonetic(
      phoneticID: map['PhoneticID'],
      phonetic: map['Phonetic'],
      youtubeVideoId: map['YoutubeVideoID'],
      example: map['Example'],
      phoneticType: map['PhoneticType'],
      description: map['Description'],
    );
  }
}
