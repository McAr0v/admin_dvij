import 'package:admin_dvij/constants/feedback_constants.dart';
import 'package:admin_dvij/feedback/feedback_class.dart';
import 'package:admin_dvij/feedback/feedback_create_screen.dart';
import 'package:admin_dvij/feedback/feedback_list_class.dart';
import 'package:admin_dvij/feedback/feedback_list_screen.dart';
import 'package:admin_dvij/feedback/feedback_tab_enum.dart';
import 'package:admin_dvij/feedback/feedback_topic.dart';
import 'package:admin_dvij/feedback/feedback_topic_picker.dart';
import 'package:admin_dvij/feedback/feedback_view_chat_screen.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../constants/screen_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../design_elements/elements_of_design.dart';
import '../navigation/drawer_custom.dart';

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

  TextEditingController searchingController = TextEditingController();

  FeedbackTopic filterTopic = FeedbackTopic();

  List<FeedbackCustom> receivedFeedbackList = [];
  List<FeedbackCustom> inWorkFeedbackList = [];
  List<FeedbackCustom> completedFeedbackList = [];

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization({bool fromDb = false}) async {

    setState(() {
      loading = true;
    });

    receivedFeedbackList = await feedbackListClass.getNeededList(topic: filterTopic, tab: FeedbackTabEnum.received, searchingText: searchingController.text, fromDb: fromDb);
    inWorkFeedbackList = await feedbackListClass.getNeededList(topic: filterTopic, tab: FeedbackTabEnum.inWork, searchingText: searchingController.text, fromDb: fromDb);
    completedFeedbackList = await feedbackListClass.getNeededList(topic: filterTopic, tab: FeedbackTabEnum.completed, searchingText: searchingController.text, fromDb: fromDb);

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: widget.initialIndex,
        length: 3,
        child: Stack(
          children: [
            if (loading) const LoadingScreen()
            else Scaffold(
                appBar: AppBar(
                  title: const Text(ScreenConstants.feedbackPage),
                  actions: [

                    // КНОПКИ В AppBar

                    Row(
                      children: [

                        // Кнопка сброса фильтра

                        if (filterTopic.topic != FeedbackTopicEnum.notChosen)
                          ElementsOfDesign.linkButton(
                              method: () async {
                                await resetFilter();
                              },
                              text: ButtonsConstants.reset,
                              context: context
                          ),

                        if (filterTopic.topic != FeedbackTopicEnum.notChosen)
                          const SizedBox(width: 10,),

                        // Кнопка "Фильтр"

                        IconButton(
                          onPressed: () async {
                            await filterFeedback();
                          },
                          icon: Icon(
                            FontAwesomeIcons.filter,
                            size: 15,
                            color: filterTopic.topic != FeedbackTopicEnum.notChosen ? AppColors.brandColor : AppColors.white,),
                        ),
                      ],
                    ),

                    // Кнопка "Обновить"
                    IconButton(
                      onPressed: () async {
                        await initialization(fromDb: true);
                      },
                      icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
                    ),

                    // Кнопка "Создать"
                    IconButton(
                      onPressed: () async {
                        await createFeedback();
                      },
                      icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
                    ),

                  ],

                  // ТАБЫ

                  bottom: TabBar(
                    tabs: [
                      ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.envelopeOpenText, text: FeedbackConstants.feedbackReceivedTab),
                      ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.spinner, text: FeedbackConstants.feedbackReceivedTab),
                      ElementsOfDesign.getTabWithIcon(icon: FontAwesomeIcons.flagCheckered, text: FeedbackConstants.feedbackCompletedTab),
                    ],
                  ),
                ),

                // СОДЕРЖИМОЕ СТРАНИЦЫ

                body: Column(
                  children: [
                    ElementsOfDesign.getSearchBar(
                        context: context,
                        textController: searchingController,
                        labelText: FeedbackConstants.feedbackSearchBarText,
                        icon: FontAwesomeIcons.searchengin,
                        onChanged: (value) async {
                          await searchingAction(text: value);
                        },
                        onClean: () async{
                          await searchingAction(text: '');
                        }
                    ),
                    Expanded(
                      child: TabBarView(
                          children: [

                            FeedbackListScreen(
                                feedbackList: receivedFeedbackList,
                                onTapFeedback: (index) async {
                                  await goToEntity(feedback: receivedFeedbackList[index], indexTabPage: 0);
                                }
                            ),

                            FeedbackListScreen(
                                feedbackList: inWorkFeedbackList,
                                onTapFeedback: (index) async {
                                  await goToEntity(feedback: inWorkFeedbackList[index], indexTabPage: 1);
                                }
                            ),

                            FeedbackListScreen(
                                feedbackList: completedFeedbackList,
                                onTapFeedback: (index) async {
                                  await goToEntity(feedback: completedFeedbackList[index], indexTabPage: 2);
                                }
                            ),
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

  Future<void> goToEntity({required FeedbackCustom feedback, required int indexTabPage}) async {

    final result = await sm.pushToPageWithResult(context: context, page: FeedbackViewChatScreen(feedback: feedback));

    if (result != null) {
      await initialization();
    }

  }

  Future<void> createFeedback() async {

    final result = await sm.pushToPageWithResult(context: context, page: const FeedbackCreateScreen());

    if (result != null) {
      await initialization();
    }
  }

  Future<void> searchingAction({required String text}) async {
    searchingController.text = text;

    await initialization(
        fromDb: false
    );
  }

  Future<void> resetFilter() async{

    filterTopic = FeedbackTopic();
    searchingController.text = '';

    await initialization(fromDb: false);
  }

  Future<void> filterFeedback() async{

    final result = await sm.getPopup(
        context: context,
        page: const FeedbackTopicPicker()
    );

    if (result != null){

      filterTopic = result;
      await initialization(fromDb: false);

    }
  }

}
