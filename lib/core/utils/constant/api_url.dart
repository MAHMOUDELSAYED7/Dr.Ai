import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvManager {
  EnvManager._();

  static String pyDrAi = dotenv.env['PY_DR_AI']!;
  static String googleMapApiKey = dotenv.env['MAP_API_KEY']!;
  static String placeSuggetion = dotenv.env['PLACE_SUGGESTION_BASE_URL']!;
  static String placeLocation = dotenv.env['PLACE_LOCATION_BASE_URL']!;
  static String directions = dotenv.env['PLACE_DIRECTIONS_BASE_URL']!;
  static String nearestHospital = dotenv.env['NEAREST_HOSPITAL_BASE_URL']!;
  static String generativeModelApiKey = dotenv.env['GENERATIVE_MODEL_API_KEY']!;
  static String generativeModelVersion =
      dotenv.env['GENERATIVE_MODEL_VERSION']!;
  static String medicalTips = dotenv.env['DAILY_TIPS_BASE_URL']!;
  static String medicalRecord =
      dotenv.env['MEDICAL_RECORD_AND_CONCLUSION_BASE_URL']!;
  static String medicalRecordPdfBackend =
      dotenv.env['MEDICAL_RECORD_PDF_BACKEND']!;
  static String defaultMedicalRecordID =
      dotenv.env['DEFAULT_MEDICAL_RECORD_ID']!;
}
