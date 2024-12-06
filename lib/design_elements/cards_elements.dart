import 'dart:io';
import 'package:flutter/material.dart';
import '../design/app_colors.dart';
import 'elements_of_design.dart';

class CardsElements{
  static Widget columnForCard({
    required BuildContext context,
    required Widget image,
    required Widget info,
  }){
    return Column(
      children: [
        image,
        info
      ],
    );
  }

  static Widget rowForCard({
    required BuildContext context,
    required Widget image,
    required Widget info,
  }){
    return Row(
      children: [
        image,
        Expanded(child: info),
      ],
    );
  }

  static Widget getCard({
    required BuildContext context,
    required VoidCallback onTap,
    required String imageUrl,
    required Widget widget,
    Widget? leftTopTag,
    Widget? leftBottomTag,
    Widget? rightTopTag,
    Widget? rightBottomTag,

  }){

    Widget image = ElementsOfDesign.imageWithTags(
      imageUrl: imageUrl,
      width: Platform.isWindows || Platform.isMacOS ? 250 : double.infinity,
      height: 250,
      leftTopTag: leftTopTag,
      rightBottomTag: rightBottomTag,
      rightTopTag: rightTopTag,
      leftBottomTag: leftBottomTag
    );

    Widget info = Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: widget),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        child: Card(
            color: AppColors.greyOnBackground,
            clipBehavior: Clip.antiAlias,
            child: Platform.isWindows || Platform.isMacOS ? rowForCard(
                context: context,
                image: image,
                info: info
            ) : columnForCard(
                context: context,
                image: image,
                info: info
            )
        ),
      ),
    );
  }

}
