import 'package:augmented_reality/provider/add_model_from_internal_storage_provider.dart';
import 'package:augmented_reality/provider/add_model_from_internet_provider.dart';
import 'package:augmented_reality/provider/ar_mobile_view_provider.dart';
import 'package:augmented_reality/provider/bottom_sheet_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/choose_screen/choose_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCnXV1lCzqi4SOZeUEmvhPR0qrXLCphEiQ",
        appId: "1:984746454319:web:ee0c4606274e7cea3e85da",
        messagingSenderId: "984746454319",
        projectId: "augmented-reality-f92e2",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomSheetProvider()),
        ChangeNotifierProvider(
            create: (context) => AddModelFromInternetProvider()),
        ChangeNotifierProvider(create: (context) => ArViewProvider()),
        ChangeNotifierProvider(
            create: (context) => AddModelFromInternetProvider()),
        ChangeNotifierProvider(
            create: (context) => AddModelFromInternalStorageProvider()),
        // ChangeNotifierProvider(create: (context) => AddModel ()),
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
