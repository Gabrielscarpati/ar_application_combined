import 'package:augmented_reality/provider/ar_mobile_view_provider.dart';
import 'package:augmented_reality/provider/bottom_sheet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'choose_screen.dart';

/*
* Figure out how to change the objects position*/
Future<void> main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomSheetProvider()),
        //ChangeNotifierProvider(create: (context) => ArMobile2()),
        ChangeNotifierProvider(create: (context) => ArViewProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChooseScreen(),
    );
  }
}
