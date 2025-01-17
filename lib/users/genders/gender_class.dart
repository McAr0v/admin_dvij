import 'package:admin_dvij/constants/gender_constants.dart';

class Gender {
  GenderEnum gender;

  Gender({this.gender = GenderEnum.notChosen});

  factory Gender.fromString(String genderInString){
    GenderEnum tempGender = GenderEnum.notChosen;
    switch (genderInString) {
      case GenderConstants.man: tempGender = GenderEnum.man;
      case 'male': tempGender = GenderEnum.man;
      case 'female': tempGender = GenderEnum.woman;
      case GenderConstants.woman: tempGender = GenderEnum.woman;
      default: tempGender = GenderEnum.notChosen;
    }

    return Gender(gender: tempGender);

  }

  List<Gender> getGendersList(){
    return [
      Gender(gender: GenderEnum.man),
      Gender(gender: GenderEnum.woman),
      Gender(gender: GenderEnum.notChosen)

    ];
  }

  String getWasStringOnGender(){
    if (gender == GenderEnum.woman){
      return 'Была онлайн';
    } else if (gender == GenderEnum.man) {
      return 'Был онлайн';
    } else {
      return 'Последний раз онлайн';
    }
  }

  @override
  String toString({bool needTranslate = false}) {
    switch (gender){
      case GenderEnum.man: return needTranslate ? GenderConstants.manHeadline : GenderConstants.man;
      case GenderEnum.woman: return needTranslate ? GenderConstants.womanHeadline : GenderConstants.woman;
      case GenderEnum.notChosen: return needTranslate ? GenderConstants.notChosenHeadline : GenderConstants.notChosen;
    }
  }

}

enum GenderEnum{
  man,
  woman,
  notChosen
}