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
    final authNotifier = ref.read(authProvider.notifier);
    
    await authNotifier.login(usernameController.text, passwordController.text);
    
    final authState = ref.read(authProvider);

    // เช็คว่ามีข้อมูล User หรือไม่
    if (authState.currentUser != null) {
      // สามารถแยกหน้าตามเงื่อนไขที่ต้องการ เช่น เช็คจาก username หรือ status
      // แต่เบื้องต้นส่งไปที่หน้าหลักเหมือนกันตามที่คุณออกแบบไว้
      Navigator.pushReplacementNamed(context, '/user_home');
    } else if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: Colors.red, // เพิ่มสีแดงเพื่อให้เด่นชัดว่าเป็นข้อผิดพลาด
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final height = context.screenHeight;

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
                    text: const Text(
                      "เข้าสู่ระบบ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                    _handleLogin();
                    },
                    border: 15,
                    color: Theme.of(context).colorScheme.primaryContainer,
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