import 'package:admin_dvij/constants/buttons_constants.dart';
import 'package:admin_dvij/constants/privacy_constants.dart';
import 'package:admin_dvij/database/image_uploader.dart';
import 'package:admin_dvij/design_elements/elements_of_design.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_class.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_list_class.dart';
import 'package:admin_dvij/privacy_policy/privacy_policy_view_edit_screen.dart';
import 'package:admin_dvij/system_methods/system_methods_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/screen_constants.dart';
import '../constants/system_constants.dart';
import '../design/app_colors.dart';
import '../design/loading_screen.dart';
import '../navigation/drawer_custom.dart';

class PrivacyPolicyListScreen extends StatefulWidget {
  const PrivacyPolicyListScreen({super.key});

  @override
  State<PrivacyPolicyListScreen> createState() => _PrivacyPolicyListScreenState();
}

class _PrivacyPolicyListScreenState extends State<PrivacyPolicyListScreen> {
  
  ImageUploader im = ImageUploader();

  bool loading = false;
  bool deleting = false;

  SystemMethodsClass sm = SystemMethodsClass();

  PrivacyPolicyList privacyPolicyListClass = PrivacyPolicyList();

  List<PrivacyPolicyClass> currentList = [];

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization ({bool fromDb = false}) async{

    setState(() {
      loading = true;
    });
    
    await im.getAllImages('admins');
    await im.getAllImages('events');

    currentList = [];

    currentList = await privacyPolicyListClass.getDownloadedList(fromDb: fromDb);

    if (fromDb) {
      //  Если обновляли с БД, выводим оповещение
      _showSnackBar(SystemConstants.refreshSuccess);
    }

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(ScreenConstants.privacyPage),
        actions: [

          // КНОПКИ В AppBar

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
              await goToView(
                  privacy: null,
                  canEdit: true,
                  isNew: true
              );
            },
            icon: const Icon(FontAwesomeIcons.plus, size: 15, color: AppColors.white,),
          ),

        ],
      ),

      drawer: const CustomDrawer(),

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: PrivacyConstants.privacyLoading)
          else if (deleting) const LoadingScreen(loadingText: 'Удаление')
          else Column(
            children: [

              if (currentList.isEmpty) const Expanded(
                  child: Center(
                    child: Text(SystemConstants.emptyList),
                  )
              ),

              if (currentList.isNotEmpty) Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {

                        PrivacyPolicyClass tempPrivacy = currentList[index];

                        return GestureDetector(
                          onTap: () async {
                            await goToView(
                                privacy: tempPrivacy,
                                canEdit: tempPrivacy.isActive() ? false : true,
                                isNew: false
                            );
                          },
                          child: Card(
                            color: AppColors.greyOnBackground,
                            child: Padding(
                                padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  tempPrivacy.status.getStatusWidget(context: context),

                                  const SizedBox(width: 10,),

                                  Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Политика от ${tempPrivacy.getFolderId()}'),
                                          Text(tempPrivacy.id, style: Theme.of(context).textTheme.labelMedium,),
                                        ],
                                      )
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        await goToView(
                                            privacy: tempPrivacy,
                                            canEdit: true,
                                            isNew: true
                                        );
                                      },
                                      icon: const Icon(FontAwesomeIcons.copy, size: 15,)
                                  ),

                                  if (!tempPrivacy.isActive()) const SizedBox(width: 10,),

                                  if (!tempPrivacy.isActive())IconButton(
                                      onPressed: () async {
                                        await deletePrivacy(privacy: tempPrivacy);
                                      },
                                      icon: const Icon(FontAwesomeIcons.trash, size: 15,)
                                  ),
                                ],
                              )
                            ),
                          ),
                        );

                      }
                  )
              )

            ],
          ),
        ],
      ),
    );
  }

  Future<void> deletePrivacy({required PrivacyPolicyClass privacy}) async {
    bool? deleteAccess = await ElementsOfDesign.exitDialog(
        context,
        'Восстановить данные будет нельзя',
        ButtonsConstants.delete,
        ButtonsConstants.cancel,
        'Удалить данную политику конфиденциальности?'
    );

    if (deleteAccess != null && deleteAccess) {
      setState(() {
        deleting = true;
      });

      String result = await privacy.deleteFromDb();
      if (result == SystemConstants.successConst) {
        _showSnackBar('Удаление прошло успшено');
        await initialization();
      } else {
        _showSnackBar(result);
      }
      setState(() {
        deleting = false;
      });
    }
  }

  Future<void> goToView ({required PrivacyPolicyClass? privacy, required bool canEdit, required bool isNew}) async {
    final result = await sm.pushToPageWithResult(
        context: context,
        page: PrivacyPolicyViewEditScreen(
          canEdit: canEdit,
          copiedPolicy: privacy,
          isNew: isNew,
        )
    );

    if (result != null) {
      await initialization(fromDb: false);
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

}
