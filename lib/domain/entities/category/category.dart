class Category {
  final int categoryID;
  final String name;
  final String translation;
  final String imageUrl;

  Category({
    required this.categoryID,
    required this.name,
    required this.translation,
    required this.imageUrl,
  });
  Map<String, dynamic> toMap() {
    return {
      'CategoryID': categoryID,
      'Name': name,
      'Translation': translation,
      'ImageURL': imageUrl,
    };
  }
  // Tạo đối tượng từ Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryID: map['CategoryID'],
      name: map['Name'],
      translation: map['Translation'],
      imageUrl: map['ImageURL'],
    );
  }

  factory Category.initial() => Category(
    categoryID: 0,
    name: '',
    translation: '',
    imageUrl: '',
  );
}

final List<Category> categories = [
  Category(
    categoryID: 1,
    name: 'Active Lifestyle',
    translation: 'Lối sống năng động',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 2,
    name: 'Art',
    translation: 'Nghệ thuật',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 3,
    name: 'Business',
    translation: 'Việc kinh doanh',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 4,
    name: 'Community',
    translation: 'Cộng đồng',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 5,
    name: 'Dining',
    translation: 'Ẩm thực',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 6,
    name: 'Entertainment',
    translation: 'Giải trí',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 7,
    name: 'Fashion',
    translation: 'Thời trang',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 8,
    name: 'Festivities',
    translation: 'Lễ hội',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 9,
    name: 'Health',
    translation: 'Sức khỏe',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 10,
    name: 'Literature',
    translation: 'Văn học',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 11,
    name: 'Memorable Events',
    translation: 'Sự kiện đáng nhớ',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 12,
    name: 'Online Presence',
    translation: 'Hiện diện trực tuyến',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 13,
    name: 'Personal Development',
    translation: 'Phát triển cá nhân',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 14,
    name: 'Relationship',
    translation: 'Mối quan hệ',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 15,
    name: 'Technology',
    translation: 'Công nghệ',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 16,
    name: 'Travel',
    translation: 'Du lịch',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
  Category(
    categoryID: 17,
    name: 'Urban Life',
    translation: 'Cuộc sống đô thị',
    imageUrl:
    'https://firebasestorage.googleapis.com/v0/b/speak-up-flutter.appspot.com/o/temp_topic.png?alt=media&token=1a238f27-1f93-41d6-a288-efd86b89dc6a',
  ),
];
