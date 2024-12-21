import 'package:admin_dvij/interfaces/entity_interface.dart';

import '../categories/event_categories/event_category.dart';
import '../cities/city_class.dart';
import '../dates/regular_date_class.dart';

class EventClass implements IEntity{

  String id;
  DateTypeEnum dateType;
  String headline;
  String desc;
  String creatorId;
  DateTime createDate;
  EventCategory category;
  City city;
  String street;
  String house;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  String imageUrl;
  String placeId;
  PriceTypeOption priceType;
  String price;
  OnceDate onceDay;
  LongDate longDays;
  RegularDate regularDays;
  IrregularDate irregularDays;

}