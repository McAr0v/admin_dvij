import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:flutter/material.dart';
import '../constants/system_constants.dart';
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

  static Widget linkButton({
    required VoidCallback method,
    required String text,
    required BuildContext context,
  }){
    return GestureDetector(
      onTap: method,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.brandColor, decoration: TextDecoration.underline,),
      ),
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

  static Widget buildAdaptiveRow(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(
        children: children
            .map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: child,
        ))
            .toList(),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i < children.length - 1) const SizedBox(width: 20), // Отступ только между элементами
            ],
          ],
        ),
      );
    }
  }

  static getAvatar({required String url, double size = 40}) {
    return CircleAvatar(
      radius: size,
      backgroundColor: AppColors.greyOnBackground,
      child: ClipOval(
        child: FadeInImage(
          placeholder: const AssetImage(SystemConstants.defaultImagePath),
          image: NetworkImage(url),
          fit: BoxFit.fill,
          width: 100,
          height: 100,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              SystemConstants.defaultImagePath, // Изображение ошибки
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            );
          },
        ),
      ),
    );
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool canEdit,
    required IconData icon,
    required BuildContext context,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextField(
      style: Theme.of(context).textTheme.bodyMedium,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, size: 18,),
      ),
      enabled: canEdit,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  static Future<bool?> exitDialog(BuildContext context, String message, String confirmText, String cancelText, String headline) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          buttonPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          contentPadding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
          backgroundColor: AppColors.greyOnBackground,
          actionsPadding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
          titlePadding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          title: Text(
            headline,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          actionsAlignment: MainAxisAlignment.end,

          actions: [

            GestureDetector(
              onTap: (){
                Navigator.of(context).pop(false);
              },
              child: Text(cancelText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.attentionRed),),
            ),

            GestureDetector(
              onTap: (){
                Navigator.of(context).pop(true);
              },
              child: Text(confirmText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green)),
            )
          ],
        );
      },
    );
  }



}