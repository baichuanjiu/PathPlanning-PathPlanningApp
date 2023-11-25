import 'package:flutter/material.dart';
import 'package:path_planning_app/home_page/home_page.dart';
import 'package:path_planning_app/path_extraction_page/path_extraction_page.dart';
import 'package:path_planning_app/path_planning_page/path_planning_page.dart';

void main() {
  runApp(const PathPlanningApp());
}

class PathPlanningApp extends StatelessWidget {
  const PathPlanningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routes: {
        '/pathExtraction': (context) => const PathExtractionPage(),
        '/pathPlanning': (context) => const PathPlanningPage(),
      },
      home: const HomePage(),
    );
  }
}
