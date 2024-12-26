enum AddressTypeEnum {
  address,
  place
}

class AddressType {

  AddressTypeEnum addressTypeEnum;

  AddressType({this.addressTypeEnum = AddressTypeEnum.address});

  @override
  String toString() {
    switch (addressTypeEnum) {
      case AddressTypeEnum.address: return 'По адресу';
      case AddressTypeEnum.place: return 'В заведении';
    }
  }

  List<AddressType> getAddressTypesList () {
    return [
      AddressType(),
      AddressType(addressTypeEnum: AddressTypeEnum.place)
    ];
  }

}