import 'package:drimaes_coding_challenge/database/database_helper.dart';
import 'package:drimaes_coding_challenge/models/user_page_model.dart';
import 'package:drimaes_coding_challenge/notification/notification_services.dart';
import 'package:drimaes_coding_challenge/providers/user_list_view_model.dart';
import 'package:drimaes_coding_challenge/screens/user_list_screen/widgets/user_card_info.dart';
import 'package:drimaes_coding_challenge/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserPageModel> userPages = [];
  bool isGridView = true;
  bool isLoading = true;

  NumberPaginatorController controllerGridView = NumberPaginatorController();
  NumberPaginatorController controllerListView = NumberPaginatorController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final userListViewModel = Provider.of<UserListViewModel>(context, listen: false);
    final notificationService = NotificationService();

    if (await notificationService.isConnectedToInternet()) {
      try {
        final userPage = await apiService.getUsers(1);
        userListViewModel.addAllUserPages([userPage]);
        userListViewModel.updateUserDataList();

        final DatabaseHelper databaseHelper = DatabaseHelper();
        await databaseHelper.saveUserPages(userListViewModel.userPages);

      } catch (e) {
        rethrow;
      }
    } else {
      await notificationService.showNoInternetNotification();

      await userListViewModel.getUserPagesFromDatabase();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        centerTitle: true,
        leading: Container(),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_on),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: isLoading == true
          ? const Center(child: CircularProgressIndicator(backgroundColor: Colors.grey, color: Colors.blueAccent,))
          : isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildGridView() {
    final userListViewModel = Provider.of<UserListViewModel>(context);

    final controller = ScrollController();

    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        userListViewModel.loadMore();
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        await userListViewModel.refresh(context);
      },
      child: SizedBox(
        height: 600.0,
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.only(top: 8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: userListViewModel.userDataList.length,
                itemBuilder: (BuildContext context, int index) {
                  return UserCard(
                    imageUrl: userListViewModel.userDataList[index].avatar,
                    email: userListViewModel.userDataList[index].email,
                    name: '${userListViewModel.userDataList[index].firstName} ${userListViewModel.userDataList[index].lastName}',
                    isListView: false,
                  );
                },
              ),
            ),
            userListViewModel.isLoadingMore// Display loading indicator when loading more
            ? const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
            : Container()
          ],
        ),
      ),
    );
  }


  Widget _buildListView() {
    final userListViewModel = Provider.of<UserListViewModel>(context);

    final controller = ScrollController();

    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        userListViewModel.loadMore();
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        await userListViewModel.refresh(context);
      },
      child: SizedBox(
        height: 600.0,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.only(top: 8.0),
                itemCount: userListViewModel.userDataList.length,
                itemBuilder: (BuildContext context, int index) {
                  return UserCard(
                    imageUrl: userListViewModel.userDataList[index].avatar,
                    email: userListViewModel.userDataList[index].email,
                    name: '${userListViewModel.userDataList[index].firstName} ${userListViewModel.userDataList[index].lastName}',
                    isListView: false,
                  );
                },
              ),
            ),
            userListViewModel.isLoadingMore// Display loading indicator when loading more
            ? const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
            : Container()
          ],
        ),
      ),
    );
  }
}