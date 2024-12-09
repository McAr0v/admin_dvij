import 'package:flutter/material.dart';
import '../../constants/ads_constants.dart';
import '../../design/app_colors.dart';

enum AdIndexEnum {
  first,
  second,
  third,
  notChosen
}

class AdIndex {

  AdIndexEnum index;

  AdIndex({required this.index});

  @override
  String toString({bool translate = false}) {
    switch (index) {
      case AdIndexEnum.first:
        return !translate ? AdsConstants.firstIndex : AdsConstants.firstIndexSlot;
      case AdIndexEnum.second:
        return !translate ? AdsConstants.secondIndex : AdsConstants.secondIndexSlot;
      case AdIndexEnum.third:
        return !translate ? AdsConstants.thirdIndex : AdsConstants.thirdIndexSlot;
      case AdIndexEnum.notChosen:
        return !translate ? AdsConstants.notChosenIndex : AdsConstants.notChosenIndexSlot;
    }
  }

  factory AdIndex.fromString({required String text}){
    switch (text){
      case AdsConstants.firstIndex: return AdIndex(index: AdIndexEnum.first);
      case AdsConstants.secondIndex: return AdIndex(index: AdIndexEnum.second);
      case AdsConstants.thirdIndex: return AdIndex(index: AdIndexEnum.third);
      default: return AdIndex(index: AdIndexEnum.notChosen);
    }
  }

  Widget getStatusWidget({required BuildContext context}){
    return Card(
      color: switchColorWidget(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(toString(translate: true), style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyOnBackground),),
      ),
    );
  }

  Color switchColorWidget(){
    switch (index) {
      case AdIndexEnum.first:
        return AppColors.slot1Color;
      case AdIndexEnum.second:
        return AppColors.slot2Color;
      case AdIndexEnum.third:
        return AppColors.slot3Color;
      case AdIndexEnum.notChosen:
        return AppColors.greyForCards;
    }
  }

  List<AdIndex> getIndexList(){
    return [
      AdIndex(index: AdIndexEnum.notChosen),
      AdIndex(index: AdIndexEnum.first),
      AdIndex(index: AdIndexEnum.second),
      AdIndex(index: AdIndexEnum.third),
    ];
  }

}