import 'package:augmented_reality/provider/add_model_from_internal_storage_provider.dart';
import 'package:augmented_reality/provider/ar_mobile_view_provider.dart';
import 'package:augmented_reality/provider/bottom_sheet_provider.dart';
import 'package:augmented_reality/provider/load_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/choose_screen /choose_screen.dart';

Future<void> main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomSheetProvider()),
        ChangeNotifierProvider(create: (context) => LoadModelProvider()),
        ChangeNotifierProvider(create: (context) => ArViewProvider()),
        ChangeNotifierProvider(
            create: (context) => AddModelFromInternalStorageProvider()),
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
