import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:flutter/material.dart';

import '../../constants/ads_constants.dart';

enum AdStatusEnum {
  active,
  draft,
  completed,
  notChosen
}

class AdStatus {

  AdStatusEnum status;

  AdStatus({required this.status});

  @override
  String toString({bool translate = false}) {
    switch (status) {
      case AdStatusEnum.active:
        return !translate ? AdsConstants.activeSystem : AdsConstants.activeHeadline;
      case AdStatusEnum.draft:
        return !translate ? AdsConstants.draftSystem : AdsConstants.draftHeadline;
      case AdStatusEnum.completed:
        return !translate ? AdsConstants.completedSystem : AdsConstants.completedHeadline;
      case AdStatusEnum.notChosen:
        return !translate ? AdsConstants.notChosenStatusSystem : AdsConstants.notChosenStatusHeadline;
    }
  }

  factory AdStatus.fromString({required String text}){
    switch (text){
      case AdsConstants.activeSystem: return AdStatus(status: AdStatusEnum.active);
      case AdsConstants.completedSystem: return AdStatus(status: AdStatusEnum.completed);
      case AdsConstants.notChosenStatusSystem: return AdStatus(status: AdStatusEnum.notChosen);
      default: return AdStatus(status: AdStatusEnum.draft);
    }
  }

  List<AdStatus> getStatusList(){
    return [
      AdStatus(status: AdStatusEnum.draft),
      AdStatus(status: AdStatusEnum.active),
      AdStatus(status: AdStatusEnum.completed),
    ];
  }

  Widget getStatusWidget({required BuildContext context}){
    return ElementsOfDesign.getTag(
        context: context,
        text: toString(translate: true),
        color: switchColorWidget(),
        textColor: switchTextColorWidget()
    );
  }

  Color switchColorWidget(){
    switch (status) {
      case AdStatusEnum.active:
        return AppColors.activeAdColor;
      case AdStatusEnum.draft:
        return AppColors.draftAdColor;
      case AdStatusEnum.completed:
        return AppColors.completedAdColor;
      case AdStatusEnum.notChosen:
        return AppColors.draftAdColor;
    }
  }

  Color switchTextColorWidget(){
    switch (status) {
      case AdStatusEnum.active:
        return AppColors.white;
      case AdStatusEnum.draft:
        return AppColors.greyOnBackground;
      case AdStatusEnum.completed:
        return AppColors.white;
      case AdStatusEnum.notChosen:
        return AppColors.greyOnBackground;
    }
  }

}