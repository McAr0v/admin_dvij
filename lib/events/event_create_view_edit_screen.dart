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

  AddressType chosenAddressType = AddressType();

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
    if (fromDb){
      await placesList.getDownloadedList(fromDb: fromDb);
      await usersList.getDownloadedList(fromDb: fromDb);
    }

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
          chosenCity = City.empty();
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

                              if (chosenPriceType.priceType == PriceTypeEnum.free) ElementsOfDesign.buildTextField(
                                  controller: freePriceController,
                                  labelText: 'Цена',
                                  canEdit: false,
                                  icon: FontAwesomeIcons.dollarSign,
                                  context: context
                              ),

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
                                      await pickOnceDate();
                                    },
                                    onStartTimeTap: () async {
                                      await pickOnceTime(true);
                                    },
                                    onEndTimeTap: () async {
                                      await pickOnceTime(false);
                                    }
                                ),

                                if (chosenDateType.dateType == DateTypeEnum.long) longDate.getLongDateWidget(
                                    isMobile: isMobile,
                                    canEdit: canEdit,
                                    context: context,
                                    onStartDate: () async {
                                      await pickLongDate(isStart: true);
                                    },
                                    onEndDate: () async {
                                      await pickLongDate(isStart: false);
                                    },
                                    onStartTime: () async {
                                      await pickLongTime(true);
                                    },
                                    onEndTime: () async {
                                      await pickLongTime(false);
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
  Future<void> pickOnceTime(bool isStart) async {
    
    TimeOfDay initial = TimeOfDay.now();

    if (isStart){
      if (onceDate.startTime != null) {
        initial = onceDate.startTime!;
      }
    } else {
      if (onceDate.endTime != null) {
        initial = onceDate.endTime!;
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
          onceDate.startTime = picked;
        } else {
          onceDate.endTime = picked;
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

  /// Показ диалога выбора времени
  Future<void> pickLongTime(bool isStart) async {

    TimeOfDay initial = TimeOfDay.now();

    if (isStart){
      if (longDate.startTime != null) {
        initial = longDate.startTime!;
      }
    } else {
      if (longDate.endTime != null) {
        initial = longDate.endTime!;
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
          longDate.startTime = picked;
        } else {
          longDate.endTime = picked;
        }
      });


    }
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

  Future<void> pickOnceDate() async{
    DateTime firstDate = DateTime.now();

    if (onceDate.date != null){
      firstDate = onceDate.date!;
    }

    final DateTime? pickedDate = await sm.dataPicker(
        context: context,
        label: 'Выбери дату проведения',
        firstDate: firstDate,
        lastDate: DateTime(2050),
        currentDate: onceDate.date
    );

    if (pickedDate != null){
      setState(() {
        onceDate.date = pickedDate;
      });
    }

  }

  Future<void> pickLongDate({required bool isStart}) async {
    DateTime firstDate = DateTime.now();
    DateTime? lastDate;

    // Устанавливаем границы выбора дат в зависимости от выбранного типа (isStart)
    if (isStart) {
      // Дата начала
      lastDate = longDate.endDate; // Дата завершения должна быть границей
      if (longDate.startDate != null) {
        firstDate = longDate.startDate!;
      }
    } else {
      // Дата завершения
      firstDate = longDate.startDate ?? DateTime.now(); // Дата начала должна быть границей
    }

    // Показываем пикер
    final DateTime? pickedDate = await sm.dataPicker(
      context: context,
      label: isStart ? 'Выбери дату начала проведения' : 'Выбери дату завершения проведения',
      firstDate: firstDate,
      lastDate: lastDate ?? DateTime(2050), // Если границы нет, оставляем 2050 год
      currentDate: isStart ? longDate.startDate : longDate.endDate,
    );

    if (pickedDate != null) {
      // Проверяем, изменяем ли дату начала или завершения
      if (isStart) {
        setState(() {
          longDate.startDate = pickedDate;
        });

        // Если новая дата начала больше текущей даты завершения, сбрасываем дату завершения
        if (longDate.endDate != null && longDate.startDate!.isAfter(longDate.endDate!)) {
          longDate.endDate = null;
        }
      } else {
        setState(() {
          longDate.endDate = pickedDate;
        });

        // Если новая дата завершения меньше текущей даты начала, сбрасываем дату начала
        if (longDate.startDate != null && longDate.endDate!.isBefore(longDate.startDate!)) {
          longDate.startDate = null;
        }
      }
    }
  }

}
