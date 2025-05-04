// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'screens/login_screen.dart';
// import 'package:device_preview/device_preview.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(
//     DevicePreview(
//       enabled: !kReleaseMode, // Disable in release mode
//       builder: (context) => const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FlexiBus - Hop on. Ride smart',
//       useInheritedMediaQuery: true,
//       builder: DevicePreview.appBuilder, // Add this line
//       locale: DevicePreview.locale(context), // Optional: for testing locales
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const LoginScreen(),
//     );
//   }
// }
import 'package:flexibus_passenger/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  

  //Initialize services after Firebase

  // Get saved theme mode
  // final themeMode = await SettingsService.getThemeMode();
  // runApp(FlexiBusApp(initialThemeMode: themeMode));
  runApp(FlexiBusApp());
}

class FlexiBusApp extends StatelessWidget {
    // final ThemeMode initialThemeMode;
    const FlexiBusApp({
    super.key,
    // required this.initialThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add your providers here
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'FlexiBus - Hop on. Ride smart',
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
