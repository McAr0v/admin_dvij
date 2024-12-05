import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/ads/ads_list_class.dart';
import 'package:admin_dvij/design/loading_screen.dart';
import 'package:admin_dvij/navigation/drawer_custom.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/screen_constants.dart';
import '../design/app_colors.dart';

class AdsPage extends StatefulWidget {
  const AdsPage({Key? key}) : super(key: key);

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {

  bool loading = false;

  AdsList adsList = AdsList();
  List<AdClass> activeAdsList = [];
  List<AdClass> draftAdsList = [];
  List<AdClass> completedAdsList = [];

  @override
  void initState() {
    super.initState();
    initialization();
  }

  Future<void> initialization({bool fromDb = false}) async{

    setState(() {
      loading = true;
    });

    activeAdsList = await adsList.getActiveAds(fromDb: fromDb);
    draftAdsList = await adsList.getDraftAds(fromDb: fromDb);
    completedAdsList = await adsList.getCompletedAds(fromDb: fromDb);

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Stack(
          children: [
            if (loading) LoadingScreen(loadingText: 'Идет загрузка рекламы',),
            if (!loading) Scaffold(
              appBar: AppBar(
                title: Text(
                  ScreenConstants.adsPage,
                ),
                actions: [

                  // КНОПКИ В AppBar

                  // Кнопка "Фильтр"
                  IconButton(
                    onPressed: () async {
                      //await saveCity(null);
                    },
                    icon: const Icon(FontAwesomeIcons.filter, size: 15, color: AppColors.white,),
                  ),

                  // Кнопка "Обновить"
                  IconButton(
                    onPressed: () async {
                      await initialization(fromDb: true);
                    },
                    icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 15, color: AppColors.white,),
                  ),

                  // Кнопка "Сорировать"
                  IconButton(
                    onPressed: (){
                      //sorting();
                    },
                    icon: Icon(/*upSorting ? FontAwesomeIcons.sortUp :*/ FontAwesomeIcons.sortDown, size: 15, color: AppColors.white,),
                  ),

                  // Кнопка "Создать"
                  IconButton(
                    onPressed: () async {
                      //await saveCity(null);
                    },
                    icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
                  ),



                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.fire, size: 15,),
                          SizedBox(width: 10,),
                          Text('Активные', style: TextStyle(fontSize: 13),),

                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.fileLines, size: 15,),
                          SizedBox(width: 10, ),
                          Text('Черновики', style: TextStyle(fontSize: 13),),

                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.circleCheck, size: 15,),
                          SizedBox(width: 10,),
                          Text('Завершенные', style: TextStyle(fontSize: 13),),

                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                  children: [
                    ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        itemCount: activeAdsList.length,
                        itemBuilder: (context, index) {

                          AdClass tempAd = activeAdsList[index];

                          return tempAd.getCard(context: context, onTap: (){});

                        }
                    ),
                    ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        itemCount: draftAdsList.length,
                        itemBuilder: (context, index) {

                          AdClass tempAd = draftAdsList[index];
                          return  tempAd.getCard(context: context, onTap: (){});

                        }
                    ),
                    ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        itemCount: completedAdsList.length,
                        itemBuilder: (context, index) {

                          AdClass tempAd = activeAdsList[index];

                          return tempAd.getCard(context: context, onTap: (){});

                        }
                    ),
                  ]
              ),
              drawer: const CustomDrawer(),
            ),
          ],
        )
    );
  }

}
