import 'package:flutter/material.dart';
import 'package:srv_paperless/utils/screensize.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(children: [Title(context)])),
    );
  }
}

Widget Title(BuildContext context) {
  final width = context.screenWidth;
  final height = context.screenHeight;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: width,
        height: height * 0.32,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/srv-logo.png"),
            SizedBox(height:10,),
            Text("ระบบโครงการออนไลน์",
            style: TextStyle(
              fontSize: 28,
              color: Colors.white, 
              fontWeight: FontWeight.bold)
              ),
            SizedBox(height:10,),
            Text("นโยบายและแผนงาน โรงเรียนสารวิทยา",
              style: TextStyle(
              fontSize: 16,
              color: Colors.white, 
              ),
            )
            ]
          ),
      ),
    ],
  );
}
