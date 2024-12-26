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
      case AddressTypeEnum.address: return 'По адресу';
      case AddressTypeEnum.place: return 'В заведении';
      case AddressTypeEnum.notChosen: return 'Не выбран';
    }
  }

  List<AddressType> getAddressTypesList () {
    return [
      AddressType(addressTypeEnum: AddressTypeEnum.address),
      AddressType(addressTypeEnum: AddressTypeEnum.place)
    ];
  }

}