import 'dart:io';
import 'package:flutter/material.dart';
import '../design/app_colors.dart';
import 'elements_of_design.dart';

class CardsElements{
  Widget _columnForCard({
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

  Widget _rowForCard({
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

  Widget getCard({
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
            child: Platform.isWindows || Platform.isMacOS ? _rowForCard(
                context: context,
                image: image,
                info: info
            ) : _columnForCard(
                context: context,
                image: image,
                info: info
            )
        ),
      ),
    );
  }

}
