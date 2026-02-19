import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/viewmodel/auth_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

class RequestDraftScreen extends ConsumerStatefulWidget {
  const RequestDraftScreen({super.key});

  @override
  ConsumerState<RequestDraftScreen> createState() => _RequestDraftScreenState();
}

class _RequestDraftScreenState extends ConsumerState<RequestDraftScreen> {
  @override
  Widget build(BuildContext context) {
  final width = context.screenWidth;
  return MenuWidget(
    title: const HeaderWithBackButton(),
    floatingActionButton: FloatingActionButton( 
      onPressed: () {
        Navigator.pushNamed(context, "/request/draft/create");
      },
      backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer, 
      child: const Icon(Icons.add,color: Colors.white,), 
    ),
    child: SafeArea(
      child: Center(
        child: Column(
          children: [
            const TitleNormal(title: "ยื่นโครงการ"),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Card(context),
            )
          ],
        ),
      ),
    ),
  );
}
}
Widget Card(BuildContext context){
  return Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                             
            ],
          ),
        );
}
