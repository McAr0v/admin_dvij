import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';

class AdClass {
  String id;
  String headline;
  String desc;
  String url;
  String imageUrl;
  DateTime startDate;
  DateTime endDate;
  AdLocation location;
  AdIndex adIndex;
  AdStatus status;
  String clientName;
  String clientPhone;
  String clientWhatsapp;
  DateTime ordersDate;

  AdClass({
    required this.id,
    required this.headline,
    required this.desc,
    required this.url,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.adIndex,
    required this.status,
    required this.clientName,
    required this.clientPhone,
    required this.clientWhatsapp,
    required this.ordersDate
  });
}