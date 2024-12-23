import 'package:admin_dvij/dates/date_type.dart';
import 'package:admin_dvij/interfaces/entity_interface.dart';
import 'package:admin_dvij/price_type/price_type_class.dart';

import '../categories/event_categories/event_category.dart';
import '../cities/city_class.dart';
import '../dates/irregular_date.dart';
import '../dates/once_date.dart';
import '../dates/regular_date_class.dart';

class EventClass implements IEntity{

  String id;
  DateType dateType;
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
  PriceType priceType;
  String price;
  OnceDate onceDay;
  LongDate longDays;
  RegularDate regularDays;
  IrregularDate irregularDays;

}