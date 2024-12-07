import 'dart:io';
import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/ads/ads_enums_class/status_picker.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/ads/ads_page.dart';
import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/constants/date_constants.dart';
import 'package:admin_dvij/constants/users_constants.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/admins_constants.dart';
import '../constants/system_constants.dart';
import '../database/image_picker.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/elements_of_design.dart';

class AdViewCreateEditScreen extends StatefulWidget {
  final AdClass? ad;
  final int indexTabPage;
  const AdViewCreateEditScreen({required this.indexTabPage, this.ad, Key? key}) : super(key: key);

  @override
  State<AdViewCreateEditScreen> createState() => _AdViewCreateEditScreenState();
}

class _AdViewCreateEditScreenState extends State<AdViewCreateEditScreen> {

  SystemMethodsClass sm = SystemMethodsClass();

  final ImagePickerService imagePickerService = ImagePickerService();

  AdsList adList = AdsList();

  bool loading = false;
  bool saving = false;
  bool deleting = false;
  bool edit = false;
  bool canEdit = false;

  bool hasChanges = false;

  AdClass ad = AdClass.empty();

  DateTime chosenStartDate = DateTime(2100);
  DateTime chosenEndDate = DateTime(2100);
  DateTime chosenOrderDate = DateTime.now();
  AdLocation chosenLocation = AdLocation.fromString(text: '');
  AdIndex chosenIndex = AdIndex.fromString(text: '');
  AdStatus chosenStatus = AdStatus.fromString(text: '');

  File? _imageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _adIndexController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();
  final TextEditingController _clientWhatsappController = TextEditingController();
  final TextEditingController _orderDateController = TextEditingController();

  void resetChosenOptions(){
    setState(() {
      chosenStartDate = DateTime(2100);
      chosenEndDate = DateTime(2100);
      chosenOrderDate = DateTime.now();
      chosenLocation = AdLocation.fromString(text: '');
      chosenIndex = AdIndex.fromString(text: '');
      chosenStatus = AdStatus.fromString(text: '');
      _imageFile = null;
    });
  }

  void setControllersFields (){

    _nameController.text = ad.headline;
    _descController.text = ad.desc;
    _urlController.text = ad.url;
    _imageUrlController.text = ad.imageUrl;
    _startDateController.text = ad.startDate.year == 2100 ? DateConstants.noDate : sm.formatDateTimeToHumanView(ad.startDate);
    _endDateController.text = ad.endDate.year == 2100 ? DateConstants.noDate : sm.formatDateTimeToHumanView(ad.endDate);
    _orderDateController.text = sm.formatDateTimeToHumanView(ad.endDate);
    _locationController.text = ad.location.toString(translate: true);
    _adIndexController.text = ad.adIndex.toString(translate: true);
    _statusController.text = ad.status.toString(translate: true);
    _clientNameController.text = ad.clientName;
    _clientPhoneController.text = ad.clientPhone;
    _clientWhatsappController.text = ad.clientWhatsapp;
  }

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization() async{

    setState(() {
      loading = true;
    });

    if (widget.ad != null) {
      ad = adList.getEntityFromList(widget.ad!.id);
    }

    resetChosenOptions();
    setControllersFields();

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 600; // Условие для мобильной версии

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ad != null ? AdsConstants.editAd : AdsConstants.createAd),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад с разным списком сущностей

        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: navigateToAdsListScreen,
        ),

        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),
        ],
      ),

      body: Stack(
        children: [
          if (saving) LoadingScreen(loadingText: widget.ad == null ? AdsConstants.createAdProcess : AdsConstants.createAdProcess,)
          else if (loading) const LoadingScreen()
          else if (deleting) const LoadingScreen(loadingText: AdsConstants.deleteAdProcess,)
          else SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: sm.getScreenWidth(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              ElementsOfDesign.getImageFromUrlOrPickedImage(url: ad.imageUrl, imageFile: _imageFile),
                              if (canEdit) Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Card(
                                    color: AppColors.greyBackground,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElementsOfDesign.linkButton(
                                          method: () async {
                                            await _pickImage();
                                          },
                                          text: 'Редактировать изображение',
                                          context: context
                                      ),

                                    ),
                                  ),
                              ),
                            ],
                          )
                        ),

                        const SizedBox(height: 20,),


                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile,
                            [

                              ElementsOfDesign.buildTextField(
                                controller: _statusController,
                                labelText: AdsConstants.statusAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.spinner,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await statusPopup();
                                },
                              ),

                              ElementsOfDesign.buildTextField(
                                controller: _orderDateController,
                                labelText: AdsConstants.orderDateAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.calendarDay,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  //await _selectDate(context);
                                },
                              ),

                            ]
                        ),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile,
                            [
                              ElementsOfDesign.buildTextField(
                                controller: _locationController,
                                labelText: AdsConstants.locationAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.locationPin,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  //await showCityTwoPopup();
                                },
                              ),
                              ElementsOfDesign.buildTextField(
                                controller: _adIndexController,
                                labelText: AdsConstants.slotAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.hashtag,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  //await showCityTwoPopup();
                                },
                              ),

                            ]
                        ),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile,
                            [
                              ElementsOfDesign.buildTextField(
                                controller: _startDateController,
                                labelText: AdsConstants.startDateAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.calendarPlus,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  //await _selectDate(context);
                                },
                              ),
                              ElementsOfDesign.buildTextField(
                                controller: _endDateController,
                                labelText: AdsConstants.endDateAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.calendarCheck,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  //await _selectDate(context);
                                },
                              ),

                            ]
                        ),

                        ElementsOfDesign.buildTextField(
                            controller: _nameController,
                            labelText: AdsConstants.headlineAdField,
                            canEdit: canEdit,
                            icon: FontAwesomeIcons.rectangleAd,
                            context: context
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildTextField(
                          controller: _descController,
                          labelText: AdsConstants.descAdField,
                          canEdit: canEdit,
                          icon: FontAwesomeIcons.fileLines,
                          context: context,
                          maxLines: null,
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildTextField(
                            controller: _urlController,
                            labelText: AdsConstants.urlAdField,
                            canEdit: canEdit,
                            icon: FontAwesomeIcons.link,
                            context: context
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildTextField(
                            controller: _clientNameController,
                            labelText: AdsConstants.clientNameAdField,
                            canEdit: canEdit,
                            icon: FontAwesomeIcons.person,
                            context: context
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile,
                            [

                              ElementsOfDesign.buildTextField(
                                  controller: _clientPhoneController,
                                  labelText: UserConstants.phone,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.phone,
                                  context: context
                              ),

                              ElementsOfDesign.buildTextField(
                                  controller: _clientWhatsappController,
                                  labelText: UserConstants.whatsapp,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.whatsapp,
                                  context: context
                              ),
                            ]
                        ),

                        if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                            isMobile,
                            [
                              ElementsOfDesign.customButton(
                                  method: (){
                                    setState(() async {
                                      await saveAd();
                                    });

                                  },
                                  textOnButton: ButtonsConstants.save,
                                  context: context
                              ),

                              ElementsOfDesign.customButton(
                                  method: (){
                                    resetChosenOptions();
                                    setState(() {
                                      canEdit = false;
                                    });

                                  },
                                  textOnButton: ButtonsConstants.cancel,
                                  context: context,
                                  buttonState: ButtonStateEnum.secondary
                              ),
                            ]
                        ),

                      ],
                    ),
                      ),
                ],
              ),
            ),
          )
        ],
      ),

    );
  }

  Future<void> statusPopup() async{
    dynamic result = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const StatusPicker();
      },
    );

    if (result != null) {

      setState(() {
        chosenStatus = result;
        _statusController.text = chosenStatus.toString(translate: true);
      });

    }

  }

  /*Future<void> _selectOrderDate(BuildContext context) async {
    DateTime initial = ad.ordersDate. != 2100 ? editUserAdmin.birthDate : DateTime.now();
    if (selectedBirthDateOnEdit.year != 2100) initial = selectedBirthDateOnEdit;

    final DateTime? picked = await showDatePicker(

      locale: const Locale('ru'), // Локализация (например, русский)
      context: context,
      initialDate: initial,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      helpText: DateConstants.chosenDate,
      cancelText: ButtonsConstants.cancel,
      confirmText: ButtonsConstants.ok,
      keyboardType: TextInputType.datetime,
      initialEntryMode: DatePickerEntryMode.inputOnly,
      fieldLabelText: DateConstants.yourBirthdayDate,


    );

    if (picked != null && picked != editUserAdmin.birthDate) {
      setState(() {
        selectedBirthDateOnEdit = picked;
        birthDateController.text = systemMethods.formatDateTimeToHumanView(selectedBirthDateOnEdit);
      });
    }

  }*/

  Future<void> _pickImage() async {

    final File? pickedImage = await imagePickerService.pickImage(ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
      });
    }
  }

  Future<void> saveAd() async{
    setState(() {
      saving = true;
    });

    setEditAdminBeforeSaving();

    if (checkStatus()){
      String publishResult = await ad.publishToDb(_imageFile);

      if (publishResult == SystemConstants.successConst) {
        _showSnackBar(AdsConstants.saveSuccess);
        await initialization();
        canEdit = false;
        resetChosenOptions();
        hasChanges = true;
      } else {
        _showSnackBar(publishResult);
      }
    }

    setState(() {
      saving = false;
    });
  }

  bool checkStatus(){
    if (ad.status.status == AdStatusEnum.active || chosenStatus.status == AdStatusEnum.active){
      if (ad.adIndex.index == AdIndexEnum.notChosen){
        _showSnackBar('Для активации рекламы нужно выбрать слот');
        return false;
      }

      if (ad.location.location == AdLocationEnum.notChosen){
        _showSnackBar('Для активации рекламы нужно выбрать место');
        return false;
      }

      if (ad.startDate.year == 2100){
        _showSnackBar('Для активации рекламы нужно выбрать дату начала показа');
        return false;
      }

      if (ad.endDate.year == 2100){
        _showSnackBar('Для активации рекламы нужно выбрать дату завершения показа');
        return false;
      }

      if (ad.ordersDate.year == 2100){
        _showSnackBar('Для активации рекламы нужно выбрать дату создания рекламы');
        return false;
      }

      if (ad.imageUrl == SystemConstants.defaultAdImagePath && _imageFile == null) {
        _showSnackBar('Для активации рекламы нужно выбрать изображение');
        return false;
      }

    }

    if (ad.clientName.isEmpty || ad.clientPhone.isEmpty){
      _showSnackBar('Для сохранения рекламы нужно указать данные заказчика');
      return false;
    }

    if (ad.headline.isEmpty || ad.desc.isEmpty) {
      _showSnackBar('Для сохранения рекламы нужно заполнить заголовок и описание рекламы');
      return false;
    }

    return true;

  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void setEditAdminBeforeSaving(){

    ad.status = chosenStatus;
    ad.url = _urlController.text;
    ad.ordersDate = chosenOrderDate;
    ad.startDate = chosenStartDate;
    ad.endDate = chosenEndDate;
    ad.desc = _descController.text;
    ad.headline = _nameController.text;
    ad.location = chosenLocation;
    if (chosenIndex.index != AdIndexEnum.notChosen){
      ad.adIndex = chosenIndex;
    }

    ad.clientName = _clientNameController.text;
    ad.clientPhone = _clientPhoneController.text;
    ad.clientWhatsapp = _clientWhatsappController.text;

  }

  void navigateToAdsListScreen() {

    if (hasChanges){
      sm.popBackToPreviousPageWithResult(context: context, result: ad);
    } else {
      // Метод возвращения на экран списка без результата
      sm.pushAndDeletePreviousPages(context: context, page: AdsPage(initialIndex: widget.indexTabPage));
    }

  }

}
