import 'dart:io';
import 'package:admin_dvij/address/address_or_place_class.dart';
import 'package:admin_dvij/address/address_type_picker.dart';
import 'package:admin_dvij/categories/event_categories/event_category.dart';
import 'package:admin_dvij/constants/events_constants.dart';
import 'package:admin_dvij/dates/date_type.dart';
import 'package:admin_dvij/dates/date_type_picker.dart';
import 'package:admin_dvij/dates/irregular_date.dart';
import 'package:admin_dvij/dates/long_date.dart';
import 'package:admin_dvij/dates/once_date.dart';
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

  File? _imageFile;

  EventClass editEvent = EventClass.empty();
  SimpleUser creator = SimpleUser.empty();

  EventCategory chosenCategory = EventCategory.empty();
  City chosenCity = City.empty();

  Place chosenPlace = Place.empty();

  AddressType addressType = AddressType();

  DateType chosenDateType = DateType();

  OnceDate onceDate = OnceDate.empty();
  LongDate longDate = LongDate.empty();
  RegularDate schedule = RegularDate();
  IrregularDate irregularDate = IrregularDate.empty();

  // Prices
  PriceType chosenPriceType = PriceType();

  final TextEditingController headlineController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController createDateController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController telegramController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

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
    await placesList.getDownloadedList(fromDb: fromDb);
    await usersList.getDownloadedList(fromDb: fromDb);

    // Если это создание, то устанавливаем режим редактирования и показ расписания сразу
    if (widget.event == null){
      canEdit = true;
    }

    // Если редактирование, подгружаем создателя и редактируемое заведение. Устанавливаем расписание
    if (widget.event != null){
      editEvent = eventsList.getEntityFromList(widget.event!.id);
    }

    // Сбрасываем текстовые поля и выбранные настройки по умолчанию
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
      chosenPlace = placesList.getEntityFromList(editEvent.placeId);

      chosenCategory = EventCategory.setCategory(category: editEvent.category);
      chosenCity = City.setCity(city: editEvent.city);

      chosenPriceType = PriceType.setPriceType(priceType: editEvent.priceType);
      chosenDateType = DateType.setDateType(dateType: editEvent.dateType);

      if (editEvent.placeId.isNotEmpty){
        addressType = AddressType(addressTypeEnum: AddressTypeEnum.place);
      } else {
        addressType = AddressType(addressTypeEnum: AddressTypeEnum.address);
      }

      headlineController.text = editEvent.headline;
      descController.text = editEvent.desc;
      createDateController.text = sm.formatDateTimeToHumanView(editEvent.createDate);
      streetController.text = editEvent.street;
      houseController.text = editEvent.house;
      phoneController.text = editEvent.phone;
      whatsappController.text = editEvent.whatsapp;
      telegramController.text = editEvent.telegram;
      instagramController.text = editEvent.instagram;

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

      schedule = RegularDate.setSchedule(fromDate: editEvent.regularDays);
      onceDate = OnceDate.setOnceDay(fromDate: editEvent.onceDay);
      longDate = LongDate.setLongDate(fromDate: editEvent.longDays);
      irregularDate = IrregularDate.setIrregularDates(fromDate: editEvent.irregularDays);

      _imageFile = null;
    });
  }


  Future<void> chooseCreator() async{
    final results = await sm.getPopup(context: context, page: const CreatorPopup());
    if (results != null){
      creator = results;
      if (!creator.checkAdminRoleInUser(chosenPlace.id)){
        setState(() {
          chosenPlace = Place.empty();
        });
      }
    }
  }

  Future<void> chooseCity() async{
    final results = await sm.getPopup(context: context, page: const CityPickerPage());
    if (results != null){
      setState(() {
        chosenCity = results;
      });
    }
  }

  Future<void> chooseCategory() async{
    final results = await sm.getPopup(context: context, page: const EventCategoryPicker());
    if (results != null){
      setState(() {
        chosenCategory = results;
      });
    }
  }

  Future<void> choosePlace() async{
    final results = await sm.getPopup(context: context, page: PlacePicker(creatorId: creator.uid.isNotEmpty ? creator.uid : creator.uid));
    if (results != null){
      setState(() {
        chosenPlace = results;
        streetController.text = chosenPlace.street;
        houseController.text = chosenPlace.house;
        chosenCity = chosenPlace.city;
      });
    }
  }

  Future<void> choosePriceType() async{
    final results = await sm.getPopup(context: context, page: const PriceTypePicker());
    if (results != null){
      setState(() {
        chosenPriceType = results;
      });

    }
  }

  Future<void> chooseDateType() async{
    final results = await sm.getPopup(context: context, page: const DateTypePicker());
    if (results != null){
      setState(() {
        chosenDateType = results;
      });

    }
  }

  Future<void> chooseAddressType() async{
    final results = await sm.getPopup(context: context, page: const AddressTypePicker());
    if (results != null){

      setState(() {
        addressType = results;
        if (addressType.addressTypeEnum == AddressTypeEnum.place){
          streetController.text = chosenPlace.street;
          houseController.text = chosenPlace.house;
          chosenCity = chosenPlace.city;
        } else {
          chosenCity = editEvent.city;
          streetController.text = editEvent.street;
          houseController.text = editEvent.house;
          chosenPlace = Place.empty();
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
              await deleteEvent();
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

                              chosenCategory.getCategoryFieldWidget(
                                  canEdit: canEdit,
                                  context: context,
                                  onTap: () async {
                                    await chooseCategory();
                                  }
                              ),
                            ]
                        ),


                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              if (canEdit) addressType.getAddressTypeFieldWidget(
                                  canEdit: canEdit,
                                  context: context,
                                  onTap: () async {
                                    await chooseAddressType();
                                  }
                              ),

                              chosenCity.getCityWidget(
                                  canEdit: canEdit && addressType.addressTypeEnum == AddressTypeEnum.address,
                                  context: context,
                                  onTap: () async {
                                    await chooseCity();
                                  }
                              ),

                              if (addressType.addressTypeEnum == AddressTypeEnum.place) chosenPlace.getPlaceWidgetField(
                                  canEdit: canEdit,
                                  context: context,
                                  onTap: () async {
                                    await choosePlace();
                                  }
                              ),

                              if (addressType.addressTypeEnum == AddressTypeEnum.address) ElementsOfDesign.buildTextField(
                                  controller: streetController,
                                  labelText: 'Улица',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.heading,
                                  context: context
                              ),

                              if (addressType.addressTypeEnum == AddressTypeEnum.address) ElementsOfDesign.buildTextField(
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

                              chosenPriceType.getPriceTypeFieldWidget(
                                  canEdit: canEdit,
                                  context: context,
                                  onTap: () async {
                                    await choosePriceType();
                                  }
                              ),

                              if (chosenPriceType.priceType == PriceTypeEnum.free) chosenPriceType.getFreePriceWidget(context: context),

                              if (chosenPriceType.priceType == PriceTypeEnum.range) ElementsOfDesign.buildTextField(
                                  controller: rangeStartPriceController,
                                  labelText: 'Минимальная цена билетов',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.dollarSign,
                                  context: context
                              ),

                              if (chosenPriceType.priceType == PriceTypeEnum.range) ElementsOfDesign.buildTextField(
                                  controller: rangeEndPriceController,
                                  labelText: 'Максимальная цена билетов',
                                  canEdit: canEdit,
                                  icon: FontAwesomeIcons.dollarSign,
                                  context: context
                              ),
                              if (chosenPriceType.priceType == PriceTypeEnum.fixed) ElementsOfDesign.buildTextField(
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

                              creator.getCreatorWidget(
                                  creator: creator,
                                  onTap: () async {
                                    await chooseCreator();
                                  },
                                  canEdit: canEdit && currentAdminUser.adminRole.accessToEditCreator(),
                                  context: context
                              )
                            ]
                        ),

                        Card(
                          color: AppColors.greyBackground,
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [

                                chosenDateType.getDateTypeWidget(
                                    canEdit: canEdit,
                                    context: context,
                                    onTap: () async {
                                      await chooseDateType();
                                    }
                                ),

                                const SizedBox(height: 20,),

                                if (chosenDateType.dateType == DateTypeEnum.regular) schedule.getRegularEditWidgetTwo(
                                    context: context,
                                    onTapStart: (index) => pickRegularTime(index, true),
                                    onTapEnd: (index) => pickRegularTime(index, false),
                                    canEdit: canEdit,
                                    onClean: (index) {
                                      updateTime(index, true, null);
                                      updateTime(index, false, null);
                                    },
                                    isMobile: isMobile
                                ),

                                const SizedBox(height: 10,),

                                if (chosenDateType.dateType == DateTypeEnum.once) onceDate.getOnceDayWidget(
                                    isMobile: isMobile,
                                    canEdit: canEdit,
                                    context: context,
                                    onDateTap: () async {
                                      await pickOnceLongDate(isStart: true, isOnce: true);
                                    },
                                    onStartTimeTap: () async {
                                      await pickOnceLongTime(isOnce: true, isStart:  true);
                                    },
                                    onEndTimeTap: () async {
                                      await pickOnceLongTime(isOnce: true, isStart:  false);
                                    }
                                ),

                                if (chosenDateType.dateType == DateTypeEnum.long) longDate.getLongDateWidget(
                                    isMobile: isMobile,
                                    canEdit: canEdit,
                                    context: context,
                                    onStartDate: () async {
                                      await pickOnceLongDate(isStart: true, isOnce: false);
                                    },
                                    onEndDate: () async {
                                      await pickOnceLongDate(isStart: false, isOnce: false);
                                    },
                                    onStartTime: () async {
                                      await pickOnceLongTime(isOnce: false, isStart:  true);
                                    },
                                    onEndTime: () async {
                                      await pickOnceLongTime(isOnce: false, isStart:  false);
                                    }
                                ),

                                if (chosenDateType.dateType == DateTypeEnum.irregular) irregularDate.getIrregularDateWidget(
                                    isMobile: isMobile,
                                    canEdit: canEdit,
                                    context: context,
                                    onDateTap: canEdit ? (index) async{
                                      DateTime? picked = await pickIrregularDate(date: irregularDate.dates[index].date);
                                      if (picked != null) {
                                        setState(() {
                                          irregularDate.dates[index].date = picked;
                                        });
                                      }
                                    } : null,
                                    onStartTimeTap: canEdit ? (index) async{
                                      TimeOfDay? picked = await pickIrregularTime(irregularDate.dates[index].startTime);
                                      if (picked != null) {
                                        setState(() {
                                          irregularDate.dates[index].startTime = picked;
                                        });
                                      }
                                    } : null,
                                    onEndTimeTap: canEdit ? (index) async{
                                      TimeOfDay? picked = await pickIrregularTime(irregularDate.dates[index].endTime);
                                      if (picked != null) {
                                        setState(() {
                                          irregularDate.dates[index].endTime = picked;
                                        });
                                      }
                                    } : null,
                                    onRemoveDate: (index) {
                                      setState(() {
                                        irregularDate.dates.remove(irregularDate.dates[index]);
                                      });
                                    },
                                    addDate: (){
                                      setState(() {
                                        irregularDate.dates.add(OnceDate(date: null, startTime: null, endTime: null));
                                      });
                                    }
                                ),
                              ],
                            ),
                          ),
                        ),



                        const SizedBox(height: 20,),

                        if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              ElementsOfDesign.customButton(
                                  method: () async {
                                    await saveEvent();
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

  Future<void> deleteEvent () async {

    bool? result = await ElementsOfDesign.exitDialog(
        context,
        'Если удалите мероприятие, данные будет невозможно восстановить',
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        'Удалить мероприятие?'
    );

    if (result != null && result){
      setState(() {
        deleting = true;
      });

      String publishResult = await editEvent.deleteFromDb();

      if (publishResult == SystemConstants.successConst){

        _showSnackBar('Мероприятие успешно удалено');
        navigateToEventsListScreen();

      } else {
        _showSnackBar(publishResult);
      }

      setState(() {
        saving = false;
      });
    }

  }

  Future<void> saveEvent() async{
    setState(() {
      saving = true;
    });

    EventClass tempEvent = setEventBeforeSaving();


    if (checkEvent(tempEvent) == SystemConstants.successConst){

      String publishResult = await tempEvent.publishToDb(_imageFile);

      if (publishResult == SystemConstants.successConst) {

        // Если поменяли создателя
        if (creator.uid != editEvent.creatorId){
          // Подгружаем старого создателя
          SimpleUser previousCreator = usersList.getEntityFromList(editEvent.creatorId);

          // Если прогрузился
          if (previousCreator.uid.isNotEmpty){
            // Удаляем запись об этом мероприятии
            await previousCreator.deleteEventFromMyEvents(eventId: editEvent.id);
          }
        }

        // Если есть выбранное место
        if (chosenPlace.id.isNotEmpty){
          // Если выбрали другое место проведения
          if (chosenPlace.id != editEvent.placeId){
            // Подгружаем место
            Place previousPlace = placesList.getEntityFromList(editEvent.placeId);

            // Если место прогрузилось
            if (previousPlace.id.isNotEmpty){
              // Удаляем мероприятие из заведения
              await previousPlace.deleteEventFromPlace(eventId: editEvent.id);
            }
          }
        }

        await initialization();



        _showSnackBar('Мероприятие успешно сохранено');

        canEdit = false;
        setTextFieldsOnDefault();

        if (widget.event == null){
          navigateToEventsListScreen();
        }

      } else {
        _showSnackBar(publishResult);
      }
    } else {
      _showSnackBar(checkEvent(tempEvent));
    }

    setState(() {
      saving = false;
    });
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String checkEvent(EventClass tempEvent){

    if (tempEvent.dateType.dateType == DateTypeEnum.notChosen){
      return 'Не выбран тип даты';
    }

    if (tempEvent.headline.isEmpty){
      return 'Нет названия мероприятия';
    }
    if (tempEvent.desc.isEmpty){
      return 'Нет описания мероприятия';
    }
    if (tempEvent.creatorId.isEmpty){
      return 'Не выбран создатель';
    }

    if (tempEvent.city.id.isEmpty){
      return 'Не выбран город';
    }
    if (tempEvent.category.id.isEmpty){
      return 'Не выбрана категория';
    }
    if (tempEvent.street.isEmpty){
      return 'Не указана улица';
    }

    if (tempEvent.house.isEmpty){
      return 'Не указан номер дома';
    }

    if (tempEvent.phone.isEmpty){
      return 'Нет контактного телефона';
    }

    if (addressType.addressTypeEnum == AddressTypeEnum.place){
      if (tempEvent.placeId.isEmpty){
        return 'Не выбрано заведение';
      }
    } else if (addressType.addressTypeEnum == AddressTypeEnum.notChosen){
      return 'Не выбран тип адреса - в заведении или по адресу';
    }

    if (tempEvent.priceType.priceType == PriceTypeEnum.notChosen){
      return 'Не выбран тип цены билетов';
    } else if (tempEvent.priceType.priceType == PriceTypeEnum.fixed){
      if (fixedPriceController.text.isEmpty){
        return 'Не указана цена билетов';
      }
    } else if (tempEvent.priceType.priceType == PriceTypeEnum.range){
      if (rangeStartPriceController.text.isEmpty){
        return 'Не указана начальная цена билетов';
      } else if (rangeEndPriceController.text.isEmpty){
        return 'Не указана конечная цена билетов';
      }
    }

    if (tempEvent.dateType.dateType == DateTypeEnum.notChosen){
      return 'Не указан тип дат проведения';
    } else if (tempEvent.dateType.dateType == DateTypeEnum.once){
      if (tempEvent.onceDay.checkDate() != SystemConstants.successConst){
        return tempEvent.onceDay.checkDate();
      }
    } else if (tempEvent.dateType.dateType == DateTypeEnum.long){
      if (tempEvent.longDays.checkDate() != SystemConstants.successConst){
        return tempEvent.longDays.checkDate();
      }
    } else if (tempEvent.dateType.dateType == DateTypeEnum.regular){
      if (!schedule.checkRegularDate()){
        return 'В расписании нет ни одного выбранного дня';
      }
    } else if (tempEvent.dateType.dateType == DateTypeEnum.irregular){
      if (tempEvent.irregularDays.checkDate() != SystemConstants.successConst){
        return tempEvent.irregularDays.checkDate();
      }
    }

    return SystemConstants.successConst;

  }

  EventClass setEventBeforeSaving(){

    EventClass tempEvent = EventClass.empty();

    tempEvent.id = editEvent.id;

    tempEvent.dateType = chosenDateType;

    if (chosenDateType.dateType == DateTypeEnum.once){
      tempEvent.onceDay = onceDate;
    } else if (chosenDateType.dateType == DateTypeEnum.long){
      tempEvent.longDays = longDate;
    } else if (chosenDateType.dateType == DateTypeEnum.regular){
      tempEvent.regularDays = schedule;
    } else if (chosenDateType.dateType == DateTypeEnum.irregular){
      tempEvent.irregularDays = irregularDate;
    }

    tempEvent.headline = headlineController.text;
    tempEvent.desc = descController.text;
    tempEvent.creatorId = creator.uid;
    tempEvent.createDate = editEvent.createDate;
    tempEvent.category = chosenCategory;
    tempEvent.city = chosenCity;
    tempEvent.street = streetController.text;
    tempEvent.house = houseController.text;
    tempEvent.phone = phoneController.text;
    tempEvent.whatsapp = whatsappController.text;
    tempEvent.instagram = instagramController.text;
    tempEvent.telegram = telegramController.text;
    tempEvent.imageUrl = editEvent.imageUrl;
    tempEvent.placeId = chosenPlace.id;
    tempEvent.priceType = chosenPriceType;

    tempEvent.price = chosenPriceType.getPriceStringForDb(
        fixedPrice: fixedPriceController.text,
        startPrice: rangeStartPriceController.text,
        endPrice: rangeEndPriceController.text
    );

    return tempEvent;

  }

  /// Обновляем время
  void updateTime(int index, bool isStart, TimeOfDay? newTime) {
    setState(() {
      switch (index) {
        case 0:
          isStart ? schedule.mondayStart = newTime : schedule.mondayEnd = newTime;
          break;
        case 1:
          isStart ? schedule.tuesdayStart = newTime : schedule.tuesdayEnd = newTime;
          break;
        case 2:
          isStart ? schedule.wednesdayStart = newTime : schedule.wednesdayEnd = newTime;
          break;
        case 3:
          isStart ? schedule.thursdayStart = newTime : schedule.thursdayEnd = newTime;
          break;
        case 4:
          isStart ? schedule.fridayStart = newTime : schedule.fridayEnd = newTime;
          break;
        case 5:
          isStart ? schedule.saturdayStart = newTime : schedule.saturdayEnd = newTime;
          break;
        case 6:
          isStart ? schedule.sundayStart = newTime : schedule.sundayEnd = newTime;
          break;
      }
    });
  }

  /// Показ диалога выбора времени
  Future<void> pickRegularTime(int index, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: schedule.getTime(index: index, isStart: true) ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      updateTime(index, isStart, picked);
    }
  }

  /// Показ диалога выбора времени
  Future<void> pickOnceLongTime({
    required bool isStart,
    required bool isOnce
  }) async {
    
    TimeOfDay initial = TimeOfDay.now();

    // Устанавливаем initial
    // Если это начальная дата
    if (isStart){
      // Если одиночная дата
      if (isOnce){
        if (onceDate.startTime != null) {
          initial = onceDate.startTime!;
        }
      }
      // Если долгая дата
      else {
        if (longDate.startTime != null) {
          initial = longDate.startTime!;
        }
      }

    }
    // Если это конечная дата
    else {
      // Если одиночная дата
      if (isOnce){
        if (onceDate.endTime != null) {
          initial = onceDate.endTime!;
        }
      }
      // Если долгая дата
      else {
        if (longDate.endTime != null) {
          initial = longDate.endTime!;
        }
      }
    }
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      setState(() {
        if (isStart){
          if (isOnce){
            onceDate.startTime = picked;
          } else {
            longDate.startTime = picked;
          }
        } else {
          if (isOnce) {
            onceDate.endTime = picked;
          } else {
            longDate.endTime = picked;
          }
        }
      });
    }
  }

  /// Показ диалога выбора времени
  Future<TimeOfDay?> pickIrregularTime(TimeOfDay? time) async {

    TimeOfDay initial = TimeOfDay.now();

    if (time != null) {
      initial = time;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      return picked;
    }

    return null;
  }

  Future<DateTime?> pickIrregularDate({required DateTime? date}) async{
    DateTime firstDate = DateTime.now();

    if (date != null){
      firstDate = date;
    }

    final DateTime? pickedDate = await sm.dataPicker(
        context: context,
        label: 'Выбери дату проведения',
        firstDate: firstDate,
        lastDate: DateTime(2050),
        currentDate: date
    );

    if (pickedDate != null){
     return pickedDate;
    }

    return null;
  }

  Future<void> pickOnceLongDate({required isOnce, required bool isStart}) async{
    DateTime firstDate = DateTime.now();
    DateTime? lastDate;

    DateTime currentDate = DateTime.now();

    if (isOnce){
      if (onceDate.date != null){
        firstDate = onceDate.date!;
        currentDate = onceDate.date!;
      }
    } else {
      // Устанавливаем границы выбора дат в зависимости от выбранного типа (isStart)
      if (isStart) {
        currentDate = longDate.startDate ?? DateTime.now();
        lastDate = longDate.endDate ?? DateTime(2050); // Дата завершения должна быть границей
      } else {
        currentDate = longDate.endDate ?? longDate.startDate ?? DateTime.now();
        firstDate = longDate.startDate ?? DateTime.now(); // Дата начала должна быть границей
        lastDate = DateTime(2050);
      }
    }

    final DateTime? pickedDate = await sm.dataPicker(
        context: context,
        label: 'Выбери дату проведения',
        firstDate: firstDate,
        lastDate: lastDate ?? DateTime(2050),
        currentDate: currentDate
    );

    if (pickedDate != null){
      setState(() {
        if (isOnce){
          onceDate.date = pickedDate;
        } else {
          if (isStart) {
            longDate.startDate = pickedDate;
          } else {
            longDate.endDate = pickedDate;
          }
        }

      });
    }
  }

}
