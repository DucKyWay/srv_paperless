import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srv_paperless/core/theme/theme.dart';
import 'package:srv_paperless/data/minio.dart';
import 'package:srv_paperless/firebase_options.dart';
import 'package:srv_paperless/views/login/login_screen.dart';
import 'package:srv_paperless/views/user/user_home_screen.dart';
import 'package:srv_paperless/core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Env loaded");
  } catch (e) {
    debugPrint("Error: can't load env: $e");
  }

  await checkB2Connection();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData.light().textTheme);
    return MaterialApp(
      title: 'SRV Paperless',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: materialTheme.light().colorScheme,
        textTheme: GoogleFonts.baiJamjureeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: StreamBuilder<fb_auth.User?>(
        stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const UserHomePage();
          }
          return const LoginScreen();
        },
      ),
      routes: AppRoutes.routes,
    );
  }
}
