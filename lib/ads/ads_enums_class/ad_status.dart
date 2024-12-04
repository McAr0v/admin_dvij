import 'package:admin_dvij/design/app_colors.dart';
import 'package:flutter/material.dart';

import '../../constants/ads_constants.dart';

enum AdStatusEnum {
  active,
  draft,
  completed
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
    }
  }

  factory AdStatus.fromString({required String text}){
    switch (text){
      case AdsConstants.activeSystem: return AdStatus(status: AdStatusEnum.active);
      case AdsConstants.completedSystem: return AdStatus(status: AdStatusEnum.completed);
      default: return AdStatus(status: AdStatusEnum.draft);
    }
  }

  Widget getStatusWidget({required BuildContext context}){
    return Card(
      color: switchColorWidget(),
      child: Padding(
          padding: const EdgeInsets.all(8),
        child: Text(toString(translate: true), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: switchTextColorWidget()),),
      ),
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
    }
  }

}