import 'package:admin_dvij/users/roles/admins_roles_class.dart';
import 'package:flutter/material.dart';
import '../../design/app_colors.dart';

class AdminPicker extends StatefulWidget {

  const AdminPicker({super.key});

  @override
  State<AdminPicker> createState() => _AdminPickerState();
}

class _AdminPickerState extends State<AdminPicker> {

  List<AdminRoleClass> rolesList = [];

  @override
  void initState() {
    super.initState();
    AdminRoleClass admin = AdminRoleClass(AdminRole.viewer);
    rolesList = admin.getRolesList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        //width: MediaQuery.of(context).size.width * 0.95,
        //height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.greyBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Выберите роль',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),

            const SizedBox(height: 10,),
            SingleChildScrollView(
                child: Column(
                  children: [
                    ListBody(
                      children: rolesList.map((AdminRoleClass admin) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(admin);
                          },
                          child: Card(
                            color: AppColors.greyOnBackground,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    admin.getNameOrDescOfRole(true),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    admin.getNameOrDescOfRole(false),
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    ListBody(
                      children: rolesList.map((AdminRoleClass admin) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(admin);
                          },
                          child: Card(
                            color: AppColors.greyOnBackground,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    admin.getNameOrDescOfRole(true),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    admin.getNameOrDescOfRole(false),
                                    style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}