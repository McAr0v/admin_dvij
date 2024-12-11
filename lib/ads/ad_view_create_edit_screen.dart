import 'dart:io';
import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/ads/ads_enums_class/location_picker.dart';
import 'package:admin_dvij/ads/ads_enums_class/slot_picker.dart';
import 'package:admin_dvij/ads/ads_enums_class/status_picker.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
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
  bool canEdit = false;

  bool hasChanges = false;

  AdClass ad = AdClass.empty();

  DateTime chosenStartDate = DateTime(2100);
  DateTime chosenEndDate = DateTime(2100);
  AdLocation chosenLocation = AdLocation(location: AdLocationEnum.notChosen);
  AdIndex chosenIndex = AdIndex(index: AdIndexEnum.notChosen);
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
      chosenLocation = AdLocation(location: AdLocationEnum.notChosen);
      chosenIndex = AdIndex(index: AdIndexEnum.notChosen);
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

    if (widget.ad == null){
      canEdit = true;
    }

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
          if (widget.ad != null) IconButton(
            onPressed: () async {
              await deleteAd();
            },
            icon: const Icon(FontAwesomeIcons.trash, size: 15, color: AppColors.attentionRed,),
          ),

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
          if (saving) LoadingScreen(loadingText: widget.ad == null ? AdsConstants.createAdProcess : AdsConstants.editAdProcess,)
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
                                          text: ButtonsConstants.changePhoto,
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
        label: AdsConstants.startDateHeadline,
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
        label: AdsConstants.endDateHeadline,
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

    AdClass tempAd = setAdBeforeSaving();

    if (checkStatus(tempAd)){
      String publishResult = await tempAd.publishToDb(_imageFile);

      if (publishResult == SystemConstants.successConst) {
        _showSnackBar(AdsConstants.saveSuccess);

        await initialization();
        canEdit = false;
        resetChosenOptions();
        hasChanges = true;

        if (widget.ad == null){
          navigateToAdsListScreen();
        }

      } else {
        _showSnackBar(publishResult);
      }
    }

    setState(() {
      saving = false;
    });
  }

  Future<void> deleteAd() async{

    bool? result = await ElementsOfDesign.exitDialog(
        context,
        AdsConstants.deleteAdDesc,
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        AdsConstants.deleteAdHeadline,
    );

    if (result != null && result){
      setState(() {
        deleting = true;
      });

      String publishResult = await ad.deleteFromDb();

      if (publishResult == SystemConstants.successConst){

        hasChanges = true;
        _showSnackBar(AdsConstants.saveSuccess);
        navigateToAdsListScreen();

      } else {
        _showSnackBar(publishResult);
      }

      setState(() {
        saving = false;
      });
    }
  }

  bool checkStatus(AdClass tempAd){

    AdsList adsList = AdsList();

    if (tempAd.status.status == AdStatusEnum.active || chosenStatus.status == AdStatusEnum.active){
      if (tempAd.adIndex.index == AdIndexEnum.notChosen){
        _showSnackBar(AdsConstants.slotSelectionError);
        return false;
      }

      if (tempAd.location.location == AdLocationEnum.notChosen){
        _showSnackBar(AdsConstants.placeSelectionError);
        return false;
      }

      if (tempAd.startDate.year == 2100){
        _showSnackBar(AdsConstants.startDateSelectionError);
        return false;
      }

      if (tempAd.endDate.year == 2100){
        _showSnackBar(AdsConstants.endDateSelectionError);
        return false;
      }

      if (tempAd.imageUrl == SystemConstants.defaultAdImagePath && _imageFile == null) {
        _showSnackBar(AdsConstants.imageSelectionError);
        return false;
      }

      if (!adsList.checkActiveAd(tempAd)){
        _showSnackBar(AdsConstants.slotOccupiedError);
        return false;
      }

    }

    if (tempAd.clientName.isEmpty || tempAd.clientPhone.isEmpty){
      _showSnackBar(AdsConstants.customerDataError);
      return false;
    }

    if (tempAd.headline.isEmpty || tempAd.desc.isEmpty) {
      _showSnackBar(AdsConstants.titleAndDescriptionError);
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

  AdClass setAdBeforeSaving(){

    AdClass tempAd = AdClass.empty();

    if (chosenStatus.status != AdStatusEnum.notChosen){
      tempAd.status = chosenStatus;
    } else {
      tempAd.status = ad.status;
    }

    if (chosenLocation.location != AdLocationEnum.notChosen){
      tempAd.location = chosenLocation;
    } else {
      tempAd.location = ad.location;
    }

    if (chosenStartDate.year != 2100){
      tempAd.startDate = chosenStartDate;
    } else {
      tempAd.startDate = ad.startDate;
    }

    if (chosenEndDate.year != 2100){
      tempAd.endDate = chosenEndDate;
    } else {
      tempAd.endDate = ad.endDate;
    }

    if (chosenIndex.index != AdIndexEnum.notChosen){
      tempAd.adIndex = chosenIndex;
    } else {
      tempAd.adIndex = ad.adIndex;
    }

    tempAd.url = _urlController.text;
    tempAd.desc = _descController.text;
    tempAd.headline = _nameController.text;
    tempAd.clientName = _clientNameController.text;
    tempAd.clientPhone = _clientPhoneController.text;
    tempAd.clientWhatsapp = _clientWhatsappController.text;
    tempAd.id = ad.id;
    tempAd.imageUrl = ad.imageUrl;
    tempAd.ordersDate = ad.ordersDate;

    return tempAd;

  }

  void navigateToAdsListScreen() {
    sm.popBackToPreviousPageWithResult(context: context, result: ad);
  }

}
