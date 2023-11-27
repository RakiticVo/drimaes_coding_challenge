import 'dart:convert';

import 'package:drimaes_coding_challenge/models/user_data_model.dart';
import 'package:drimaes_coding_challenge/models/user_support_model.dart';

UserPageModel userPageModelFromJson(String str) => UserPageModel.fromJson(json.decode(str));

String userPageModelToJson(UserPageModel data) => json.encode(data.toJson());

class UserPageModel {
  int page;
  int perPage;
  int total;
  int totalPages;
  List<UserDataModel> data;
  UserSupportModel support;

  UserPageModel({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.data,
    required this.support,
  });

  factory UserPageModel.fromJson(Map<String, dynamic> json) => UserPageModel(
    page: json["page"],
    perPage: json["per_page"],
    total: json["total"],
    totalPages: json["total_pages"],
    data: List<UserDataModel>.from(json["data"].map((x) => UserDataModel.fromJson(x))),
    support: UserSupportModel.fromJson(json["support"]),
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "per_page": perPage,
    "total": total,
    "total_pages": totalPages,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "support": support.toJson(),
  };
}
