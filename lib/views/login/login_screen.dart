import 'package:flutter/material.dart';
import 'package:srv_paperless/utils/screen_size.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/views/widgets/custom_button.dart';
import 'package:srv_paperless/views/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _handleLogin() async {
    if(ref.read(authProvider).isLoading) return;

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.login(usernameController.text, passwordController.text);

    if(!mounted) return;
    final authState = ref.read(authProvider);

    if (authState.currentUser != null) {
      final user = authState.currentUser!;
      if(user.isAdmin) {
        Navigator.pushReplacementNamed(context, '/user_home'); //TODO: admin home
      } else {
        Navigator.pushReplacementNamed(context, '/user_home');
      }
    } else if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final height = context.screenHeight;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: width,
              height: height * 0.35, // Change height following phone
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea( 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height * 0.1, 
                      child: Image.asset("assets/images/srv-logo.png", fit: BoxFit.contain)
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "ระบบโครงการออนไลน์",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "นโยบายและแผนงาน โรงเรียนสารวิทยา",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08, 
                vertical: 30
              ),
              child: Column(
                children: [
                  const Text(
                    "เข้าสู่ระบบ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    label: "ชื่อผู้ใช้งาน",
                    hint: "กรอกชื่อผู้ใช้งาน",
                    controller: usernameController,
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
                    text: authState.isLoading
                        ? SizedBox( 
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : Text(
                      "เข้าสู่ระบบ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: authState.isLoading ? null : _handleLogin,
                    border: 15,
                    color: authState.isLoading
                        ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6)
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