import 'package:admin_dvij/ads/ads_enums_class/ad_index.dart';
import 'package:admin_dvij/ads/ads_enums_class/location_picker.dart';
import 'package:admin_dvij/ads/ads_enums_class/slot_picker.dart';
import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:admin_dvij/design_elements/button_state_enum.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'ads_enums_class/ad_location.dart';

class FilterPicker extends StatefulWidget {
  final AdIndex slot;
  final AdLocation location;

  const FilterPicker({required this.location, required this.slot, Key? key}) : super(key: key);

  @override
  State<FilterPicker> createState() => _FilterPickerState();
}

class _FilterPickerState extends State<FilterPicker> {

  SystemMethodsClass systemMethodsClass = SystemMethodsClass();

  AdLocation chosenLocation = AdLocation(location: AdLocationEnum.notChosen);
  AdIndex chosenIndex = AdIndex(index: AdIndexEnum.notChosen);

  TextEditingController locationController = TextEditingController();
  TextEditingController slotController = TextEditingController();

  @override
  void initState() {

    chosenLocation = widget.location;
    chosenIndex = widget.slot;

    locationController.text = chosenLocation.toString(translate: true);
    slotController.text = chosenIndex.toString(translate: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Expanded(child: Text('Фильтр', style: Theme.of(context).textTheme.titleLarge,),),
                  const SizedBox(width: 20,),
                  if (chosenLocation.location != AdLocationEnum.notChosen || chosenIndex.index != AdIndexEnum.notChosen)
                    ElementsOfDesign.linkButton(
                        method: (){
                          setState(() {
                            chosenLocation = AdLocation(location: AdLocationEnum.notChosen);
                            chosenIndex = AdIndex(index: AdIndexEnum.notChosen);
                            locationController.text = chosenLocation.toString(translate: true);
                            slotController.text = chosenIndex.toString(translate: true);
                          });
                        },
                        text: 'Сбросить настройки',
                        context: context
                    )
                ],
              ),

              const SizedBox(height: 20,),

              ElementsOfDesign.buildTextField(
                  controller: locationController,
                  labelText: AdsConstants.locationAdField,
                  canEdit: true,
                  icon: FontAwesomeIcons.locationPin,
                  context: context,
                  onTap: () async {
                    final result = await systemMethodsClass.getPopup(
                        context: context,
                        page: const LocationPicker()
                    );

                    if (result != null){
                      setState(() {
                        chosenLocation = result;
                        locationController.text = chosenLocation.toString(translate: true);
                      });

                    }
                  },
                readOnly: true
              ),

              const SizedBox(height: 20,),

              ElementsOfDesign.buildTextField(
                  controller: slotController,
                  labelText: AdsConstants.slotAdField,
                  canEdit: true,
                  icon: FontAwesomeIcons.hashtag,
                  context: context,
                  onTap: () async {
                    final result = await systemMethodsClass.getPopup(
                        context: context,
                        page: const SlotPicker()
                    );

                    if (result != null){
                      setState(() {
                        chosenIndex = result;
                        slotController.text = chosenIndex.toString(translate: true);
                      });

                    }
                  },
                  readOnly: true
              ),

              const SizedBox(height: 20,),

              Row(
                children: [
                  Expanded(
                    child: ElementsOfDesign.customButton(
                        method: (){
                          systemMethodsClass.popBackToPreviousPageWithResult(context: context, result: [chosenLocation, chosenIndex]);
                        },
                        textOnButton: ButtonsConstants.ok,
                        context: context
                    )
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                      child: ElementsOfDesign.customButton(
                          method: (){
                            systemMethodsClass.popBackToPreviousPageWithResult(context: context, result: null);
                          },
                          textOnButton: ButtonsConstants.cancel,
                          context: context,
                        buttonState: ButtonStateEnum.secondary
                      )
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
}
