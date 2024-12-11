import 'package:admin_dvij/ads/ad_class.dart';
import 'package:admin_dvij/constants/ads_constants.dart';
import 'package:flutter/material.dart';
import '../design_elements/cards_elements.dart';

class AdsListScreen extends StatefulWidget {
  final List<AdClass> adsList;
  final void Function(int index) editAds;
  const AdsListScreen({required this.adsList, required this.editAds,  Key? key}) : super(key: key);

  @override
  State<AdsListScreen> createState() => _AdsListScreenState();
}

class _AdsListScreenState extends State<AdsListScreen> {
  @override
  Widget build(BuildContext context) {
     if (widget.adsList.isNotEmpty) {

       return ListView.builder(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        itemCount: widget.adsList.length,
        itemBuilder: (context, index) {

          AdClass tempAd = widget.adsList[index];

          return CardsElements.getCard(
              context: context,
              onTap: () => widget.editAds(index), // Передаем index через замыкание
              imageUrl: tempAd.imageUrl,
              widget: tempAd.getInfoWidget(context: context),
              leftTopTag: tempAd.status.getStatusWidget(context: context)
          );

        }
    );
     } else {
       return Center(
        child: Text(AdsConstants.emptyAdList, style: Theme.of(context).textTheme.bodyMedium,),
      );
     }
  }
}
