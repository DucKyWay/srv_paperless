import 'package:flutter/material.dart';
import 'package:srv_paperless/core/constants/constants.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/core/utils/snackbar_util.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _handleLogin() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      SnackBarWidget.warning(context, "กรุณากรอกข้อมูลให้ครบ");
      return;
    }

    ref
        .read(authProvider.notifier)
        .login(usernameController.text, passwordController.text);
  }

  @override
  void initState() {
    super.initState();

    ref.listenManual(authProvider, (previous, next) {
      next.whenOrNull(
        data: (authState) {
          if (authState.error != null) {
            SnackBarWidget.error(context, authState.error!);
          }

          if (authState.message != null) {
            SnackBarWidget.success(context, authState.message!);
          }
        },
        error: (error, stack) {
          SnackBarWidget.error(context, error.toString());
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final height = context.screenHeight;

    final authAsync = ref.watch(authProvider);
    final isLoading = authAsync.isLoading;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: width,
              height: height * 0.35,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Image.asset(
                        "${AppConstants.imagePath}/srv-logo.png",
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "ระบบโครงการออนไลน์",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "นโยบายและแผนงาน โรงเรียนสารวิทยา",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: 30,
              ),
              child: Column(
                children: [
                  const Text(
                    "เข้าสู่ระบบ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    label: "ชื่อผู้ใช้งาน (อีเมล)",
                    hint: "example@gmail.com",
                    controller: usernameController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: "รหัสผ่าน",
                    hint: "กรอกรหัสผ่าน",
                    controller: passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    height: 55,
                    text:
                        isLoading
                            ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Text(
                              "เข้าสู่ระบบ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                    onPressed: isLoading ? null : _handleLogin,
                    border: 15,
                    color:
                        isLoading
                            ? Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.6)
                            : Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
