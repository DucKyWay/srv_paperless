
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const MainLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.tertiary ,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("SRV Menu")),
            ListTile(
              title: const Text("หน้าหลัก"),
              onTap: () { /* Navigate to Home */ },
            ),
          ],
        ),
      ),
      body: child, 
    );
  }
}