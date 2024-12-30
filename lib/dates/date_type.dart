import 'package:admin_dvij/constants/date_type_constants.dart';
import 'package:admin_dvij/constants/fields_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../design_elements/elements_of_design.dart';

enum DateTypeEnum {
  once,
  long,
  regular,
  irregular,
  notChosen
}

class DateType {

  DateTypeEnum dateType;

  DateType({this.dateType = DateTypeEnum.notChosen});

  factory DateType.fromString({required String enumString}){
    switch (enumString){
      case DateTypeConstants.onceId: return DateType(dateType: DateTypeEnum.once);
      case DateTypeConstants.longId: return DateType(dateType: DateTypeEnum.long);
      case DateTypeConstants.regularId: return DateType(dateType: DateTypeEnum.regular);
      case DateTypeConstants.irregularId: return DateType(dateType: DateTypeEnum.irregular);
      default: return DateType(dateType: DateTypeEnum.notChosen);
    }
  }

  factory DateType.setDateType({required DateType dateType}){
    return DateType(dateType: dateType.dateType);
  }

  Widget getDateTypeWidget({
    required bool canEdit,
    required BuildContext context,
    required VoidCallback onTap
  }){

    TextEditingController dateTypeController = TextEditingController();
    dateTypeController.text = toString(translate: true);

    return ElementsOfDesign.buildTextField(
        controller: dateTypeController,
        labelText: FieldsConstants.dateTypeField,
        canEdit: canEdit,
        icon: FontAwesomeIcons.calendar,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

  @override
  String toString({bool translate = false}) {
    switch (dateType) {
      case DateTypeEnum.once:
        return !translate ? DateTypeConstants.onceId : DateTypeConstants.onceHeadline;
      case DateTypeEnum.long:
        return !translate ? DateTypeConstants.longId : DateTypeConstants.longHeadline;
      case DateTypeEnum.regular:
        return !translate ? DateTypeConstants.regularId : DateTypeConstants.regularHeadline;
      case DateTypeEnum.irregular:
        return !translate ? DateTypeConstants.irregularId : DateTypeConstants.irregularHeadline;
      default: return !translate ? '' : DateTypeConstants.notChosenHeadline;
    }
  }

  List<DateType> getTypesList(){
    return [
      DateType(dateType: DateTypeEnum.once),
      DateType(dateType: DateTypeEnum.long),
      DateType(dateType: DateTypeEnum.regular),
      DateType(dateType: DateTypeEnum.irregular),
    ];
  }

}