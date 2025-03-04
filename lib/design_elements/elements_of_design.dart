import 'dart:io';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';

class ElementsOfDesign {

  static ListTile drawerListElement(
      String text,
      IconData icon,
      dynamic page,
      BuildContext context,
      ){

    SystemMethodsClass sm = SystemMethodsClass();

    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium,),
      leading: Icon(icon, size: 15,),
      onTap: () {
        Navigator.pop(context);
        sm.pushAndDeletePreviousPages(context: context, page: page);
      },
    );
  }

  static Widget linkButton({
    required VoidCallback method,
    required String text,
    required BuildContext context,
    Color textColor = AppColors.brandColor
  }){
    return GestureDetector(
      onTap: method,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: textColor, decoration: TextDecoration.underline,),
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

  static Widget buildAdaptiveRow({
    required bool isMobile,
    required List<Widget> children,
    double bottomPadding = 20
      }) {
    if (isMobile) {
      return Column(
        children: children
            .map((child) => Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: child,
        ))
            .toList(),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
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

  static Widget checkBox({
    required String text,
    required bool isChecked,
    required ValueChanged<bool?> onChanged,
    required BuildContext context,
    bool canEdit = true
  }){
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: canEdit ? onChanged : null,
        ),
        const SizedBox(width: 10,),
        Text(text, style: Theme.of(context).textTheme.bodyMedium,),
      ],
    );
  }

  static Widget imageForEditViewScreen({
    required BuildContext context,
    required String imageUrl,
    required File? imageFile,
    required bool canEdit,
    required VoidCallback onEditImage

  }){
    return Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [

            getImageFromUrlOrPickedImage(url: imageUrl, imageFile: imageFile),

            if (canEdit) Positioned(
              top: 10,
              left: 10,
              child: Card(
                color: AppColors.greyBackground,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElementsOfDesign.linkButton(
                      method: onEditImage,
                      text: ButtonsConstants.changePhoto,
                      context: context
                  ),

                ),
              ),
            ),
          ],
        )
    );
  }

  static Widget getImageFromUrlOrPickedImage({
    File? imageFile,
    required String url
  }){
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: imageFile != null
          ? getImageFromFile(image: imageFile)
          : getImageFromUrl(imageUrl: url),
    );
  }

  static Widget getImageFromFile({ required File image}){
    return Image.file(
      image,
      fit: BoxFit.cover,
      width: 100,
      height: 100,
    );
  }

  static Widget getImageFromFileWithXButton({ 
    required File image,
    required VoidCallback onTap
  }){
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Image.file(
            image,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
          ),

          Positioned(
            top: 5.0,
            left: 5.0,
            child: GestureDetector(
              onTap: onTap,
              child: const Card(
                margin: EdgeInsets.zero,
                color: AppColors.greyOnBackground,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Icon(FontAwesomeIcons.x, size: 8,),
                  )
              ),
            ),
          ),
          
        ],
      ),
    );
  }
  

  static getAvatar({required String url, double size = 40}) {
    return CircleAvatar(
      radius: size,
      backgroundColor: AppColors.greyOnBackground,
      child: ClipOval(
        child: getImageFromUrl(imageUrl: url)
      ),
    );
  }

  static Widget getImageFromUrl ({required String imageUrl}){
    return Image.network(
      imageUrl, // Ссылка на картинку
      height: 100,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child; // Показываем картинку, когда загрузка завершена
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                : null, // Показываем прогресс загрузки
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Text(SystemConstants.errorLoad), // Показываем текст при ошибке загрузки
        );
      },
      fit: BoxFit.cover, // Настройка масштабирования
    );
  }

  static Widget imageWithTags({
    required String imageUrl,
    required double width,
    required double height,
    Widget? leftTopTag,
    Widget? rightTopTag,
    Widget? leftBottomTag,
    Widget? rightBottomTag,
    bool needMargin = true

  }){
    return SizedBox(
      width: width, // Растягиваем картинку на всю ширину
      height: height,
      child: Card(
        margin: needMargin ? (Platform.isMacOS || Platform.isWindows ? const EdgeInsets.fromLTRB(10, 10, 10, 10) : const EdgeInsets.fromLTRB(10, 10, 10, 0)) : const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity, // Растягиваем картинку на всю ширину
              height: height,
              child: getImageFromUrl(imageUrl: imageUrl),
            ),

            if (leftTopTag != null) Positioned(
              top: 10.0,
              left: 10.0,
              child: leftTopTag,
            ),
            if (leftBottomTag != null) Positioned(
              bottom: 10.0,
              left: 10.0,
              child: leftBottomTag,
            ),
            if (rightTopTag != null) Positioned(
              top: 10.0,
              right: 10.0,
              child: rightTopTag,
            ),
            if (rightBottomTag != null) Positioned(
              right: 10.0,
              bottom: 10.0,
              child: rightBottomTag,
            ),
          ],
        ),
      ),
    );
  }


  static Tab getTabWithIcon({
    required IconData icon,
    required String text
  }){
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 15,),
          const SizedBox(width: 10,),

          if (Platform.isAndroid || Platform.isIOS)
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

          if (Platform.isWindows || Platform.isMacOS)
            Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),

        ],
      ),
    );
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool canEdit,
    required IconData? icon,
    required BuildContext context,
    int? maxLines = 1,
    VoidCallback? onTap,
    VoidCallback? onIconTap,
    bool readOnly = false,
    TextInputType textInputType = TextInputType.text
  }) {
    return TextField(
      style: Theme.of(context).textTheme.bodyMedium,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: icon != null
            ? GestureDetector(
              onTap: onIconTap,
              child: Icon(
                        icon,
                        size: 18,
                      ),
            )
            : null,
      ),
      enabled: canEdit,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      keyboardType: textInputType,
    );
  }

  static Widget buildTextFieldWithoutController({
    required String controllerText,
    required String labelText,
    required bool canEdit,
    required IconData icon,
    required BuildContext context,
    int? maxLines = 1,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {

    TextEditingController controller = TextEditingController();
    controller.text = controllerText;

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
      maxLines: maxLines,
    );
  }

  static Widget getTag({
    required BuildContext context,
    Color color = AppColors.brandColor,
    required String text,
    IconData? icon,
    Color textColor = AppColors.greyOnBackground
  }){
    return IntrinsicWidth(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              if (icon != null) Icon(icon, color: textColor, size: 15,),
              if (icon != null) const SizedBox(width: 10,),
              Text(
                text,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget cleanButton ({required VoidCallback onClean}) {

    return IconButton(
      onPressed: onClean,
      icon: const Icon(FontAwesomeIcons.x, size: 15, color: AppColors.attentionRed,),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            return AppColors.greyBackground;
          },
        ),
      ),
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

  static Container getSearchBar({
    required BuildContext context,
    required TextEditingController textController,
    TextInputType textInputType = TextInputType.text,
    required String labelText,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required VoidCallback onClean
  }){
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [

          // Форма ввода названия
          Expanded(
            child: TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              keyboardType: textInputType,
              controller: textController,
              decoration: InputDecoration(
                labelText: labelText,
                prefixIcon: Icon(
                    icon,
                  size: 18,
                ),
              ),
              onChanged: onChanged
            ),
          ),

          if (textController.text.isNotEmpty) const SizedBox(width: 20,),

          // Кнопка сброса
          if (textController.text.isNotEmpty) IconButton(
              onPressed: onClean,
              icon: const Icon(
                FontAwesomeIcons.x,
                size: 15,
              )
          ),
        ],
      ),
    );
  }

  static void showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // Закрытие при нажатии вне окна
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // Убираем отступы
          backgroundColor: Colors.black.withOpacity(0.8), // Затемнение фона
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  maxScale: 3.0, // Позволяет увеличивать изображение
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain, // Подгоняем изображение
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          "Ошибка загрузки",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: Platform.isMacOS || Platform.isWindows ? 40 : 50,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: Platform.isMacOS || Platform.isWindows ? 20 : 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}