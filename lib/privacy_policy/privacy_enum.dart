import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:flutter/cupertino.dart';

enum PrivacyEnum {
  draft,
  active
}

class PrivacyStatus {
  PrivacyEnum privacyEnum;

  PrivacyStatus({this.privacyEnum = PrivacyEnum.draft});

  factory PrivacyStatus.fromString({required String statusString}){
    switch (statusString) {

      case 'active' : return PrivacyStatus(privacyEnum: PrivacyEnum.active);
      default : return PrivacyStatus(privacyEnum: PrivacyEnum.draft);
    }
  }

  @override
  String toString({bool translate = false}) {
    switch (privacyEnum) {
      case PrivacyEnum.draft: return !translate ? 'draft' : 'Черновик';
      case PrivacyEnum.active: return !translate ? 'active' : 'Активное';
    }
  }

  Color _switchStatusWidgetColor ({bool isText = false}){
    switch (privacyEnum) {
      case PrivacyEnum.draft: return !isText ? AppColors.greyForCards : AppColors.white;
      case PrivacyEnum.active: return !isText ? AppColors.success : AppColors.greyOnBackground;
    }
  }

  Widget getStatusWidget ({
    required BuildContext context
  }){
    return ElementsOfDesign.getTag(
        context: context,
        text: toString(translate: true),
        color: _switchStatusWidgetColor(),
      textColor: _switchStatusWidgetColor(isText: true)
    );
  }
}