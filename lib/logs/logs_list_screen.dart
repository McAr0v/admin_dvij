import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/logs/entity_enum.dart';
import 'package:admin_dvij/logs/log_class.dart';
import 'package:admin_dvij/logs/log_entity_picker.dart';
import 'package:admin_dvij/logs/log_list_class.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:admin_dvij/users/simple_users/simple_user_screen.dart';
import 'package:admin_dvij/users/simple_users/simple_users_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/buttons_constants.dart';
import '../constants/screen_constants.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../navigation/drawer_custom.dart';
import '../users/simple_users/simple_user.dart';

class LogsListScreen extends StatefulWidget {
  const LogsListScreen({Key? key}) : super(key: key);

  @override
  State<LogsListScreen> createState() => _LogsListScreenState();
}

class _LogsListScreenState extends State<LogsListScreen> {

  LogListClass logListClass = LogListClass();
  SystemMethodsClass sm = SystemMethodsClass();

  TextEditingController searchingText = TextEditingController();
  LogEntity filterEntity = LogEntity(entity: EntityEnum.notChosen);

  @override
  void initState() {
    initialization();
    super.initState();
  }

  bool loading = false;
  List<LogCustom> logsList = [];

  Future<void> initialization({bool fromDb = false}) async {
    setState(() {
      loading = true;
    });

    logsList = await logListClass.getNeededLogs(fromDb: fromDb, entity: filterEntity, searchingText: searchingText.text);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(ScreenConstants.logs),
        actions: [

          // КНОПКИ В AppBar

          Row(
            children: [

              // Кнопка сброса фильтра

              if (filterEntity.entity != EntityEnum.notChosen)
                ElementsOfDesign.linkButton(
                    method: () async {
                      await resetFilter();
                    },
                    text: ButtonsConstants.reset,
                    context: context
                ),

              if (filterEntity.entity != EntityEnum.notChosen)
                const SizedBox(width: 10,),

              // Кнопка "Фильтр"

              IconButton(
                onPressed: () async {
                  await filterLogs();
                },
                icon: Icon(
                  FontAwesomeIcons.filter,
                  size: 15,
                  color: filterEntity.entity != EntityEnum.notChosen ? AppColors.brandColor : AppColors.white,),
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



        ],
      ),

      drawer: const CustomDrawer(),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(),
          if (!loading) Column(
            children: [
              // СПИСОК

              ElementsOfDesign.getSearchBar(
                  context: context,
                  textController: searchingText,
                  labelText: 'Название, id, создатель, имя сущности...',
                  icon: FontAwesomeIcons.searchengin,
                  onChanged: (value) async {
                    await searchingAction(text: value);
                  },
                  onClean: () async{
                    await searchingAction(text: '');
                  }
              ),

              Expanded(
                child: Column(
                  children: [

                    if (logsList.isEmpty) const Expanded(
                        child: Center(
                          child: Text(SystemConstants.emptyList),
                        )
                    ),

                    if (logsList.isNotEmpty) Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                            itemCount: logsList.length,
                            itemBuilder: (context, index) {

                              LogCustom tempLog = logsList[index];

                              return Card(
                                color: AppColors.greyOnBackground,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      ElementsOfDesign.getTag(
                                          context: context,
                                          text: tempLog.action.toString(translate: true)
                                      ),

                                      const SizedBox(height: 10,),

                                      GestureDetector(
                                          onTap: () async {
                                            await goToEntityPage(log: tempLog);
                                          },
                                          child: Text(
                                            '${tempLog.entity.toString(translate: true)} - ${tempLog.entity.getEntityName(id: tempLog.id)}',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline),
                                          )
                                      ),

                                      Text(
                                        tempLog.id,
                                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                      ),

                                      const SizedBox(height: 10,),

                                      GestureDetector(
                                        onTap: () async {
                                          await goToCreatorPage(creatorId: tempLog.creatorId);
                                        },
                                          child: Text(
                                              tempLog.getCreatorName(),
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline),
                                          )
                                      ),

                                      Text(
                                          sm.formatDateTimeToHumanViewWithClock(tempLog.date),
                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: AppColors.greyText),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                            }
                        )
                    )

                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> goToEntityPage({required LogCustom log}) async {
    dynamic page = log.getEntityPage();

    if (page != null) {
      final result = await sm.pushToPageWithResult(context: context, page: page);

      if (result != null) {
        await initialization();
      }
    } else {
      _showSnackBar('Сущность не найдена');
    }
  }

  Future<void> goToCreatorPage({required String creatorId}) async {

    SimpleUsersList simpleUsersList = SimpleUsersList();

    SimpleUser user = simpleUsersList.getEntityFromList(creatorId);

    if (user.uid.isNotEmpty) {
      final result = await sm.pushToPageWithResult(context: context, page: SimpleUserScreen(simpleUser: user));

      if (result != null) {
        await initialization();
      }

    } else {
      _showSnackBar('Пользователь не найден');
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

  Future<void> filterLogs() async{

    final result = await sm.getPopup(
        context: context,
        page: const LogEntityPicker()
    );

    if (result != null){
      filterEntity = result;

      await initialization(fromDb: false);

    }
  }

  Future<void> searchingAction({required String text}) async {
    searchingText.text = text;

    await initialization(
        fromDb: false
    );
  }

  Future<void> resetFilter () async {
    setState(() {
      filterEntity = LogEntity(entity: EntityEnum.notChosen);
      searchingText.text = '';
    });

    await initialization(fromDb: false);

  }
}
