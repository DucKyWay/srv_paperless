import 'package:flutter/material.dart';

import '../../views/login/login_screen.dart';
import '../../views/user/projects/project_create_request_screen.dart';
import '../../views/user/projects/project_draft_pending_screen.dart';
import '../../views/user/user_home_screen.dart';
import '../../views/user/user_profile_screen.dart';

class AppRoutes {
  // Auth
  static const login = '/login';

  // User
  static const userHome = '/user/home';
  static const userProfile = '/user/profile';

  // Project / Draft
  static const projectDraft = '/project/draft';

  // ===== routes =====
  static Map<String, WidgetBuilder> get routes => {
    userHome: (context) => const UserHomePage(),
    userProfile: (context) => const UserProfile(),
    login: (context) => const LoginScreen(),
    projectDraft: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        if (args == 'create') return CreateRequestScreen();
        return CreateRequestScreen(draftId: args);
      }
      return const RequestDraftAndPendingScreen();
    }
  };
}