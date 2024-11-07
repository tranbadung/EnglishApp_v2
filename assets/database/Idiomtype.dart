class IdiomType {
  final int id;
  final String name;
  final String translation;

  IdiomType({
    required this.id,
    required this.name,
    required this.translation,
  });

   factory IdiomType.fromJson(Map<String, dynamic> json) {
    return IdiomType(
      id: json['id'],
      name: json['name'],
      translation: json['translation'],
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'translation': translation,
    };
  }
}

 List<IdiomType> idiomTypeList = [
  IdiomType(
      id: 1,
      name: "Idioms about Money and Finance",
      translation: "Tiền bạc và tài chính"),
  IdiomType(id: 2, name: "Idioms about Love", translation: "Tình yêu"),
  IdiomType(
      id: 3,
      name: "Idioms about Happiness and Sadness",
      translation: "Hạnh phúc và nỗi buồn"),
  IdiomType(id: 4, name: "Idioms about Health", translation: "Sức khỏe"),
  IdiomType(id: 5, name: "Idioms about Travel", translation: "Du lịch"),
  IdiomType(id: 6, name: "Idioms about Work", translation: "Công việc"),
  IdiomType(id: 7, name: "Idioms about Friendship", translation: "Tình bạn"),
  IdiomType(id: 8, name: "Idioms about Dreams", translation: "Ước mơ"),
  IdiomType(id: 9, name: "Idioms about Time", translation: "Thời gian"),
  IdiomType(id: 10, name: "Idioms about Decisions", translation: "Quyết định"),
];
