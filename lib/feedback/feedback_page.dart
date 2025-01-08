import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/feedback/feedback_message.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/admin_user/admin_user_class.dart';
import 'package:admin_dvij/users/admin_user/admin_users_list.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/screen_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/elements_of_design.dart';
import '../navigation/drawer_custom.dart';
import '../users/simple_users/simple_user.dart';

class FeedbackPage extends StatefulWidget {
  final int initialIndex;
  const FeedbackPage({this.initialIndex = 0, Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {

  bool loading = false;
  FeedbackListClass feedbackListClass = FeedbackListClass();
  SystemMethodsClass sm = SystemMethodsClass();

  List<FeedbackCustom> feedbackList = [];

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {

    setState(() {
      loading = true;
    });

    feedbackList = await feedbackListClass.getDownloadedList(fromDb: fromDb);

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        //initialIndex: widget.initialIndex,
        length: 3,
        child: Stack(
          children: [
            if (loading) const LoadingScreen()
            //else if (deleting) const LoadingScreen(loadingText: SystemConstants.deleting)
            else Scaffold(
                appBar: AppBar(
                  title: const Text(ScreenConstants.feedbackPage),
                  actions: [

                    // КНОПКИ В AppBar

                    /*Row(
                      children: [

                        // Кнопка сброса фильтра

                        if (chosenLocation.location != ImageLocationEnum.notChosen)
                          ElementsOfDesign.linkButton(
                              method: () async {
                                await resetFilter();
                              },
                              text: ButtonsConstants.reset,
                              context: context
                          ),

                        if (chosenLocation.location != ImageLocationEnum.notChosen)
                          const SizedBox(width: 10,),

                        // Кнопка "Фильтр"

                        IconButton(
                          onPressed: () async {
                            await filterPromos();
                          },
                          icon: Icon(
                            FontAwesomeIcons.filter,
                            size: 15,
                            color: chosenLocation.location != ImageLocationEnum.notChosen ? AppColors.brandColor : AppColors.white,),
                        ),
                      ],
                    ),*/

                    // Кнопка "Обновить"
                    IconButton(
                      onPressed: () async {
                        await initialization(fromDb: true);
                      },
                      icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
                    ),

                  ],

                  // ТАБЫ

                  bottom: TabBar(
                    tabs: [
                      ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.images, text: 'Поступившие'),
                      ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.solidFileImage, text: 'В работе'),
                      ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.solidFileImage, text: 'Завершенные'),
                    ],
                  ),
                ),

                // СОДЕРЖИМОЕ СТРАНИЦЫ

                body: Column(
                  children: [
                    /*ElementsOfDesign.getSearchBar(
                        context: context,
                        textController: searchingController,
                        labelText: ImagesConstants.searchFieldHint,
                        icon: FontAwesomeIcons.searchengin,
                        onChanged: (value) async {
                          await searchingAction(text: value);
                        },
                        onClean: () async{
                          await searchingAction(text: '');
                        }
                    ),*/
                    Expanded(
                      child: TabBarView(
                          children: [

                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (FeedbackCustom feedback in feedbackList) Column(
                                    children: [
                                      feedback.getFeedbackWidget()
                                    ],
                                  )
                                ],
                              ),
                            ),

                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (FeedbackCustom feedback in feedbackList) Column(
                                    children: [
                                      Text(feedback.id),
                                      Text(feedback.status.toString(translate: true)),
                                      for (FeedbackMessage message in feedback.messages) Column(
                                        children: [
                                          Text(message.messageText),
                                          ElementsOfDesign.imageWithTags(imageUrl: message.imageUrl, width: 100, height: 100)
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),

                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (FeedbackCustom feedback in feedbackList) Column(
                                    children: [
                                      Text(feedback.id),
                                      Text(feedback.status.toString(translate: true)),
                                      for (FeedbackMessage message in feedback.messages) Column(
                                        children: [
                                          Text(message.messageText),
                                          ElementsOfDesign.imageWithTags(imageUrl: message.imageUrl, width: 100, height: 100)
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),

                            /*ImagesListScreen(
                                imagesList: allImagesList,
                                deleteImage: (index) async {
                                  await deleteImage(allImagesList[index]);
                                },
                                onTapImage: (index) async {
                                  await goToEntity(image: allImagesList[index], indexTabPage: 0);
                                }
                            ),

                            ImagesListScreen(
                                imagesList: unusedImagesList,
                                deleteImage: (index) async {
                                  await deleteImage(unusedImagesList[index]);
                                },
                                onTapImage: (index) async {
                                  await goToEntity(image: unusedImagesList[index], indexTabPage: 1);
                                }
                            ),*/

                          ]
                      ),
                    ),
                  ],
                ),
                drawer: const CustomDrawer(),
              ),
          ],
        )
    );
  }
}
