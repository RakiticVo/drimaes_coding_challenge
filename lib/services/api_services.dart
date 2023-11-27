import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drimaes_coding_challenge/models/user_page_model.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<UserPageModel> getUsers(int pageNumber) async {
    try {
      final response = await _dio.get('https://reqres.in/api/users?page=$pageNumber');
      final userModel = userPageModelFromJson(json.encode(response.data));
      return userModel;
    } catch (e) {
      print("Error fetching users: $e");
      rethrow;
    }
  }
}