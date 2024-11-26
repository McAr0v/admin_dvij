class Gender {
  GenderEnum gender;

  Gender({this.gender = GenderEnum.notChosen});

  factory Gender.fromString(String genderInString){
    GenderEnum tempGender = GenderEnum.notChosen;
    switch (genderInString) {
      case 'man': tempGender = GenderEnum.man;
      case 'woman': tempGender = GenderEnum.woman;
      default: tempGender = GenderEnum.notChosen;
    }

    return Gender(gender: tempGender);

  }

  @override
  String toString({bool needTranslate = false}) {
    switch (gender){
      case GenderEnum.man: return needTranslate ? 'Мужчина' : 'man';
      case GenderEnum.woman: return needTranslate ? 'Женщина' : 'woman';
      case GenderEnum.notChosen: return needTranslate ? 'Пол не выбран' : 'notChosen';
    }
  }

}

enum GenderEnum{
  man,
  woman,
  notChosen
}