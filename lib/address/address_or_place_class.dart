import 'package:admin_dvij/constants/address_type_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../design_elements/elements_of_design.dart';

enum AddressTypeEnum {
  address,
  place,
  notChosen
}

class AddressType {

  AddressTypeEnum addressTypeEnum;

  AddressType({this.addressTypeEnum = AddressTypeEnum.notChosen});

  @override
  String toString() {
    switch (addressTypeEnum) {
      case AddressTypeEnum.address: return AddressTypeConstants.onAddress;
      case AddressTypeEnum.place: return AddressTypeConstants.inPlace;
      case AddressTypeEnum.notChosen: return AddressTypeConstants.notChosen;
    }
  }

  List<AddressType> getAddressTypesList () {
    return [
      AddressType(addressTypeEnum: AddressTypeEnum.address),
      AddressType(addressTypeEnum: AddressTypeEnum.place)
    ];
  }

  Widget getAddressTypeFieldWidget({
    required bool canEdit,
    required BuildContext context,
    required VoidCallback onTap
  }){

    TextEditingController addressTypeController = TextEditingController();
    addressTypeController.text = toString();

    return ElementsOfDesign.buildTextField(
        controller: addressTypeController,
        labelText: AddressTypeConstants.whenAction,
        canEdit: canEdit,
        icon: FontAwesomeIcons.city,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

}