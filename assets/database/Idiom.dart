class Idiom {
  final int idiomID;
  final int idiomTypeID;
  final String name;
  final String description;
  final String descriptionTranslation;
  final String audioEndpoint;

  Idiom({
    required this.idiomID,
    required this.idiomTypeID,
    required this.name,
    required this.description,
    required this.descriptionTranslation,
    required this.audioEndpoint,
  });

  // Method to convert JSON data into an Idiom instance
  factory Idiom.fromJson(Map<String, dynamic> json) {
    return Idiom(
      idiomID: json['IdiomID'] as int,
      idiomTypeID: json['IdiomTypeID'] as int,
      name: json['Name'] as String,
      description: json['Description'] as String,
      descriptionTranslation: json['DescriptionTranslation'] as String,
      audioEndpoint: json['AudioEndpoint'] as String,
    );
  }

  // Method to convert an Idiom instance into JSON format
  Map<String, dynamic> toJson() {
    return {
      'IdiomID': idiomID,
      'IdiomTypeID': idiomTypeID,
      'Name': name,
      'Description': description,
      'DescriptionTranslation': descriptionTranslation,
      'AudioEndpoint': audioEndpoint,
    };
  }
}

List<Idiom> sampleIdioms = [
  Idiom(
    idiomID: 1,
    idiomTypeID: 1,
    name: "A penny saved is a penny earned",
    description:
        "Advice saying that it’s good to save money. When money is saved, it is as good as earning it.",
    descriptionTranslation:
        "Lời khuyên cho rằng việc tiết kiệm tiền là tốt. Khi tiền được tiết kiệm, nó giống như kiếm được tiền.",
    audioEndpoint: "1-money-idioms-00",
  ),
  Idiom(
    idiomID: 2,
    idiomTypeID: 1,
    name: "Beyond one’s means",
    description: "To spend more money than you can afford.",
    descriptionTranslation: "Tiêu nhiều tiền hơn khả năng của bạn.",
    audioEndpoint: "1-money-idioms-04",
  ),
  Idiom(
    idiomID: 3,
    idiomTypeID: 1,
    name: "Someone’s bread and butter",
    description:
        "Someone’s basic income, someone’s livelihood, a job or activity that provides them with a steady income.",
    descriptionTranslation:
        "Thu nhập cơ bản của ai đó, sinh kế của ai đó, công việc hoặc hoạt động cung cấp cho họ thu nhập ổn định.",
    audioEndpoint: "1-money-idioms-08",
  ),
  Idiom(
    idiomID: 4,
    idiomTypeID: 1,
    name: "Cut one’s losses",
    description:
        "To stop doing an activity that causes losses or damage, to avoid losing any more money.",
    descriptionTranslation:
        "Ngừng thực hiện một hoạt động gây tổn thất hoặc thiệt hại, để tránh mất thêm tiền.",
    audioEndpoint: "1-money-idioms-12",
  ),
  Idiom(
    idiomID: 5,
    idiomTypeID: 1,
    name: "Down-and-out",
    description:
        "(adj) having no money, no job and no home (n) a person who has no money, no job and no home.",
    descriptionTranslation:
        "(adj) không có tiền, không có việc làm và không có nhà (n) một người không có tiền, không có việc làm và không có nhà.",
    audioEndpoint: "1-money-idioms-16",
  ),
  Idiom(
    idiomID: 6,
    idiomTypeID: 1,
    name: "Dutch treat \\ Go Dutch",
    description:
        "Dutch treat: a situation or a meal in which each person pays for themselves.",
    descriptionTranslation:
        "Dutch treat: một trường hợp hoặc bữa ăn mà mỗi người tự trả tiền cho mình.",
    audioEndpoint: "1-money-idioms-20",
  ),
  Idiom(
    idiomID: 7,
    idiomTypeID: 1,
    name: "Money talks.",
    description:
        "Money is so powerful, it can get things done or help a person succeed.",
    descriptionTranslation:
        "Tiền có sức mạnh rất lớn, nó có thể hoàn thành nhiều việc hoặc giúp ai đó thành công.",
    audioEndpoint: "1-money-idioms-24",
  ),
  Idiom(
    idiomID: 8,
    idiomTypeID: 1,
    name: "Bring home the bacon",
    description:
        "To go out to work and earn money for the family, to successfully bring in an income for the family.",
    descriptionTranslation:
        "Hãy ra ngoài làm việc và kiếm tiền cho gia đình, để thành công mang về thu nhập cho gia đình.",
    audioEndpoint: "1-money-idioms-28",
  ),
  Idiom(
    idiomID: 9,
    idiomTypeID: 1,
    name: "At all costs",
    description:
        "You use this to say that you’re determined to achieve whatever it takes.",
    descriptionTranslation: "Bằng mọi giá",
    audioEndpoint: "1-money-idioms-32",
  ),
  Idiom(
    idiomID: 10,
    idiomTypeID: 1,
    name: "Earn a living",
    description: "To earn money to pay for food, housing, clothing, etc.",
    descriptionTranslation: "Kiếm tiền trả cho thức ăn, nhà ở, quần áo, v.v.",
    audioEndpoint: "1-money-idioms-36",
  ),
  // Add more entries as needed...
];
