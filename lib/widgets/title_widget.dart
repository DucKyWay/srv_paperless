import 'package:flutter/material.dart';

abstract class TitleWidget extends StatelessWidget {
  final String title;
  const TitleWidget({super.key, required this.title});

  Widget? buildLeading(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [if (buildLeading(context) != null) buildLeading(context)!],
    );
  }
}

class TitleNormal extends TitleWidget {
  const TitleNormal({super.key, required super.title});

  @override
  Widget? buildLeading(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Image.asset("assets/images/srv-logo.png", fit: BoxFit.contain),
          Text(
            title,
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

class TitleSmall extends TitleWidget {
  const TitleSmall({super.key, required super.title});

  @override
  Widget? buildLeading(BuildContext context) {
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
