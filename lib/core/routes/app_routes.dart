import 'package:flutter/material.dart';
import 'package:srv_paperless/views/admin/admin_home_screen.dart';
import 'package:srv_paperless/views/user/budgets/project_manage_screen.dart';
import 'package:srv_paperless/views/user/budgets/project_request_screen.dart';
import 'package:srv_paperless/views/user/projects/project_create_screen.dart';

import '../../views/login/login_screen.dart';
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
  static const projectCreate = '/project/create';
  static const projectDraft = '/project/draft';
  static const projectRequest = '/project/manage/requests';

  // Admin
  static const adminHome = '/admin/home';

  // ===== routes =====
  static Map<String, WidgetBuilder> get routes => {
    userHome: (context) => const UserHomePage(),
    userProfile: (context) => const UserProfile(),
    login: (context) => const LoginScreen(),

    // Project
    projectCreate: (context) => const ProjectCreateScreen(),
    projectDraft: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        return ProjectCreateScreen(draftId: args);
      }
      return const RequestDraftAndPendingScreen();
    },
    projectRequest: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        return ProjectRequestScreen(projectId: args);
      }
      return const ProjectManageScreen();
    },

    // Admin
    adminHome: (context) => const AdminHomeScreen()
  };
}