import 'package:flutter/material.dart';
import 'app_colors.dart';

class LoadingScreen extends StatelessWidget {
  final String loadingText;

  const LoadingScreen({Key? key, this.loadingText = 'Подожди чуть-чуть) Идет загрузка'}) : super(key: key);

  // ---- ВИДЖЕТ ЭКРАНА ЗАГРУЗКИ ----

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyOnBackground.withOpacity(0.5),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 15.0),
            Text(
              loadingText,
              style: Theme.of(context).textTheme.bodyMedium,
              softWrap: true,
            )
          ],
        ),
      ),
    );
  }
}