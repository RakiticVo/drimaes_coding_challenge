import 'package:drimaes_coding_challenge/database/database_helper.dart';
import 'package:drimaes_coding_challenge/models/user_page_model.dart';
import 'package:flutter/material.dart';

class UserListViewModel extends ChangeNotifier {
  List<UserPageModel> _userPages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;

  List<UserPageModel> get userPages => _userPages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> refresh() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Fetch the latest user pages from the API or any source
      final newUserPages = await _databaseHelper.getUserPages();

      // Update the existing user pages with the new data
      _userPages = newUserPages;
      notifyListeners();
    } catch (e) {
      print("Error refreshing user pages: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserPages() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Fetch user pages from the API or any source
      final newUserPages = await _databaseHelper.getUserPages();

      _userPages = newUserPages;
      notifyListeners();
    } catch (e) {
      print("Error fetching user pages: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) {
      return; // Avoid loading more if a request is already in progress
    }

    try {
      _isLoadingMore = true;
      notifyListeners();

      // Implement your logic to load more data, for example:
      final nextPageNumber = _userPages.length + 1;
      final newPage = await _databaseHelper.getUserPage(nextPageNumber);

      if (newPage != null && newPage.data.isNotEmpty) {
        _userPages.add(newPage);
      }
    } catch (e) {
      print("Error loading more: $e");
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> getUserPagesFromDatabase() async {
    try {
      final userPages = await _databaseHelper.getUserPages();
      _userPages = userPages;
      notifyListeners();
    } catch (e) {
      print("Error fetching user pages from database: $e");
    }
  }

  void addUserPages(List<UserPageModel> newUserPages) {
    _userPages = newUserPages;
    notifyListeners();
  }

  void addAllUserPages(List<UserPageModel> userPages) {
    _userPages.addAll(userPages);
    notifyListeners();
  }

  void updateUserPages(List<UserPageModel> newUserPages) {
    _userPages = newUserPages;
    notifyListeners();
  }
}
