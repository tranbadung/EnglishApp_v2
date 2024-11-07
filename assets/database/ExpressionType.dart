class Expression {
  final int id;
  final String name;
  final String translation;
  final int type;

  Expression({
    required this.id,
    required this.name,
    required this.translation,
    required this.type,
  });

  // Phương thức để tạo instance từ JSON
  factory Expression.fromJson(Map<String, dynamic> json) {
    return Expression(
      id: json['id'],
      name: json['name'],
      translation: json['translation'],
      type: json['type'],
    );
  }

  // Phương thức để chuyển đổi instance thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'translation': translation,
      'type': type,
    };
  }
}

// Dữ liệu mẫu
List<Expression> expressionList = [
  Expression(
      id: 1,
      name: "General greetings (Formal)",
      translation: "Lời chào chung (trang trọng)",
      type: 1),
  Expression(
      id: 2,
      name: "General greetings (Informal)",
      translation: "Lời chào chung (không trang trọng)",
      type: 1),
  Expression(
      id: 3,
      name: "Greeting someone you haven’t seen for a long time.",
      translation: "Chào hỏi ai đó mà bạn đã lâu không gặp.",
      type: 1),
  Expression(
      id: 4,
      name: "Useful responses when greeting people",
      translation: "Những câu trả lời hữu ích khi chào hỏi mọi người",
      type: 1),
  Expression(
      id: 5,
      name: "Different ways to say goodbye.",
      translation: "Những cách khác nhau để nói tạm biệt.",
      type: 2),
  Expression(
      id: 6,
      name: "Apologies Expressions",
      translation: "Biểu hiện lời xin lỗi",
      type: 3),
  Expression(
      id: 7,
      name: "To accept an apology, you can use these sentences and ...",
      translation:
          "Để chấp nhận lời xin lỗi, bạn có thể sử dụng các câu và ...",
      type: 3),
  Expression(
      id: 8,
      name: "Introducing yourself",
      translation: "Giới thiệu bản thân",
      type: 4),
  Expression(
      id: 9,
      name: "Introducing others",
      translation: "Giới thiệu người khác",
      type: 4),
  Expression(
      id: 10,
      name: "Useful responses when introducing yourself or other people",
      translation:
          "Những câu trả lời hữu ích khi giới thiệu bản thân hoặc người khác",
      type: 4),
  Expression(
      id: 11,
      name: "Useful Responses:",
      translation: "Phản hồi hữu ích:",
      type: 5),
  Expression(
      id: 12,
      name: "Talking About Time",
      translation: "Nói về thời gian",
      type: 6),
  Expression(
      id: 13,
      name: "Do you speak English?",
      translation: "Bạn có nói tiếng Anh không?",
      type: 7),
  Expression(
      id: 14,
      name: "Giving Compliments:",
      translation: "Đưa ra lời khen:",
      type: 8),
  Expression(
      id: 15,
      name: "Receiving compliments:",
      translation: "Nhận được lời khen:",
      type: 8),
  Expression(
      id: 16, name: "Making a complaint", translation: "Khiếu nại", type: 9),
  Expression(
      id: 17,
      name: "Accepting a complaint",
      translation: "Chấp nhận một khiếu nại",
      type: 9),
  Expression(
      id: 18,
      name: "Rejecting a complaint",
      translation: "Từ chối một khiếu nại",
      type: 9),
  Expression(
      id: 19,
      name: "Expressing Likes:",
      translation: "Bày tỏ sở thích:",
      type: 10),
  Expression(
      id: 20,
      name: "Expressing dislikes:",
      translation: "Bày tỏ không thích:",
      type: 10),
  Expression(
      id: 21,
      name: "Asking for Certainty:",
      translation: "Yêu cầu sự chắc chắn:",
      type: 11),
  Expression(
      id: 22,
      name: "Expressing Certainty:",
      translation: "Biểu hiện sự chắc chắn:",
      type: 11),
  // Thêm các mục khác nếu cần
];
