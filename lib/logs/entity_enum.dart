import 'package:admin_dvij/constants/database_constants.dart';
import 'package:admin_dvij/constants/entity_constants.dart';

enum EntityEnum {
  user,
  city,
  admin,
  eventCategory,
  placeCategory,
  promoCategory,
  ad,
  place,
  event,
  promo,
  policy,
  feedback,
  notChosen
}

class LogEntity {
  EntityEnum entity;

  LogEntity({required this.entity});

  factory LogEntity.fromString({required String entityString}){
    switch (entityString) {
      case DatabaseConstants.user: return LogEntity(entity: EntityEnum.user);
      case DatabaseConstants.city: return LogEntity(entity: EntityEnum.city);
      case DatabaseConstants.admin: return LogEntity(entity: EntityEnum.admin);
      case DatabaseConstants.eventCategory: return LogEntity(entity: EntityEnum.eventCategory);
      case DatabaseConstants.placeCategory: return LogEntity(entity: EntityEnum.placeCategory);
      case DatabaseConstants.promoCategory: return LogEntity(entity: EntityEnum.promoCategory);
      case DatabaseConstants.ad: return LogEntity(entity: EntityEnum.ad);
      case DatabaseConstants.place: return LogEntity(entity: EntityEnum.place);
      case DatabaseConstants.event: return LogEntity(entity: EntityEnum.event);
      case DatabaseConstants.promo: return LogEntity(entity: EntityEnum.promo);
      case DatabaseConstants.policy: return LogEntity(entity: EntityEnum.policy);
      case DatabaseConstants.feedback: return LogEntity(entity: EntityEnum.feedback);
      default : return LogEntity(entity: EntityEnum.notChosen);
    }
  }

  @override
  String toString({bool translate = false}) {
    switch (entity) {
      case EntityEnum.user: return !translate ? DatabaseConstants.user : EntityConstants.user;
      case EntityEnum.city: return !translate ? DatabaseConstants.city : EntityConstants.city;
      case EntityEnum.admin: return !translate ? DatabaseConstants.admin : EntityConstants.admin;
      case EntityEnum.eventCategory: return !translate ? DatabaseConstants.eventCategory : EntityConstants.eventCategory;
      case EntityEnum.placeCategory: return !translate ? DatabaseConstants.placeCategory : EntityConstants.placeCategory;
      case EntityEnum.promoCategory: return !translate ? DatabaseConstants.promoCategory : EntityConstants.promoCategory;
      case EntityEnum.ad: return !translate ? DatabaseConstants.ad : EntityConstants.ad;
      case EntityEnum.place: return !translate ? DatabaseConstants.place : EntityConstants.place;
      case EntityEnum.event: return !translate ? DatabaseConstants.event : EntityConstants.event;
      case EntityEnum.promo: return !translate ? DatabaseConstants.promo : EntityConstants.promo;
      case EntityEnum.policy: return !translate ? DatabaseConstants.policy : EntityConstants.policy;
      case EntityEnum.feedback: return !translate ? DatabaseConstants.feedback : EntityConstants.feedback;
      case EntityEnum.notChosen: return !translate ? DatabaseConstants.notChosen : EntityConstants.notChosen;
    }
  }

}