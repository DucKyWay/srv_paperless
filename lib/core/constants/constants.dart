import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static final String apiKey = dotenv.get(['API_KEY'][0]);
  static final String imagePath = "assets/images";
}
