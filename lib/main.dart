import 'package:flutter/material.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:uresaxapp/pages/companies_page.dart';

void main() async {
  try {
    await connection.open();
    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(
        title: 'URESAX',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(e.toString(), style: const TextStyle(fontSize: 25),textAlign: TextAlign.center),
            ],
          ),
        ))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URESAX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CompaniesPage(),
    );
  }
}
