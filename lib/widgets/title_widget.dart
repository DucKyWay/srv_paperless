import 'package:flutter/material.dart';

abstract class TitleWidget extends StatelessWidget {
  final String? title;
  final String? des;
  const TitleWidget({super.key, this.title, this.des});

  Widget buildLeading(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [buildLeading(context)]
    );
  }
}

class TitleNormal extends TitleWidget {
  const TitleNormal({super.key, super.title, super.des});

  @override
  Widget buildLeading(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Image.asset("assets/images/srv-logo.png", fit: BoxFit.contain),
          Text(
            title ?? "ระบบโครงการออนไลน์",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            des ?? "นโยบายและแผนงาน โรงเรียนสารวิทยา",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class TitleSmall extends TitleWidget {
  const TitleSmall({super.key, super.title, super.des});

  @override
  Widget buildLeading(BuildContext context) {
    //TODO: make small title
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Image.asset("assets/images/srv-logo.png", fit: BoxFit.contain),
          Text(
            "Lorem Ipsum",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            "นโยบายและแผนงาน โรงเรียนสารวิทยา",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
