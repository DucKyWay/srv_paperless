import 'package:flutter/material.dart';
import 'package:srv_paperless/views/widgets/main_layout.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ระบบโครงการออนไลน์",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.white),),
          Text("นโยบายและแผนงาน โรงเรียนสารวิทยา",style:TextStyle(fontSize: 12,color: Colors.white),)
        ],
      ) ,
      child: Center(child: Text("ยินดีต้อนรับ")),
    );
  }
}