import 'dart:io';

import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_location.dart';
import 'package:admin_dvij/ads/ads_enums_class/ad_status.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/ads/ads_page.dart';
import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:admin_dvij/constants/date_constants.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admins_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  AdsList adList = AdsList();

  bool loading = false;
  bool saving = false;
  bool deleting = false;
  bool edit = false;
  bool canEdit = false;

  AdClass ad = AdClass.empty();

  DateTime chosenStartDate = DateTime(2100);
  DateTime chosenEndDate = DateTime(2100);
  AdLocation chosenLocation = AdLocation.fromString(text: '');
  AdIndex chosenIndex = AdIndex.fromString(text: '');
  AdStatus chosenStatus = AdStatus.fromString(text: '');

  //File? _imageFile;

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

  void resetChosenOptions(){
    setState(() {
      chosenStartDate = DateTime(2100);
      chosenEndDate = DateTime(2100);
      chosenLocation = AdLocation.fromString(text: '');
      chosenIndex = AdIndex.fromString(text: '');
      chosenStatus = AdStatus.fromString(text: '');
      //_imageFile = null;
    });
  }

  void setControllersFields (){

    _nameController.text = ad.headline;
    _descController.text = ad.desc;
    _urlController.text = ad.url;
    _imageUrlController.text = ad.imageUrl;
    _startDateController.text = ad.startDate.year == 2100 ? DateConstants.noDate : sm.formatDateTimeToHumanView(ad.startDate);
    _endDateController.text = ad.endDate.year == 2100 ? DateConstants.noDate : sm.formatDateTimeToHumanView(ad.endDate);
    _locationController.text = ad.location.toString(translate: true);
    _adIndexController.text = ad.adIndex.toString(translate: true);
    _statusController.text = ad.adIndex.toString(translate: true);
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
            child: Column(
              children: [
                Container(
                  width: sm.getScreenWidth(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile,
                          [
                            ElementsOfDesign.buildTextField(
                                controller: _nameController,
                                labelText: AdsConstants.headlineAdField,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.rectangleAd,
                                context: context
                            ),
                            ElementsOfDesign.buildTextField(
                              controller: _statusController,
                              labelText: AdsConstants.statusAdField,
                              canEdit: canEdit,
                              icon: FontAwesomeIcons.ellipsisVertical,
                              context: context,
                              readOnly: true,
                              onTap: () async {
                                //await showCityTwoPopup();
                              },
                            ),

                          ]
                      ),
                    ],
                  ),
                    ),
              ],
            ),
          )
        ],
      ),

    );
  }



  void navigateToAdsListScreen() {
    // Метод возвращения на экран списка без результата
    sm.pushAndDeletePreviousPages(context: context, page: AdsPage(initialIndex: widget.indexTabPage));
  }

}
