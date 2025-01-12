import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ad_view_create_edit_screen.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/categories/event_categories/event_categories_list.dart';
import 'package:admin_dvij/categories/event_categories/event_category.dart';
import 'package:admin_dvij/categories/event_categories/event_category_create_or_edit_screen.dart';
import 'package:admin_dvij/categories/place_categories/place_categories_list.dart';
import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/categories/place_categories/place_category_create_or_edit_screen.dart';
import 'package:admin_dvij/categories/promo_categories/promo_categories_list.dart';
import 'package:admin_dvij/categories/promo_categories/promo_category.dart';
import 'package:admin_dvij/categories/promo_categories/promo_category_create_or_edit_screen.dart';
import 'package:admin_dvij/cities/cities_list_class.dart';
import 'package:admin_dvij/cities/city_class.dart';
import 'package:admin_dvij/cities/city_create_or_edit_screen.dart';
import 'package:admin_dvij/constants/database_constants.dart';
import 'package:admin_dvij/constants/entity_constants.dart';
import 'package:admin_dvij/events/event_class.dart';
import 'package:admin_dvij/events/event_create_view_edit_screen.dart';
import 'package:admin_dvij/events/events_list_class.dart';
import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/feedback/feedback_view_chat_screen.dart';
import 'package:admin_dvij/places/place_create_view_edit_screen.dart';
import 'package:admin_dvij/places/places_list_class.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_class.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_list_class.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_view_edit_screen.dart';
import 'package:admin_dvij/promos/promo_class.dart';
import 'package:admin_dvij/promos/promo_create_edit_view_screen.dart';
import 'package:admin_dvij/promos/promos_list_class.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/admin_user/profile_screen.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_user_screen.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';

import '../places/place_class.dart';

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

  List<LogEntity> getEntitiesList(){
    return [
    LogEntity(entity: EntityEnum.user),
    LogEntity(entity: EntityEnum.city),
    LogEntity(entity: EntityEnum.admin),
    LogEntity(entity: EntityEnum.eventCategory),
    LogEntity(entity: EntityEnum.placeCategory),
    LogEntity(entity: EntityEnum.promoCategory),
    LogEntity(entity: EntityEnum.ad),
    LogEntity(entity: EntityEnum.place),
    LogEntity(entity: EntityEnum.event),
    LogEntity(entity: EntityEnum.promo),
    LogEntity(entity: EntityEnum.policy),
    LogEntity(entity: EntityEnum.feedback),
    ];
  }

  String getEntityName({required String id}) {
    SystemMethodsClass sm = SystemMethodsClass();

    switch (entity) {
      case EntityEnum.user: {
        SimpleUsersList simpleUsersList = SimpleUsersList();
        SimpleUser tempUser = simpleUsersList.getEntityFromList(id);
        return tempUser.uid.isNotEmpty ? tempUser.getFullName() : 'Удалено';
      }
      case EntityEnum.city: {
        CitiesList citiesList = CitiesList();
        City tempCity = citiesList.getEntityFromList(id);
        return tempCity.name.isNotEmpty ? tempCity.name : 'Удалено';
      }
      case EntityEnum.admin: {
        AdminUsersListClass adminUsersListClass = AdminUsersListClass();
        AdminUserClass admin = adminUsersListClass.getEntityFromList(id);
        return admin.uid.isNotEmpty ? admin.getFullName() : 'Удалено';
      }
      case EntityEnum.eventCategory: {
        EventCategoriesList eventCategoriesList = EventCategoriesList();
        EventCategory tempCategory = eventCategoriesList.getEntityFromList(id);
        return tempCategory.name.isNotEmpty ? tempCategory.name : 'Удалено';
      }
      case EntityEnum.placeCategory: {
        PlaceCategoriesList categoriesList = PlaceCategoriesList();
        PlaceCategory tempCategory = categoriesList.getEntityFromList(id);
        return tempCategory.name.isNotEmpty ? tempCategory.name : 'Удалено';
      }
      case EntityEnum.promoCategory: {
        PromoCategoriesList categoriesList = PromoCategoriesList();
        PromoCategory tempCategory = categoriesList.getEntityFromList(id);
        return tempCategory.name.isNotEmpty ? tempCategory.name : 'Удалено';
      }
      case EntityEnum.ad: {
        AdsList adsList = AdsList();
        AdClass ad = adsList.getEntityFromList(id);
        return ad.headline.isNotEmpty ? ad.headline : 'Удалено';
      }
      case EntityEnum.place: {
        PlacesList placesList = PlacesList();
        Place place = placesList.getEntityFromList(id);
        return place.name.isNotEmpty ? place.name : 'Удалено';
      }
      case EntityEnum.event: {
        EventsListClass eventsListClass = EventsListClass();
        EventClass event = eventsListClass.getEntityFromList(id);
        return event.headline.isNotEmpty ? event.headline : 'Удалено';
      }
      case EntityEnum.promo: {
        PromosListClass promosListClass = PromosListClass();
        Promo promo = promosListClass.getEntityFromList(id);
        return promo.headline.isNotEmpty ? promo.headline : 'Удалено';
      }
      case EntityEnum.policy: {
        PrivacyPolicyList privacyPolicyList = PrivacyPolicyList();
        PrivacyPolicyClass privacyPolicyClass = privacyPolicyList.getEntityFromList(id);
        return privacyPolicyClass.id.isNotEmpty
            ? 'Политика конфиденциальности от ${sm.formatDateTimeToHumanViewWithClock(privacyPolicyClass.date)}'
            : 'Удалено';
      }
      case EntityEnum.feedback: {
        FeedbackListClass feedbackListClass = FeedbackListClass();
        FeedbackCustom feedbackCustom = feedbackListClass.getEntityFromList(id);
        return feedbackCustom.id.isNotEmpty
            ? 'Обращение обратной связи от ${sm.formatDateTimeToHumanViewWithClock(feedbackCustom.createDate)}'
            : 'Удалено';
      }
      case EntityEnum.notChosen: return 'Удалено';
    }
  }
  
  dynamic getPageFromEntity({required String entityId}){

    switch (entity) {
      case EntityEnum.user: {
        SimpleUsersList simpleUsersList = SimpleUsersList();
        SimpleUser tempUser = simpleUsersList.getEntityFromList(entityId);
        return tempUser.uid.isNotEmpty
            ? SimpleUserScreen(simpleUser: tempUser)
            : null;
      }
      case EntityEnum.city: {
        CitiesList citiesList = CitiesList();
        City tempCity = citiesList.getEntityFromList(entityId);
        return tempCity.name.isNotEmpty
            ? CityCreateOrEditScreen(city: tempCity,)
            : null;
      }
      case EntityEnum.admin: {
        AdminUsersListClass adminUsersListClass = AdminUsersListClass();
        AdminUserClass admin = adminUsersListClass.getEntityFromList(entityId);
        return admin.uid.isNotEmpty
            ? ProfileScreen(admin: admin,)
            : null;
      }
      case EntityEnum.eventCategory: {
        EventCategoriesList eventCategoriesList = EventCategoriesList();
        EventCategory tempCategory = eventCategoriesList.getEntityFromList(entityId);
        return tempCategory.name.isNotEmpty
            ? EventCategoryCreateOrEditScreen(category: tempCategory,)
            : null;
      }
      case EntityEnum.placeCategory: {
        PlaceCategoriesList categoriesList = PlaceCategoriesList();
        PlaceCategory tempCategory = categoriesList.getEntityFromList(entityId);
        return tempCategory.name.isNotEmpty
            ? PlaceCategoryCreateOrEditScreen(category: tempCategory,)
            : null;
      }
      case EntityEnum.promoCategory: {
        PromoCategoriesList categoriesList = PromoCategoriesList();
        PromoCategory tempCategory = categoriesList.getEntityFromList(entityId);
        return tempCategory.name.isNotEmpty
            ? PromoCategoryCreateOrEditScreen(category: tempCategory,)
            : null;
      }
      case EntityEnum.ad: {
        AdsList adsList = AdsList();
        AdClass ad = adsList.getEntityFromList(entityId);
        return ad.headline.isNotEmpty
            ? AdViewCreateEditScreen(indexTabPage: 0, ad: ad,)
            : null;
      }
      case EntityEnum.place: {
        PlacesList placesList = PlacesList();
        Place place = placesList.getEntityFromList(entityId);
        return place.name.isNotEmpty
            ? PlaceCreateViewEditScreen(place: place,)
            : null;
      }
      case EntityEnum.event: {
        EventsListClass eventsListClass = EventsListClass();
        EventClass event = eventsListClass.getEntityFromList(entityId);
        return event.headline.isNotEmpty
            ? EventCreateViewEditScreen(indexTabPage: 0, event: event,)
            : null;
      }
      case EntityEnum.promo: {
        PromosListClass promosListClass = PromosListClass();
        Promo promo = promosListClass.getEntityFromList(entityId);
        return promo.headline.isNotEmpty
            ? PromoCreateViewEditScreen(indexTabPage: 0, promo: promo,)
            : null;
      }
      case EntityEnum.policy: {
        PrivacyPolicyList privacyPolicyList = PrivacyPolicyList();
        PrivacyPolicyClass privacyPolicyClass = privacyPolicyList.getEntityFromList(entityId);
        return privacyPolicyClass.id.isNotEmpty
            ? PrivacyPolicyViewEditScreen(canEdit: false, isNew: false, copiedPolicy: privacyPolicyClass,)
            : null;
      }
      case EntityEnum.feedback: {
        FeedbackListClass feedbackListClass = FeedbackListClass();
        FeedbackCustom feedbackCustom = feedbackListClass.getEntityFromList(entityId);
        return feedbackCustom.id.isNotEmpty
            ? FeedbackViewChatScreen(feedback: feedbackCustom)
            : null;
      }
      case EntityEnum.notChosen: return null;
    }
  }

}