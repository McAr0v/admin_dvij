import 'package:admin_dvij/address/address_or_place_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design/app_colors.dart';

class AddressTypePicker extends StatefulWidget {
  const AddressTypePicker({Key? key}) : super(key: key);

  @override
  State<AddressTypePicker> createState() => _AddressTypePickerState();
}

class _AddressTypePickerState extends State<AddressTypePicker> {
  List<AddressType> types = [];

  @override
  void initState() {
    super.initState();
    AddressType tempType = AddressType();
    types = tempType.getAddressTypesList();
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
          child: ListBody(
            children: types.map((AddressType addressType) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(addressType);
                },
                child: Card(
                  color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      addressType.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
      ),
    );
  }
}
