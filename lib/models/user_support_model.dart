class UserSupportModel {
  String url;
  String text;

  UserSupportModel({
    required this.url,
    required this.text,
  });

  factory UserSupportModel.fromJson(Map<String, dynamic> json) => UserSupportModel(
    url: json["url"],
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "text": text,
  };
}