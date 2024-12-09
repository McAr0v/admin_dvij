import 'dart:io';
import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/ads/ads_enums_class/location_picker.dart';
import 'package:admin_dvij/ads/ads_enums_class/slot_picker.dart';
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

  // Переменные для сохранения изначальных даты рекламы
  // Для исправления ошибки когда диапазон дат уже занят
  // и отображаются выбранные даты
  AdClass firstTempAd = AdClass.empty();

  AdClass ad = AdClass.empty();

  DateTime chosenStartDate = DateTime(2100);
  DateTime chosenEndDate = DateTime(2100);
  AdLocation chosenLocation = AdLocation.fromString(text: '');
  AdIndex chosenIndex = AdIndex.fromString(text: '');
  AdStatus chosenStatus = AdStatus(status: AdStatusEnum.notChosen);



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
      chosenLocation = AdLocation.fromString(text: '');
      chosenIndex = AdIndex.fromString(text: '');
      chosenStatus = AdStatus(status: AdStatusEnum.notChosen);
      _imageFile = null;
    });

    setControllersFields();

  }

  void setControllersFields (){

    _nameController.text = ad.headline;
    _descController.text = ad.desc;
    _urlController.text = ad.url;
    _imageUrlController.text = ad.imageUrl;
    _startDateController.text = ad.startDate.year == 2100 ? DateConstants.noDate : sm.formatDateTimeToHumanView(ad.startDate);
    _endDateController.text = ad.endDate.year == 2100 ? DateConstants.noDate : sm.formatDateTimeToHumanView(ad.endDate);
    _orderDateController.text = sm.formatDateTimeToHumanView(ad.ordersDate);
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

      // Сохраняем в переменные данные дат по умолчанию
      // Для исправления ошибки если диапазон дат попадает в уже занятый
      firstTempAd = ad;
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
                    width: sm.getScreenWidth(neededWidth: 1000),
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
                                controller: _locationController,
                                labelText: AdsConstants.locationAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.locationPin,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await locationPopup();
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
                                  await slotPopup();
                                },
                              ),



                            ]
                        ),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile,
                            [
                              ElementsOfDesign.buildTextField(
                                controller: _orderDateController,
                                labelText: AdsConstants.orderDateAdField,
                                canEdit: false,
                                icon: FontAwesomeIcons.calendarDay,
                                context: context,
                                readOnly: true,
                              ),

                              ElementsOfDesign.buildTextField(
                                controller: _startDateController,
                                labelText: AdsConstants.startDateAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.calendarPlus,
                                context: context,
                                readOnly: true,
                                onTap: () async {
                                  await _selectStartDate(context);
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
                                  await _selectEndDate(context);
                                },
                              ),

                            ]
                        ),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile,
                            [
                              ElementsOfDesign.buildTextField(
                                  controller: _clientNameController,
                                  labelText: AdsConstants.clientNameAdField,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.person,
                                  context: context
                              ),

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



                        if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                            isMobile,
                            [
                              ElementsOfDesign.customButton(
                                  method: () async {
                                    await saveAd();

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

    dynamic result = await sm.getPopup(context: context, page: const StatusPicker());

    if (result != null) {

      setState(() {
        chosenStatus = result;
        _statusController.text = chosenStatus.toString(translate: true);
      });

    }

  }

  Future<void> locationPopup() async{
    dynamic result = await sm.getPopup(context: context, page: const LocationPicker());

    if (result != null){
      setState(() {
        chosenLocation = result;
        _locationController.text = chosenLocation.toString(translate: true);
      });
    }

  }

  Future<void> slotPopup() async{
    dynamic result = await sm.getPopup(context: context, page: const SlotPicker());

    if (result != null){
      setState(() {
        chosenIndex = result;
        _adIndexController.text = chosenIndex.toString(translate: true);
      });
    }

  }

  Future<void> _selectStartDate(BuildContext context) async {

    DateTime currentDate = DateTime.now();

    if (chosenStartDate.year == 2100 && ad.startDate.year != 2100){
      currentDate = ad.startDate;
    } else if (chosenStartDate.year != 2100 && ad.startDate.year != 2100){
      currentDate = chosenStartDate;
    }

    final DateTime? picked = await sm.dataPicker(
        context: context,
        label: 'Первый день показов',
        firstDate: DateTime(2024),
        lastDate: DateTime(2050),
        currentDate: currentDate,
        needCalendar: true
    );

    if (picked != null) {
      setState(() {
        chosenStartDate = picked;
        _startDateController.text = sm.formatDateTimeToHumanView(chosenStartDate);
      });
    }

  }

  Future<void> _selectEndDate(BuildContext context) async {

    DateTime currentDate = DateTime.now();

    if (chosenEndDate.year == 2100 && ad.endDate.year != 2100){
      currentDate = ad.endDate;
    } else if (chosenEndDate.year != 2100 && ad.endDate.year != 2100){
      currentDate = chosenEndDate;
    }

    final DateTime? picked = await sm.dataPicker(
        context: context,
        label: 'Последний день показов',
        firstDate: DateTime(2024),
        lastDate: DateTime(2050),
        currentDate: currentDate,
        needCalendar: true
    );

    if (picked != null) {
      setState(() {
        chosenEndDate = picked;
        _endDateController.text = sm.formatDateTimeToHumanView(chosenEndDate);
      });
    }

  }

  Future<void> _pickImage() async {

    // TODO - сделать подборщика картинок на macOs

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

    setAdBeforeSaving();

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
    } else {
      // Исправляем ошибку меняющихся дат если диапазон занят
      ad = firstTempAd;
    }

    setState(() {
      saving = false;
    });
  }

  bool checkStatus(){

    AdsList adsList = AdsList();

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

      if (ad.imageUrl == SystemConstants.defaultAdImagePath && _imageFile == null) {
        _showSnackBar('Для активации рекламы нужно выбрать изображение');
        return false;
      }

      if (!adsList.checkActiveAd(ad)){
        _showSnackBar('Этот слот на указанные даты уже занят');
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

  void setAdBeforeSaving(){

    if (chosenStatus.status != AdStatusEnum.notChosen){
      ad.status = chosenStatus;
    }

    if (chosenLocation.location != AdLocationEnum.notChosen){
      ad.location = chosenLocation;
    }

    if (chosenStartDate.year != 2100){
      ad.startDate = chosenStartDate;
    }

    if (chosenEndDate.year != 2100){
      ad.endDate = chosenEndDate;
    }

    if (chosenIndex.index != AdIndexEnum.notChosen){
      ad.adIndex = chosenIndex;
    }

    ad.url = _urlController.text;
    ad.desc = _descController.text;
    ad.headline = _nameController.text;
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
