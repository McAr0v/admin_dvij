import 'package:admin_dvij/categories/event_categories/event_category.dart';
import 'package:admin_dvij/cities/city_picker_page.dart';
import 'package:admin_dvij/constants/address_type_constants.dart';
import 'package:admin_dvij/constants/categories_constants.dart';
import 'package:admin_dvij/constants/city_constants.dart';
import 'package:admin_dvij/events/event_category_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../cities/city_class.dart';
import '../constants/buttons_constants.dart';
import '../constants/filter_constants.dart';
import '../design/app_colors.dart';
import '../design_elements/button_state_enum.dart';
import '../design_elements/elements_of_design.dart';
import '../system_methods/system_methods_class.dart';

class FilterEvents extends StatefulWidget {
  final bool inPlace;
  final EventCategory filterCategory;
  final City filterCity;

  const FilterEvents({
    required this.inPlace,
    required this.filterCity,
    required this.filterCategory,
    Key? key
  }) : super(key: key);

  @override
  State<FilterEvents> createState() => _FilterEventsState();
}

class _FilterEventsState extends State<FilterEvents> {

  SystemMethodsClass systemMethodsClass = SystemMethodsClass();

  bool chosenInPlace = false;
  EventCategory chosenCategory = EventCategory.empty();
  City chosenCity = City.empty();

  TextEditingController categoryController = TextEditingController();
  TextEditingController cityController = TextEditingController();


  @override
  void initState() {

    chosenInPlace = widget.inPlace;
    chosenCity = widget.filterCity;
    chosenCategory = widget.filterCategory;

    categoryController.text = _getCategoryTextForField();
    cityController.text = _getCityTextForField();

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
                  if (chosenInPlace || chosenCity.name.isNotEmpty || chosenCategory.name.isNotEmpty)
                    ElementsOfDesign.linkButton(
                        method: (){
                          setState(() {
                            chosenCategory = EventCategory.empty();
                            chosenCity = City.empty();
                            chosenInPlace = false;

                            cityController.text = _getCityTextForField();
                            categoryController.text = _getCategoryTextForField();

                          });
                        },
                        text: FilterConstants.clearFilter,
                        context: context
                    )
                ],
              ),

              const SizedBox(height: 20,),

              ElementsOfDesign.buildTextField(
                  controller: cityController,
                  labelText: CityConstants.chooseCity,
                  canEdit: true,
                  icon: FontAwesomeIcons.locationPin,
                  context: context,
                  onTap: () async {
                    final result = await systemMethodsClass.getPopup(
                        context: context,
                        page: const CityPickerPage()
                    );

                    if (result != null){
                      setState(() {
                        chosenCity = result;
                        cityController.text = _getCityTextForField();
                      });

                    }
                  },
                  readOnly: true
              ),

              const SizedBox(height: 20,),

              ElementsOfDesign.buildTextField(
                  controller: categoryController,
                  labelText: CategoriesConstants.chooseCategory,
                  canEdit: true,
                  icon: FontAwesomeIcons.tag,
                  context: context,
                  onTap: () async {
                    final result = await systemMethodsClass.getPopup(
                        context: context,
                        page: const EventCategoryPicker()
                    );

                    if (result != null){
                      setState(() {
                        chosenCategory = result;
                        categoryController.text = _getCategoryTextForField();
                      });

                    }
                  },
                  readOnly: true
              ),

              const SizedBox(height: 20,),

              ElementsOfDesign.checkBox(
                  text: AddressTypeConstants.inPlace,
                  isChecked: chosenInPlace,
                  onChanged: (value){
                    setState(() {
                      chosenInPlace = !chosenInPlace;
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
                            systemMethodsClass.popBackToPreviousPageWithResult(context: context, result: [chosenCity, chosenCategory, chosenInPlace]);
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

  String _getCityTextForField(){
    return chosenCity.id.isEmpty ? CityConstants.cityNotChosen : chosenCity.name;
  }

  String _getCategoryTextForField(){
    return chosenCategory.id.isEmpty ? CategoriesConstants.categoryNotChosen : chosenCategory.name;
  }
}
