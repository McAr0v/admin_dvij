import 'package:admin_dvij/logs/log_class.dart';
import 'package:admin_dvij/logs/log_list_class.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/screen_constants.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../navigation/drawer_custom.dart';

class LogsListScreen extends StatefulWidget {
  const LogsListScreen({Key? key}) : super(key: key);

  @override
  State<LogsListScreen> createState() => _LogsListScreenState();
}

class _LogsListScreenState extends State<LogsListScreen> {

  LogListClass logListClass = LogListClass();
  SystemMethodsClass sm = SystemMethodsClass();

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

    logsList = await logListClass.getDownloadedList(fromDb: fromDb);

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
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tempLog.id),
                                      Text(tempLog.creatorId),
                                      Text(tempLog.action.toString(translate: true)),
                                      Text(tempLog.entity.toString(translate: true)),
                                      Text(sm.formatDateTimeToHumanViewWithClock(tempLog.date)),
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
}
