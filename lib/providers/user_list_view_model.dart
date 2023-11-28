import 'package:drimaes_coding_challenge/database/database_helper.dart';
import 'package:drimaes_coding_challenge/models/user_data_model.dart';
import 'package:drimaes_coding_challenge/models/user_page_model.dart';
import 'package:drimaes_coding_challenge/notification/notification_services.dart';
import 'package:drimaes_coding_challenge/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserListViewModel extends ChangeNotifier {
  List<UserPageModel> _userPages = [];
  List<UserDataModel> _userDataList = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  List<UserPageModel> get userPages => _userPages;
  List<UserDataModel> get userDataList => _userDataList;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> refresh(BuildContext context) async {
    final notificationService = NotificationService();
    if (await notificationService.isConnectedToInternet()) {
      try {
        _isLoading = true;
        notifyListeners();

        // Clear existing data
        _userPages.clear();
        _userDataList.clear();
        _currentPage = 1;

        final apiService = Provider.of<ApiService>(context, listen: false);

        final userPage = await apiService.getUsers(1);
        addAllUserPages([userPage]);
        updateUserDataList();

        final DatabaseHelper databaseHelper = DatabaseHelper();
        await databaseHelper.saveUserPages(userPages);

      } catch (e) {
        print("Error refreshing user pages: $e");
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // No internet connection
      await notificationService.showNoInternetNotification();
      _isLoading = true;
      notifyListeners();

      _userPages.clear();
      _userDataList.clear();
      _currentPage = 1;

      await getUserPagesFromDatabase();
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUserDataList() {
    if (_userPages.isNotEmpty && _currentPage <= _userPages.length) {
      _userDataList.addAll(_userPages[_currentPage - 1].data);
      notifyListeners();
    }
  }

  Future<void> fetchUserPages() async {
    try {
      _isLoading = true;
      notifyListeners();

      final newUserPages = await _databaseHelper.getUserPages();

      if(newUserPages != null){
        _userPages = newUserPages;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user pages: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) {
      return;
    }

    try {
      _isLoadingMore = true;
      notifyListeners();

      final nextPageNumber = _currentPage + 1;
      final newPage = await _databaseHelper.getUserPage(nextPageNumber);

      if (newPage != null) {
        _userPages.add(newPage);
        _currentPage = nextPageNumber; // Update _currentPage
        updateUserDataList();
      } else {
        print("Failed to load more data.");
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
      if(userPages != null){
        _userPages = userPages;
        updateUserDataList();
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user pages from database: $e");
    }
  }

  void addAllUserPages(List<UserPageModel> userPages) {
    _userPages.addAll(userPages);
    notifyListeners();
  }
}