import 'package:admin_dvij/constants/fields_constants.dart';
import 'package:admin_dvij/constants/price_type_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../design_elements/elements_of_design.dart';

enum PriceTypeEnum {
  free,
  fixed,
  range,
  notChosen
}

class PriceType {

  PriceTypeEnum priceType;

  PriceType({this.priceType = PriceTypeEnum.notChosen});

  factory PriceType.fromString({required String enumString}){
    switch (enumString){
      case PriceTypeConstants.freeId: return PriceType(priceType: PriceTypeEnum.free);
      case PriceTypeConstants.fixedId: return PriceType(priceType: PriceTypeEnum.fixed);
      case PriceTypeConstants.rangeId: return PriceType(priceType: PriceTypeEnum.range);
      default: return PriceType();
    }
  }

  factory PriceType.setPriceType({required PriceType priceType}){
    return PriceType(priceType: priceType.priceType);
  }

  Widget getFreePriceWidget({required BuildContext context}){
    return ElementsOfDesign.buildTextField(
        controller: TextEditingController(text: PriceTypeConstants.freePrice),
        labelText: FieldsConstants.priceHeadline,
        canEdit: false,
        icon: FontAwesomeIcons.dollarSign,
        context: context
    );
  }

  Widget getPriceTypeFieldWidget({
    required bool canEdit,
    required BuildContext context,
    required VoidCallback onTap
  }){
    return ElementsOfDesign.buildTextField(
        controller: TextEditingController(text: toString(translate: true)),
        labelText: FieldsConstants.priceTypeHeadline,
        canEdit: canEdit,
        icon: FontAwesomeIcons.tengeSign,
        context: context,
        readOnly: true,
        onTap: onTap
    );
  }

  @override
  String toString({bool translate = false}) {
    switch (priceType) {
      case PriceTypeEnum.free:
        return !translate ? PriceTypeConstants.freeId : PriceTypeConstants.freeHeadline;
      case PriceTypeEnum.fixed:
        return !translate ? PriceTypeConstants.fixedId : PriceTypeConstants.fixeHeadline;
      case PriceTypeEnum.range:
        return !translate ? PriceTypeConstants.rangeId : PriceTypeConstants.rangeHeadline;
      default: return '';
    }
  }

  String getHumanViewPrice ({required String price}){

    // Функция преобразования цены из БД в человеческий вид

    switch (priceType) {

      case PriceTypeEnum.free: return PriceTypeConstants.freePrice;
      case PriceTypeEnum.fixed: return '$price ${PriceTypeConstants.tenge}';
      case PriceTypeEnum.range: {
        List<String> temp = price.split('-');
        return 'от ${temp[0]} ${PriceTypeConstants.tenge} - до ${temp[1]} ${PriceTypeConstants.tenge}';
      }
      default: return '';
    }
  }

  String getPriceStringForDb({required String fixedPrice, required String startPrice, required String endPrice}){
    switch (priceType){
      case PriceTypeEnum.free: return '';
      case PriceTypeEnum.fixed: return fixedPrice;
      case PriceTypeEnum.range: return '$startPrice-$endPrice';
      case PriceTypeEnum.notChosen: return '';
    }
  }

  String getRangePrices({
    bool isStart = true,
    required String price
  }){

    List<String> prices = price.split('-');

    if (isStart){
      return prices[0];
    } else {
      return prices[1];
    }
  }

  List<PriceType> getPriceTypesList(){
    return [
      PriceType(priceType: PriceTypeEnum.free),
      PriceType(priceType: PriceTypeEnum.fixed),
      PriceType(priceType: PriceTypeEnum.range),
    ];
  }

}