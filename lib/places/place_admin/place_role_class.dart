import 'package:admin_dvij/constants/place_role_constants.dart';

enum PlaceUserRoleEnum {
  admin,
  org,
  creator,
  reader
}

class PlaceRole {
  PlaceUserRoleEnum role;
  
  PlaceRole({this.role = PlaceUserRoleEnum.reader});

  factory PlaceRole.fromString({required String roleString}){

    switch (roleString) {
      case PlaceRoleConstants.admin: return PlaceRole(role: PlaceUserRoleEnum.admin);
      case PlaceRoleConstants.org: return PlaceRole(role: PlaceUserRoleEnum.org);
      case PlaceRoleConstants.creator: return PlaceRole(role: PlaceUserRoleEnum.creator);
      default: return PlaceRole(role: PlaceUserRoleEnum.reader);
    }
  }

  @override
  String toString({bool needTranslate = false}) {
    switch (role) {
      case PlaceUserRoleEnum.admin: return !needTranslate ? PlaceRoleConstants.admin : PlaceRoleConstants.adminHeadline;
      case PlaceUserRoleEnum.org: return !needTranslate ? PlaceRoleConstants.org : PlaceRoleConstants.orgHeadline;
      case PlaceUserRoleEnum.creator: return !needTranslate ? PlaceRoleConstants.creator : PlaceRoleConstants.creatorHeadline;
      case PlaceUserRoleEnum.reader: return !needTranslate ? PlaceRoleConstants.reader : PlaceRoleConstants.readerHeadline;
    }
  }

  String getDesc(){
    switch (role) {
      case PlaceUserRoleEnum.admin: return PlaceRoleConstants.adminDesc;
      case PlaceUserRoleEnum.org: return PlaceRoleConstants.orgDesc;
      case PlaceUserRoleEnum.creator: return PlaceRoleConstants.creatorDesc;
      case PlaceUserRoleEnum.reader: return PlaceRoleConstants.readerDesc;
    }
  }

  List<PlaceRole> getPlacesRolesList(){
    return [
      PlaceRole(role: PlaceUserRoleEnum.admin),
      PlaceRole(role: PlaceUserRoleEnum.org),
      PlaceRole(role: PlaceUserRoleEnum.reader),
    ];
  }

}