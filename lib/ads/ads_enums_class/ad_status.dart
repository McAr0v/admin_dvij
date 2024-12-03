import '../../constants/ads_constants.dart';

enum AdStatusEnum {
  notActive,
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
      case AdStatusEnum.notActive:
        return !translate ? AdsConstants.notActiveSystem : AdsConstants.notActiveHeadline;
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
      case AdsConstants.draftSystem: return AdStatus(status: AdStatusEnum.draft);
      case AdsConstants.completedSystem: return AdStatus(status: AdStatusEnum.completed);
      default: return AdStatus(status: AdStatusEnum.notActive);
    }
  }

}