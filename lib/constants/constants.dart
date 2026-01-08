import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String api_key = dotenv.get(['API_KEY'][0]);
}
