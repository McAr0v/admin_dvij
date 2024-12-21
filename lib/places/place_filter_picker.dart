import 'package:admin_dvij/categories/place_categories/place_category.dart';
import 'package:admin_dvij/categories/place_categories/place_category_picker.dart';
import 'package:admin_dvij/constants/filter_constants.dart';
import 'package:admin_dvij/constants/places_constants.dart';
import 'package:admin_dvij/design/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../design_elements/button_state_enum.dart';
import '../design_elements/elements_of_design.dart';
import '../system_methods/system_methods_class.dart';

class PlaceFilterPicker extends StatefulWidget {
  final PlaceCategory placeCategory;
  final bool haveEvents;
  final bool havePromos;

  const PlaceFilterPicker({
    required this.placeCategory,
    required this.havePromos,
    required this.haveEvents,
    super.key
  });

  @override
  State<PlaceFilterPicker> createState() => _PlaceFilterPickerState();
}

class _PlaceFilterPickerState extends State<PlaceFilterPicker> {

  SystemMethodsClass systemMethodsClass = SystemMethodsClass();
  TextEditingController categoryController = TextEditingController();

  PlaceCategory chosenCategory = PlaceCategory.empty();
  bool chosenHaveEvents = false;
  bool chosenHavePromos = false;

  @override
  void initState() {

    chosenCategory = widget.placeCategory;
    chosenHaveEvents = widget.haveEvents;
    chosenHavePromos = widget.havePromos;

    categoryController.text = chosenCategory.name.isNotEmpty? chosenCategory.name : PlacesConstants.chooseCategoryPlace;

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
                  Expanded(child: Text(FilterConstants.filterName, style: Theme.of(context).textTheme.titleLarge,),),
                  const SizedBox(width: 20,),
                  if (chosenCategory.name.isNotEmpty || chosenHavePromos || chosenHaveEvents)
                    ElementsOfDesign.linkButton(
                        method: (){
                          setState(() {
                            chosenCategory = PlaceCategory.empty();
                            categoryController.text = chosenCategory.name.isNotEmpty? chosenCategory.name : PlacesConstants.chooseCategoryPlace;

                            chosenHaveEvents = false;
                            chosenHavePromos = false;

                          });
                        },
                        text: FilterConstants.clearFilter,
                        context: context
                    )
                ],
              ),

              const SizedBox(height: 20,),

              ElementsOfDesign.buildTextField(
                  controller: categoryController,
                  labelText: PlacesConstants.categoryPlace,
                  canEdit: true,
                  icon: FontAwesomeIcons.tag,
                  context: context,
                  onTap: () async {
                    final result = await systemMethodsClass.getPopup(
                        context: context,
                        page: const PlaceCategoryPicker()
                    );

                    if (result != null){
                      setState(() {
                        chosenCategory = result;
                        categoryController.text = chosenCategory.name;
                      });

                    }
                  },
                  readOnly: true
              ),

              const SizedBox(height: 20,),

             ElementsOfDesign.checkBox(
                 text: FilterConstants.haveEvents,
                 isChecked: chosenHaveEvents,
                 onChanged: (value){
                   setState(() {
                     chosenHaveEvents = !chosenHaveEvents;
                   });

                 },
                 context: context
             ),

              const SizedBox(height: 20,),

              ElementsOfDesign.checkBox(
                  text: FilterConstants.havePromos,
                  isChecked: chosenHavePromos,
                  onChanged: (value){
                    setState(() {
                      chosenHavePromos = !chosenHavePromos;
                    });

                  },
                  context: context
              ),

              const SizedBox(height: 20,),

              Row(
                children: [
                  Expanded(
                      child: ElementsOfDesign.customButton(
                          method: (){
                            systemMethodsClass.popBackToPreviousPageWithResult(context: context, result: [chosenCategory, chosenHaveEvents, chosenHavePromos]);
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
