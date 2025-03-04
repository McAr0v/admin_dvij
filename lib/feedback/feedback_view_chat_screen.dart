import 'dart:io';
import 'package:admin_dvij/constants/date_constants.dart';
import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:admin_dvij/constants/simple_users_constants.dart';
import 'package:admin_dvij/database/image_picker.dart';
import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/feedback/feedback_status.dart';
import 'package:admin_dvij/feedback/feedback_status_picker.dart';
import 'package:admin_dvij/feedback/feedback_topic.dart';
import 'package:admin_dvij/feedback/feedback_topic_picker.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user.dart';
import 'package:admin_dvij/users/simple_users/simple_user_screen.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/buttons_constants.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/button_state_enum.dart';
import '../design_elements/elements_of_design.dart';
import 'feedback_message.dart';

class FeedbackViewChatScreen extends StatefulWidget {
  final FeedbackCustom feedback;

  const FeedbackViewChatScreen({required this.feedback, Key? key}) : super(key: key);

  @override
  State<FeedbackViewChatScreen> createState() => _FeedbackViewChatScreenState();
}

class _FeedbackViewChatScreenState extends State<FeedbackViewChatScreen> {

  FeedbackListClass fl = FeedbackListClass();
  SystemMethodsClass sm = SystemMethodsClass();
  SimpleUsersList simpleUsersList = SimpleUsersList();
  ImagePickerService imagePickerService = ImagePickerService();

  AdminUserClass currentAdmin = AdminUserClass.empty();
  SimpleUser client = SimpleUser.empty();

  TextEditingController answerController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool loading = false;
  bool saving = false;
  bool deleting = false;
  bool sendingMessage = false;
  bool canEdit = false;

  FeedbackCustom editFeedback = FeedbackCustom.empty();
  FeedbackTopic chosenTopic = FeedbackTopic();
  FeedbackStatus chosenStatus = FeedbackStatus();
  DateTime? finishDate;

  File? imageFile;

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {
    setState(() {
      loading = true;
    });

    canEdit = false;

    answerController.text = '';

    if (fromDb) {
      await fl.getDownloadedList(fromDb: fromDb);
    }

    editFeedback = fl.getEntityFromList(widget.feedback.id);
    currentAdmin = await currentAdmin.getCurrentUser(fromDb: fromDb);
    chosenTopic = editFeedback.topic;
    chosenStatus = editFeedback.status;
    client = simpleUsersList.getEntityFromList(editFeedback.userId);
    finishDate = editFeedback.finishDate;

    editFeedback.messages.sortFeedbackMessages(true);

    imageFile = null;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Условие для мобильной версии

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
            'Обращение №${editFeedback.id}'
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            navigateToFeedbackListScreen();
          },
        ),

        actions: [

          // Иконка обновления данных.

          IconButton(
            onPressed: () async {
              await initialization(fromDb: true);
            },
            icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
          ),

          // Иконка редактирования. Доступна если у текущего админа есть доступ или это не создание заведения

          if (currentAdmin.adminRole.accessToEditFeedback()) IconButton(
            onPressed: () async {
              setState(() {
                canEdit = true;
              });
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 15, color: AppColors.white,),
          ),

          if (currentAdmin.adminRole.accessToDeleteFeedback() && !canEdit) IconButton(
            onPressed: () async {
              await deleteFeedback();
            },
            icon: const Icon(FontAwesomeIcons.trash, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      bottomSheet: Container(
        width: sm.getScreenWidth(neededWidth: 1000),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: Platform.isWindows || Platform.isMacOS ? const EdgeInsets.symmetric(vertical: 10, horizontal: 20) : const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (imageFile != null) ElementsOfDesign.getImageFromFileWithXButton(
                  image: imageFile!,
                  onTap: (){
                    setState(() {
                      imageFile = null;
                    });
                  }
              ),

              if (imageFile != null) const SizedBox(width: 20),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElementsOfDesign.buildTextField(
                          controller: answerController,
                          labelText: SystemConstants.enterTextMessage,
                          canEdit: !canEdit,
                          maxLines: null,
                          icon: FontAwesomeIcons.paperclip,
                          textInputType: TextInputType.multiline,
                          context: context,
                          onIconTap: !canEdit ? () async {
                            await _pickImage();

                          } : null
                      ),
                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      width: 40, // Задаем ширину
                      height: 40, // Задаем высоту
                      child: sendingMessage
                          ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(),
                          )
                          : IconButton(
                        icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                        onPressed: () async {
                          if (!canEdit && answerController.text.isNotEmpty){
                            await sendMessage();
                          } else if (answerController.text.isEmpty) {
                            _showSnackBar(SystemConstants.enterTextMessage);
                          } else if (canEdit){
                            _showSnackBar(FeedbackConstants.feedbackSendMessageOnCanEditError);
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.loadingDefault)
          else if (saving) const LoadingScreen(loadingText: SystemConstants.saving)
          else if (deleting) const LoadingScreen(loadingText: SystemConstants.deleting)
            else SingleChildScrollView(
                controller: _scrollController,
              child: Center(
                child: Container(
                  width: sm.getScreenWidth(neededWidth: 1000),
                  padding: EdgeInsets.all(isMobile ? 20 : 30),
                  margin: EdgeInsets.symmetric(
                      vertical: Platform.isWindows || Platform.isMacOS ? 10 : 10,
                      horizontal: Platform.isWindows || Platform.isMacOS ? 0 : 10
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greyOnBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'Обращение №${editFeedback.id}',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 10,),

                      Text(
                        'От ${sm.formatDateTimeToHumanView(editFeedback.createDate)}',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                        textAlign: TextAlign.start,
                      ),

                      const SizedBox(height: 20,),

                      ElementsOfDesign.buildAdaptiveRow(
                          isMobile: isMobile,
                          children: [
                            chosenStatus.getStatusFieldWidget(
                                canEdit: canEdit,
                                context: context,
                                onTap: () async {
                                  await chooseStatus();
                                }
                            ),


                            ElementsOfDesign.buildTextFieldWithoutController(
                                controllerText: finishDate != null ? sm.formatDateTimeToHumanView(finishDate!) : DateConstants.noFinish,
                                labelText: DateConstants.finishDateFeedback,
                                canEdit: false,
                                icon: FontAwesomeIcons.flagCheckered,
                                context: context,
                            )
                          ]
                      ),

                      chosenTopic.getTopicFieldWidget(
                          canEdit: canEdit,
                          context: context,
                          onTap: () async {
                            await chooseTopic();
                          }
                      ),

                      if (canEdit) const SizedBox(height: 20,),

                      if (canEdit) ElementsOfDesign.buildAdaptiveRow(
                          isMobile: isMobile,
                          children: [
                            ElementsOfDesign.customButton(
                                method: () async {
                                  await saveFeedback();
                                },
                                textOnButton: ButtonsConstants.save,
                                context: context
                            ),

                            ElementsOfDesign.customButton(
                                method: () async {
                                  await initialization();
                                },
                                textOnButton: ButtonsConstants.cancel,
                                context: context,
                                buttonState: ButtonStateEnum.secondary
                            ),
                          ]
                      ),

                      const SizedBox(height: 30,),

                      Text(
                        'Чат с ${client.getFullName()}:',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 20,),

                      // if (!sendingMessage)
                      Column(
                        children: [
                          for (FeedbackMessage message in editFeedback.messages) message.getMessageWidget(
                              client: client,
                              context: context,
                              onProfileTap: () async {
                                await goToClientPage(id: message.senderId);
                            },
                            onImageTap: (){
                                ElementsOfDesign.showImagePopup(context, message.imageUrl);
                            }
                          )
                        ],
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

  Future<void> goToClientPage({required String id}) async {

    SimpleUser tempUser = simpleUsersList.getEntityFromList(id);

    if (tempUser.uid.isNotEmpty){

      final result = await sm.pushToPageWithResult(context: context, page: SimpleUserScreen(simpleUser: tempUser));

      if (result != null) {
        await initialization();
      }

    } else {
      _showSnackBar(SimpleUsersConstants.userNotLoadedError);
    }


  }

  Future<void> _pickImage() async {

    // TODO - сделать подборщика картинок на macOs

    final File? pickedImage = await imagePickerService.pickImage(ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = pickedImage;
      });
    }
  }

  Future<void> sendMessage() async {
    FeedbackMessage tempMessage = FeedbackMessage(
        id: '',
        sendTime: DateTime.now(),
        feedbackId: editFeedback.id,
        userId: editFeedback.userId,
        senderId: currentAdmin.uid,
        messageText: answerController.text,
        imageUrl: ''
    );

    setState(() {
      sendingMessage = true;
    });

    if (tempMessage.checkMessageBeforeSending()){

      String result = await tempMessage.publishToDb(imageFile);

      if (result == SystemConstants.successConst){
        await initialization();
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomSmoothly());
      } else {
        _showSnackBar(result);
      }

    } else {
      _showSnackBar(FeedbackConstants.feedbackNotFillError);
    }

    setState(() {
      sendingMessage = false;
    });

  }

  void _scrollToBottomSmoothly() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> chooseTopic() async{
    final results = await sm.getPopup(context: context, page: const FeedbackTopicPicker());
    if (results != null){
      setState(() {
        chosenTopic = results;
      });
    }
  }

  Future<void> chooseStatus() async{
    final results = await sm.getPopup(context: context, page: const FeedbackStatusPicker());
    if (results != null){
      setState(() {
        chosenStatus = results;

        if (chosenStatus.isFinishStatus()){
          finishDate = DateTime.now();
        } else {
          finishDate = null;
        }

      });
    }
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void navigateToFeedbackListScreen() {
    sm.popBackToPreviousPageWithResult(context: context, result: editFeedback);
  }

  Future<void> deleteFeedback() async {

    final confirmed = await ElementsOfDesign.exitDialog(
        context,
        FeedbackConstants.feedbackNoRemoveDesc,
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        FeedbackConstants.feedbackDeleteQuestion(editFeedback.id)
    );

    if (confirmed != null && confirmed){
      setState(() {
        deleting = true;
      });

      String result = await editFeedback.deleteFromDb();

      if (result == SystemConstants.successConst){
        _showSnackBar(SystemConstants.deletingSuccess);
        navigateToFeedbackListScreen();
      } else {
        _showSnackBar(result);
      }

      setState(() {
        deleting = false;
      });
    }

  }

  Future<void> saveFeedback() async {
    FeedbackCustom tempFeedback = FeedbackCustom(
        id: editFeedback.id,
        createDate: editFeedback.createDate,
        userId: editFeedback.userId,
        status: chosenStatus,
        topic: chosenTopic,
        messages: editFeedback.messages,
        finishDate: finishDate
    );

    setState(() {
      saving = true;
    });

    if (tempFeedback.checkBeforeSaving()){
      String result = await tempFeedback.publishToDb(null);

      if (result == SystemConstants.successConst){
        _showSnackBar(SystemConstants.savingSuccess);
        await initialization(fromDb: false);
      } else {
        _showSnackBar(result);
      }
    } else {
      _showSnackBar(FeedbackConstants.feedbackNotFillError);
    }

    setState(() {
      saving = false;
    });

  }
}
