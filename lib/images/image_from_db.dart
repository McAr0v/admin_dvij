import 'package:admin_dvij/images/image_location.dart';

class ImageFromDb {
  String id;
  String url;
  ImageLocation location;

  ImageFromDb({required this.id, required this.url, required this.location});

  factory ImageFromDb.empty(){
    return ImageFromDb(
        id: '',
        url: '',
        location: ImageLocation()
    );
  }

  Future<String> deleteFromDb() async {
    String result = '';

    return result;
  }

}