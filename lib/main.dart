import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:srv_paperless/theme/theme.dart';
import 'package:srv_paperless/views/login/login_screen.dart';
import 'package:srv_paperless/views/user/user_homepage.dart';
import 'package:srv_paperless/views/user/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("Env loaded");
  } catch (e) {
    print("Error: can't load env: $e");
  }

  runApp(ProviderScope(child: MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = MaterialTheme(ThemeData.light().textTheme);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: materialTheme.light().colorScheme,
        textTheme: GoogleFonts.baiJamjureeTextTheme(
          Theme.of(context).textTheme
        )
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/user_home': (context) => const UserHomePage(),
        '/user_profile':(context) =>const UserProfile()
      },
    );
  }
}
