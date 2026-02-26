import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  runApp(const ProviderScope(child: MyApp()));

  Future.microtask(() async {
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("Env loaded");

      await checkB2Connection();
    } catch (e) {
      debugPrint("Background init error: $e");
    }
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading:
          () => const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
      error:
          (err, stack) => const MaterialApp(
            home: Scaffold(body: Center(child: Text("Something went wrong"))),
          ),
      data: (authState) {
        final materialTheme = MaterialTheme(ThemeData.light().textTheme);

        return MaterialApp(
          title: 'SRV Paperless',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'BaiJamjuree',
            colorScheme: materialTheme.light().colorScheme,
          ),
          home:
              authState.currentUser != null
                  ? const UserHomePage()
                  : const LoginScreen(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
