import 'dart:io';
import 'package:admin_dvij/address/address_or_place_class.dart';
import 'package:admin_dvij/address/address_type_picker.dart';
import 'package:admin_dvij/categories/event_categories/event_category.dart';
import 'package:admin_dvij/constants/events_constants.dart';
import 'package:admin_dvij/events/event_category_picker.dart';
import 'package:admin_dvij/events/event_class.dart';
import 'package:admin_dvij/events/events_list_class.dart';
import 'package:admin_dvij/places/place_picker.dart';
import 'package:admin_dvij/price_type/price_type_class.dart';
import 'package:admin_dvij/price_type/price_type_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../cities/city_class.dart';
import '../cities/city_picker_page.dart';
import '../constants/buttons_constants.dart';
import '../constants/city_constants.dart';
import '../constants/places_constants.dart';
import '../constants/system_constants.dart';
import '../constants/users_constants.dart';
import '../database/image_picker.dart';
import '../dates/regular_date_class.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/button_state_enum.dart';
import '../design_elements/elements_of_design.dart';
import '../places/place_class.dart';
import '../places/places_list_class.dart';
import '../system_methods/system_methods_class.dart';
import '../users/admin_user/admin_user_class.dart';
import '../users/simple_users/creator_popup.dart';
import '../users/simple_users/simple_user.dart';
import '../users/simple_users/simple_users_list.dart';

class EventCreateViewEditScreen extends StatefulWidget {

  final EventClass? event;
  final int indexTabPage;

  const EventCreateViewEditScreen({this.event, required this.indexTabPage, Key? key}) : super(key: key);

  @override
  State<EventCreateViewEditScreen> createState() => _EventCreateViewEditScreenState();
}

class _EventCreateViewEditScreenState extends State<EventCreateViewEditScreen> {

  AdminUserClass currentAdminUser = AdminUserClass.empty();

  PlacesList placesList = PlacesList();
  EventsListClass eventsList = EventsListClass();
  SimpleUsersList usersList = SimpleUsersList();
  SystemMethodsClass sm = SystemMethodsClass();
  final ImagePickerService imagePickerService = ImagePickerService();

  bool loading = false;
  bool saving = false;
  bool deleting = false;
  bool canEdit = false;
  bool showSchedule = false;

  File? _imageFile;

  EventClass editEvent = EventClass.empty();

  SimpleUser creator = SimpleUser.empty();
  SimpleUser chosenCreator = SimpleUser.empty();

  EventCategory chosenCategory = EventCategory.empty();
  City chosenCity = City.empty();


  Place placeFromEvent = Place.empty();
  Place chosenPlace = Place.empty();

  AddressType addressType = AddressType();
  AddressType chosenAddressType = AddressType();


  RegularDate schedule = RegularDate();

  // Prices
  PriceType chosenPriceType = PriceType();

  final TextEditingController headlineController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController creatorController = TextEditingController();
  final TextEditingController createDateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController telegramController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  final TextEditingController placeController = TextEditingController();
  final TextEditingController addressTypeController = TextEditingController();



  final TextEditingController priceTypeController = TextEditingController();
  final TextEditingController fixedPriceController = TextEditingController();
  final TextEditingController rangeStartPriceController = TextEditingController();
  final TextEditingController rangeEndPriceController = TextEditingController();
  final TextEditingController freePriceController = TextEditingController();

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({
    bool fromDb = false
  })async{

    setState(() {
      loading = true;
    });

    // Подгружаем текущего пользователя
    currentAdminUser = await currentAdminUser.getCurrentUser(fromDb: false);

    // Подгружаем список заведений и список пользователей
    if (fromDb){
      await placesList.getDownloadedList(fromDb: fromDb);
      await usersList.getDownloadedList(fromDb: fromDb);
    }

    // Если это создание, то устанавливаем режим редактирования и показ расписания сразу
    if (widget.event == null){
      canEdit = true;
      showSchedule = true;
    }

    // Если редактирование, подгружаем создателя и редактируемое заведение. Устанавливаем расписание
    if (widget.event != null){
      editEvent = eventsList.getEntityFromList(widget.event!.id);

      // TODO Сделать прогрузку расписания
      //setSchedule();
    }

    // Сбрасываем текстовые поля и выбранные настройки по умолчанию
    // TODO Сделать сброс текстовых полей
    setTextFieldsOnDefault();

    setState(() {
      loading = false;
    });

  }

  void navigateToEventsListScreen() {
    sm.popBackToPreviousPageWithResult(context: context, result: editEvent);
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

  void setTextFieldsOnDefault(){
    setState(() {

      creator = usersList.getEntityFromList(editEvent.creatorId);
      placeFromEvent = placesList.getEntityFromList(editEvent.placeId);

      chosenCreator = SimpleUser.empty();
      chosenCategory = EventCategory.empty();
      chosenCity = City.empty();
      chosenPlace = Place.empty();
      chosenAddressType = AddressType();
      chosenPriceType = PriceType();

      if (editEvent.placeId.isNotEmpty){
        addressType = AddressType(addressTypeEnum: AddressTypeEnum.place);
        placeController.text = placeFromEvent.name;
        addressTypeController.text = addressType.toString();
      } else {
        addressType = AddressType(addressTypeEnum: AddressTypeEnum.address);
        placeController.text = 'Выбери заведение';
        addressTypeController.text = addressType.toString();
      }

      headlineController.text = editEvent.headline;
      descController.text = editEvent.desc;
      creatorController.text = creator.getFullName().isNotEmpty ? creator.getFullName() : EventsConstants.chooseCreator;
      createDateController.text = sm.formatDateTimeToHumanView(editEvent.createDate);
      categoryController.text = editEvent.category.name.isNotEmpty ? editEvent.category.name : EventsConstants.chooseCategory;
      cityController.text = editEvent.city.name.isNotEmpty ? editEvent.city.name : CityConstants.cityNotChosen;
      streetController.text = editEvent.street;
      houseController.text = editEvent.house;
      phoneController.text = editEvent.phone;
      whatsappController.text = editEvent.whatsapp;
      telegramController.text = editEvent.telegram;
      instagramController.text = editEvent.instagram;

      priceTypeController.text = editEvent.priceType.toString(translate: true);
      freePriceController.text = 'Бесплатно';

      if (editEvent.priceType.priceType == PriceTypeEnum.fixed){
        fixedPriceController.text = editEvent.price;
        rangeStartPriceController.text = '';
        rangeEndPriceController.text = '';
      } else if (editEvent.priceType.priceType == PriceTypeEnum.range){
        fixedPriceController.text = '';
        rangeStartPriceController.text = editEvent.priceType.getRangePrices(price: editEvent.price);
        rangeEndPriceController.text = editEvent.priceType.getRangePrices(price: editEvent.price, isStart: false);
      } else {
        fixedPriceController.text = '';
        rangeStartPriceController.text = '';
        rangeEndPriceController.text = '';
      }

      //setSchedule();

      _imageFile = null;
    });
  }

  Future<void> chooseCreator() async{
    final results = await sm.getPopup(context: context, page: const CreatorPopup());
    if (results != null){
      chosenCreator = results;
      creatorController.text = chosenCreator.getFullName();
      if (!chosenCreator.checkAdminRoleInUser(chosenPlace.id)){
        setState(() {
          chosenPlace = Place.empty();
          placeController.text = 'Выбери заведение';
        });
      }
    }
  }

  Future<void> chooseCity() async{
    final results = await sm.getPopup(context: context, page: const CityPickerPage());
    if (results != null){
      chosenCity = results;
      cityController.text = chosenCity.name;
    }
  }

  Future<void> chooseCategory() async{
    final results = await sm.getPopup(context: context, page: const EventCategoryPicker());
    if (results != null){
      chosenCategory = results;
      categoryController.text = chosenCategory.name;
    }
  }

  Future<void> choosePlace() async{
    final results = await sm.getPopup(context: context, page: PlacePicker(creatorId: chosenCreator.uid.isNotEmpty ? chosenCreator.uid : creator.uid));
    if (results != null){
      chosenPlace = results;
      placeController.text = chosenPlace.name;
      streetController.text = chosenPlace.street;
      houseController.text = chosenPlace.house;
      chosenCity = chosenPlace.city;
      cityController.text = chosenCity.name;
    }
  }

  Future<void> choosePriceType() async{
    final results = await sm.getPopup(context: context, page: const PriceTypePicker());
    if (results != null){
      setState(() {
        chosenPriceType = results;
        priceTypeController.text = chosenPriceType.toString(translate: true);
      });

    }
  }

  Future<void> chooseAddressType() async{
    final results = await sm.getPopup(context: context, page: const AddressTypePicker());
    if (results != null){

      setState(() {
        addressType = results;
        addressTypeController.text = addressType.toString();
        if (addressType.addressTypeEnum == AddressTypeEnum.place){
          placeController.text = chosenPlace.name;
          streetController.text = chosenPlace.street;
          houseController.text = chosenPlace.house;
          chosenCity = chosenPlace.city;
          cityController.text = chosenCity.name;
        } else {
          cityController.text = editEvent.city.name;
          chosenCity = City.empty();
          cityController.text = 'Выбери город';
          streetController.text = editEvent.street;
          houseController.text = editEvent.house;
          chosenPlace = Place.empty();
          placeController.text = 'Выбери заведение';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Условие для мобильной версии

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.event != null && widget.event!.headline.isNotEmpty
                ? '${EventsConstants.watchEvent} "${editEvent.headline}"'
                : EventsConstants.createEvent
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            navigateToEventsListScreen();
          },
        ),

        actions: [

          // Иконка обновления данных.

          if (widget.event != null) IconButton(
            onPressed: () async {
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка редактирования. Доступна если у текущего админа есть доступ или это не создание заведения

          if (currentAdminUser.adminRole.accessToEditEvents() && widget.event != null) IconButton(
            onPressed: () async {
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),

          if (currentAdminUser.adminRole.accessToDeleteEvents() && widget.event != null) IconButton(
            onPressed: () async {
              // TODO Сделать удаление
              //await deletePlace();
            },
            icon: const Icon(FontAwesomeIcons.trash, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.loadingDefault)
          else if (saving) const LoadingScreen(loadingText: SystemConstants.saving)
          else if (deleting) const LoadingScreen(loadingText: SystemConstants.deleting)
            else SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: sm.getScreenWidth(neededWidth: 800),
                    padding: EdgeInsets.all(isMobile ? 20 : 30),
                    margin: EdgeInsets.symmetric(
                        vertical: Platform.isWindows || Platform.isMacOS ? 20 : 10,
                        horizontal: Platform.isWindows || Platform.isMacOS ? 0 : 10
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greyOnBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [

                        ElementsOfDesign.imageForEditViewScreen(
                            context: context,
                            imageUrl: editEvent.imageUrl,
                            imageFile: _imageFile,
                            canEdit: canEdit,
                            onEditImage: () async {
                              await _pickImage();
                            }
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildTextField(
                            controller: headlineController,
                            labelText: EventsConstants.nameEvent,
                            canEdit: canEdit,
                            icon: FontAwesomeIcons.heading,
                            context: context
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildTextField(
                          controller: descController,
                          labelText: EventsConstants.descEvent,
                          canEdit: canEdit,
                          icon: FontAwesomeIcons.paragraph,
                          context: context,
                          maxLines: null,
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [

                              ElementsOfDesign.buildTextField(
                                  controller: categoryController,
                                  labelText: EventsConstants.eventCategory,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.tag,
                                  context: context,
                                  readOnly: true,
                                  onTap: () async {
                                    await chooseCategory();
                                  }
                              )
                            ]
                        ),


                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              if (canEdit) ElementsOfDesign.buildTextField(
                                  controller: addressTypeController,
                                  labelText: 'Где проводится',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.city,
                                  context: context,
                                  readOnly: true,
                                  onTap: () async {
                                    await chooseAddressType();
                                  }
                              ),

                              ElementsOfDesign.buildTextField(
                                  controller: cityController,
                                  labelText: UserConstants.city,
                                  canEdit: canEdit && addressType.addressTypeEnum == AddressTypeEnum.address,
                                  icon: FontAwesomeIcons.city,
                                  context: context,
                                  readOnly: true,
                                  onTap: () async {
                                    await chooseCity();
                                  }
                              ),


                              if (getAddressType() == AddressTypeEnum.place) ElementsOfDesign.buildTextField(
                                  controller: placeController,
                                  labelText: 'Название заведения',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.house,
                                  context: context,
                                  readOnly: true,
                                  onTap: () async {
                                    await choosePlace();
                                  }
                              ),

                              if (getAddressType() == AddressTypeEnum.address) ElementsOfDesign.buildTextField(
                                  controller: streetController,
                                  labelText: 'Улица',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.heading,
                                  context: context
                              ),

                              if (getAddressType() == AddressTypeEnum.address) ElementsOfDesign.buildTextField(
                                  controller: houseController,
                                  labelText: 'Номер дома',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.heading,
                                  context: context
                              ),

                            ]
                        ),



                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              ElementsOfDesign.buildTextField(
                                  controller: priceTypeController,
                                  labelText: 'Тип цены за билеты',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.dollarSign,
                                  context: context,
                                  readOnly: true,
                                  onTap: () async {
                                    await choosePriceType();
                                  }
                              ),

                              if (getPriceType() == PriceTypeEnum.free) ElementsOfDesign.buildTextField(
                                  controller: freePriceController,
                                  labelText: 'Цена',
                                  canEdit: false,
                                  icon: FontAwesomeIcons.dollarSign,
                                  context: context
                              ),

                              if (getPriceType() == PriceTypeEnum.range) ElementsOfDesign.buildTextField(
                                  controller: rangeStartPriceController,
                                  labelText: 'Минимальная цена билетов',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.dollarSign,
                                  context: context
                              ),

                              if (getPriceType() == PriceTypeEnum.range) ElementsOfDesign.buildTextField(
                                  controller: rangeEndPriceController,
                                  labelText: 'Максимальная цена билетов',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.dollarSign,
                                  context: context
                              ),
                              if (getPriceType() == PriceTypeEnum.fixed) ElementsOfDesign.buildTextField(
                                  controller: fixedPriceController,
                                  labelText: 'Цена билетов',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.dollarSign,
                                  context: context
                              ),

                            ]
                        ),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              ElementsOfDesign.buildTextField(
                                  controller: phoneController,
                                  labelText: UserConstants.phone,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.phone,
                                  context: context
                              ),
                              ElementsOfDesign.buildTextField(
                                controller: whatsappController,
                                labelText: UserConstants.whatsapp,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.whatsapp,
                                context: context,
                              )
                            ]
                        ),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              ElementsOfDesign.buildTextField(
                                  controller: telegramController,
                                  labelText: UserConstants.telegram,
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.telegram,
                                  context: context
                              ),
                              ElementsOfDesign.buildTextField(
                                controller: instagramController,
                                labelText: UserConstants.instagram,
                                canEdit: canEdit,
                                icon: FontAwesomeIcons.instagram,
                                context: context,
                              )
                            ]
                        ),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              ElementsOfDesign.buildTextField(
                                  controller: createDateController,
                                  labelText: EventsConstants.createDateEvent,
                                  canEdit: false,
                                  icon: FontAwesomeIcons.calendar,
                                  context: context
                              ),
                              ElementsOfDesign.buildTextField(
                                  controller: creatorController,
                                  labelText: EventsConstants.creatorEvent,
                                  canEdit: canEdit && currentAdminUser.adminRole.accessToEditCreator(),
                                  icon: FontAwesomeIcons.signature,
                                  context: context,
                                  readOnly: true,
                                  onTap: () async {
                                    await chooseCreator();
                                  }
                              )
                            ]
                        ),

                        /*schedule.getRegularEditWidget(
                          context: context,
                          onTapStart: (index) => pickTime(index, true),
                          onTapEnd: (index) => pickTime(index, false),
                          canEdit: canEdit,
                          showSchedule: showSchedule,
                          show: (){
                            setState(() {
                              showSchedule = !showSchedule;
                            });
                          },
                          onClean: (index) {
                            updateTime(index, true, null);
                            updateTime(index, false, null);
                          },
                        ),*/



                        const SizedBox(height: 20,),

                        if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              ElementsOfDesign.customButton(
                                  method: () async {
                                    //await savePlace();

                                  },
                                  textOnButton: ButtonsConstants.save,
                                  context: context
                              ),

                              ElementsOfDesign.customButton(
                                  method: (){
                                    setTextFieldsOnDefault();
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
                ),
              )
        ],
      ),

    );
  }

  AddressTypeEnum getAddressType(){
    if (chosenAddressType.addressTypeEnum == AddressTypeEnum.notChosen){
      return addressType.addressTypeEnum;
    } else {
      return chosenAddressType.addressTypeEnum;
    }
  }

  PriceTypeEnum getPriceType(){
    if (chosenPriceType.priceType == PriceTypeEnum.notChosen){
      return editEvent.priceType.priceType;
    } else {
      return chosenPriceType.priceType;
    }
  }

}
