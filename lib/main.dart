import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srv_paperless/core/theme/theme.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/firebase_options.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/views/login/login_screen.dart';
import 'package:srv_paperless/views/user/user_home_screen.dart';
import 'package:srv_paperless/core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Env loaded");
  } catch (e) {
    debugPrint("Error: can't load env: $e");
  }

  await checkB2Connection();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialTheme = MaterialTheme(ThemeData.light().textTheme);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'SRV Paperless',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: materialTheme.light().colorScheme,
        textTheme: GoogleFonts.baiJamjureeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home:
          authState.isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : (authState.currentUser != null
                  ? const UserHomePage()
                  : const LoginScreen()),
      routes: AppRoutes.routes,
    );
  }
}
