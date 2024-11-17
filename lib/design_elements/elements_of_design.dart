import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:flutter/material.dart';

import '../design/app_colors.dart';

class ElementsOfDesign {

  static ListTile drawerListElement(
      String text,
      IconData icon,
      dynamic page,
      BuildContext context,
      ){
    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium,),
      leading: Icon(icon, size: 15,),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  static TextButton customButton ({
      required VoidCallback method,
      required String textOnButton,
      required BuildContext context,
      ButtonStateEnum buttonState = ButtonStateEnum.primary
      }){

    Color buttonColor = AppColors.brandColor;
    Color textColor = AppColors.greyOnBackground;

    return TextButton(
        onPressed: method,
        //style: ButtonStyle(backgroundColor: ),
        child: Text(textOnButton, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.greyOnBackground),)
    );
  }

  Color _switchColorButton(ButtonStateEnum state){
    switch (state) {
      case ButtonStateEnum.primary: return AppColors.brandColor;
      case ButtonStateEnum.secondary: return AppColors.greyText;
    }
  }

}