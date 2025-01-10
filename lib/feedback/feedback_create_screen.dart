import 'dart:io';
import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:admin_dvij/feedback/feedback_message.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/buttons_constants.dart';
import '../constants/system_constants.dart';
import '../database/database_class.dart';
import '../database/image_picker.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/button_state_enum.dart';
import '../design_elements/elements_of_design.dart';
import '../logs/action_class.dart';
import '../logs/entity_enum.dart';
import '../logs/log_class.dart';
import '../system_methods/system_methods_class.dart';
import '../users/admin_user/admin_user_class.dart';
import 'feedback_list_class.dart';
import 'feedback_topic.dart';
import 'feedback_topic_picker.dart';

class FeedbackCreateScreen extends StatefulWidget {
  const FeedbackCreateScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackCreateScreen> createState() => _FeedbackCreateScreenState();
}

class _FeedbackCreateScreenState extends State<FeedbackCreateScreen> {

  bool loading = false;
  bool saving = false;

  SystemMethodsClass sm = SystemMethodsClass();
  FeedbackListClass fl = FeedbackListClass();
  ImagePickerService imagePickerService = ImagePickerService();

  File? imageFile;

  FeedbackCustom feedback = FeedbackCustom.empty();
  FeedbackMessage message = FeedbackMessage.empty();
  FeedbackTopic chosenTopic = FeedbackTopic();

  AdminUserClass currentAdmin = AdminUserClass.empty();

  TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {
    setState(() {
      loading = true;
    });

    currentAdmin = await currentAdmin.getCurrentUser(fromDb: fromDb);
    answerController.text = '';
    feedback = FeedbackCustom.empty();
    feedback.userId = currentAdmin.uid;
    chosenTopic = feedback.topic;
    imageFile = null;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Условие для мобильной версии

    // 'Обращение от ${sm.formatDateTimeToHumanViewWithClock(editFeedback.createDate)}'

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            FeedbackConstants.feedbackPathCreatePageHeadline
        ),

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            navigateToFeedbackListScreen();
          },
        ),
      ),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: SystemConstants.loadingDefault)
          else if (saving) const LoadingScreen(loadingText: SystemConstants.saving)
            else SingleChildScrollView(
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
                          FeedbackConstants.feedbackPathCreatePageHeadline,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 10,),

                        Text(
                          'От ${sm.formatDateTimeToHumanView(feedback.createDate)}',
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                          textAlign: TextAlign.start,
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildAdaptiveRow(
                            isMobile: isMobile,
                            children: [
                              feedback.status.getStatusFieldWidget(
                                  canEdit: false,
                                  context: context,
                                  onTap: () {}
                              ),
                            ]
                        ),

                        chosenTopic.getTopicFieldWidget(
                            canEdit: true,
                            context: context,
                            onTap: () async {
                              await chooseTopic();
                            }
                        ),

                        const SizedBox(height: 20,),

                        if (imageFile != null) ElementsOfDesign.getImageFromFileWithXButton(
                            image: imageFile!,
                            onTap: (){
                              setState(() {
                                imageFile = null;
                              });
                            }
                        ),

                        if (imageFile != null) const SizedBox(height: 20),

                        ElementsOfDesign.buildTextField(
                            controller: answerController,
                            labelText: SystemConstants.enterTextMessage,
                            maxLines: null,
                            canEdit: true,
                            icon: FontAwesomeIcons.paperclip,
                            context: context,
                            onIconTap: () async {
                              await _pickImage();

                            }
                        ),

                        const SizedBox(height: 20,),

                        ElementsOfDesign.buildAdaptiveRow(
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
                      ],
                    ),
                  ),
                ),
              )
        ],
      ),

    );
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

  Future<void> sendMessage({required FeedbackCustom tempFeedback}) async {
    FeedbackMessage tempMessage = FeedbackMessage(
        id: '',
        sendTime: DateTime.now(),
        feedbackId: tempFeedback.id,
        userId: tempFeedback.userId,
        senderId: currentAdmin.uid,
        messageText: answerController.text,
        imageUrl: ''
    );

    if (tempMessage.checkMessageBeforeSending()){

      setState(() {
        saving = true;
      });

      String result = await tempMessage.publishToDb(imageFile);

      if (result == SystemConstants.successConst){
        _showSnackBar(FeedbackConstants.feedbackPublishSuccess);
        navigateToFeedbackListScreen();
      } else {
        _showSnackBar(result);
      }

    } else {
      _showSnackBar(FeedbackConstants.feedbackNotFillError);
    }

  }

  Future<void> saveFeedback() async {
    FeedbackCustom tempFeedback = FeedbackCustom(
        id: feedback.id,
        createDate: feedback.createDate,
        userId: feedback.userId,
        status: feedback.status,
        topic: chosenTopic,
        messages: feedback.messages,
        finishDate: feedback.finishDate
    );

    setState(() {
      saving = true;
    });



    // Если Id не задан
    if (tempFeedback.id == '') {
      DatabaseClass db = DatabaseClass();
      // Генерируем ID
      String? idFeedback = db.generateKey();

      // Если ID по какой то причине не сгенерировался
      // генерируем вручную
      tempFeedback.id = idFeedback ?? 'noId_${tempFeedback.createDate.toString()}';

      // Публикуем запись в логе, если создание
      await LogCustom.empty().createAndPublishLog(
          entityId: tempFeedback.id,
          entityEnum: EntityEnum.feedback,
          actionEnum: ActionEnum.create,
          creatorId: currentAdmin.uid
      );
    }

    if (tempFeedback.checkBeforeSaving() && answerController.text.isNotEmpty){
      String result = await tempFeedback.publishToDb(null);

      if (result == SystemConstants.successConst){

        await sendMessage(tempFeedback: tempFeedback);

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

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void navigateToFeedbackListScreen() {
    sm.popBackToPreviousPageWithResult(context: context, result: feedback);
  }

  Future<void> chooseTopic() async{
    final results = await sm.getPopup(context: context, page: const FeedbackTopicPicker());
    if (results != null){
      setState(() {
        chosenTopic = results;
      });
    }
  }

}
