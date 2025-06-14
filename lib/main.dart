import 'package:dr_ai/core/cache/cache.dart';
import 'package:dr_ai/core/utils/helper/error_screen.dart';
import 'package:dr_ai/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/source/local/chat_message_model.dart';

Future<void> main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorScreen(
      errorMessage: details.exception.toString(),
      stackTrace: details.stack.toString(),
    );
  };

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await CacheData.cacheDataInit();
  await Hive.initFlutter();
  Hive.registerAdapter(ChatMessageModelAdapter());
  runApp(const MyApp());
}
