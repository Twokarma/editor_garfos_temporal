import 'package:flutter/material.dart';
import 'package:graph_maker_app_2/screens/graph_screen.dart';
import 'package:graph_maker_app_2/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'providers/graph_provider.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GraphProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.themeSeed),
      ),
      home: const GraphScreen(),
    );
  }
}