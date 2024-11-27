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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
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

            ],
          )
      ),
    );
  }
}