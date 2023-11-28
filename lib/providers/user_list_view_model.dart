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

      // Clear existing data
      _userPages.clear();
      _userDataList.clear();
      _currentPage = 1;

      // Load user pages from SQLite
      await getUserPagesFromDatabase();
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUserDataList() {
    print('_currentPage = $_currentPage');
    print('_userPages.length = ${_userPages.length}');
    if (_userPages.isNotEmpty && _currentPage <= _userPages.length) {
      // for(UserDataModel userModel in _userPages[_currentPage - 1].data){
      //   log('userModel =${userModel.toJson().toString()}');
      // }
      _userDataList.addAll(_userPages[_currentPage - 1].data);
      notifyListeners();
    }
  }

  Future<void> fetchUserPages() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Fetch user pages from the API or any source
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
      return; // Avoid loading more if a request is already in progress
    }

    try {
      _isLoadingMore = true;
      notifyListeners();

      // Implement your logic to load more data, for example:
      final nextPageNumber = _currentPage + 1;
      final newPage = await _databaseHelper.getUserPage(nextPageNumber);

      if (newPage != null) {
        _userPages.add(newPage);
        _currentPage = nextPageNumber; // Update _currentPage
        updateUserDataList();
        // for(UserPageModel userModel in _userPages){
        //   log('page = ${userModel.toJson().toString()}');
        // }
      } else {
        print("Failed to load more data."); // Log a message if loading fails
      }
    } catch (e) {
      print("Error loading more: $e");
      // Handle the error (e.g., show an error message to the user)
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> getUserPagesFromDatabase() async {
    try {
      final userPages = await _databaseHelper.getUserPages();
      // for(UserPageModel userModel in userPages){
      //   log('user page: ${userModel.toJson().toString()}');
      // }
      if(userPages != null){
        _userPages = userPages;
        updateUserDataList();
        notifyListeners();
      }
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