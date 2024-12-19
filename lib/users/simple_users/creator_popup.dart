import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import '../../constants/system_constants.dart';
import '../../design/app_colors.dart';
import '../../design/loading_screen.dart';

class CreatorPopup extends StatefulWidget {
  const CreatorPopup({Key? key}) : super(key: key);

  @override
  State<CreatorPopup> createState() => _CreatorPopupState();
}

class _CreatorPopupState extends State<CreatorPopup> {

  bool loading = false;

  AdminUserClass currentAdminUser = AdminUserClass.empty();

  SimpleUsersList usersListClass = SimpleUsersList();
  TextEditingController searchController = TextEditingController();

  List<SimpleUser> currentUsersList = [];
  List<SimpleUser> filteredUsersList = [];

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization()async{
    setState(() {
      loading = true;
    });

    currentUsersList = await usersListClass.getDownloadedList();
    filteredUsersList = List.from(currentUsersList);

    currentAdminUser = await currentAdminUser.getCurrentUser(fromDb: false);

    setState(() {
      loading = false;
    });
  }

  void updateFilteredUsers(String query) {
    setState(() {
      filteredUsersList = currentUsersList
          .where((user) =>
          user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase()) ||
          user.lastName.toLowerCase().contains(query.toLowerCase()) ||
          user.getFullName().toLowerCase().contains(query.toLowerCase()) ||
          user.phone.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (loading) const LoadingScreen(),
        if (!loading) Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: const BoxDecoration(
            color: AppColors.greyBackground,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Имя, фамилия, телефон...',
                  ),
                  onChanged: (value) {
                    updateFilteredUsers(value);
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              if (filteredUsersList.isEmpty) Expanded(
                  child: Text(SystemConstants.requestAnswerNegative(searchController.text))
              ),

              if (filteredUsersList.isNotEmpty) Expanded(
                  child: SingleChildScrollView(
                    child: ListBody(
                      children: filteredUsersList.map((SimpleUser user) {
                        return user.getUserCardInList(
                            context: context,
                            onTap: () => Navigator.of(context).pop(user),
                            createAdminFunc: (){},
                            currentAdmin: currentAdminUser
                        );
                      }).toList(),
                    ),
                  )
              ),
            ],
          ),
        )
      ],
    );
  }
}
