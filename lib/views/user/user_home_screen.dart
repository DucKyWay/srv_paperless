import 'package:flutter/material.dart';
import 'package:srv_paperless/widgets/main_layout.dart';
import 'package:srv_paperless/widgets/menu_header.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: NormalHeader(),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/srv-logo.png",
                      fit: BoxFit.contain,
                    ),
                    Text(
                      "หน้าแรก",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("สรุปผลเบื้องต้น", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              
              card(context,"ยื่นโครงการ",1),
              card(context,"ติดตามโครงการ",2),
              card(context,"สรุปโครงการที่ดำเนินการสำเร็จ",3),
              
            ],
          ),
        ),
      ),
    );
  }
}
Widget card(BuildContext context, String text, int num) { // เพิ่ม context เข้ามา
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.5),
    child: Container(
      // ใช้ความกว้าง 90% ของหน้าจอ แทนการระบุเลข 350 ตรงๆ
      width: MediaQuery.of(context).size.width * 0.85, 
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1.0),
      
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(text, style: const TextStyle(fontSize: 20,fontWeight:FontWeight.bold)),
          Text('$num', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
