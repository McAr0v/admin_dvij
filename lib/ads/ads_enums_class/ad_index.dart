import '../../constants/ads_constants.dart';

enum AdIndexEnum {
  first,
  second,
  third,
  all,
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
      case AdIndexEnum.all:
        return !translate ? AdsConstants.allIndex : AdsConstants.adlIndexSlot;
      case AdIndexEnum.notChosen:
        return !translate ? AdsConstants.notChosenIndex : AdsConstants.notChosenIndexSlot;
    }
  }

  factory AdIndex.fromString({required String text}){
    switch (text){
      case AdsConstants.firstIndex: return AdIndex(index: AdIndexEnum.first);
      case AdsConstants.secondIndex: return AdIndex(index: AdIndexEnum.second);
      case AdsConstants.thirdIndex: return AdIndex(index: AdIndexEnum.third);
      case AdsConstants.allIndex: return AdIndex(index: AdIndexEnum.all);
      default: return AdIndex(index: AdIndexEnum.notChosen);
    }
  }

}