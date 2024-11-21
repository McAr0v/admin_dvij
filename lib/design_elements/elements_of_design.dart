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

    ElementsOfDesign elements = ElementsOfDesign();

    return TextButton(
        onPressed: method,
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    return elements._switchColorButton(buttonState);
                    },
            ),
            side: WidgetStateProperty.resolveWith<BorderSide?>(
                  (Set<WidgetState> states) {
                    return BorderSide(color: elements._switchColorButton(buttonState));
                    },
            ),
        ),

        child: Text(
          textOnButton,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: elements._switchTextOnButtonColor(buttonState)),
        )
    );
  }

  Color _switchColorButton(ButtonStateEnum state){
    switch (state) {
      case ButtonStateEnum.primary: return AppColors.brandColor;
      case ButtonStateEnum.secondary: return AppColors.white;
    }
  }

  Color _switchTextOnButtonColor(ButtonStateEnum state){
    switch (state) {
      case ButtonStateEnum.primary: return AppColors.greyOnBackground;
      case ButtonStateEnum.secondary: return AppColors.greyOnBackground;
    }
  }

}