import 'package:device_preview/device_preview.dart';
import 'package:flexibus_passenger/providers/auth_provider.dart';
import 'package:flexibus_passenger/screens/dashboard/home_screen.dart';
import 'package:flutter/foundation.dart';
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
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Disable in release mode
      builder: (context) => const FlexiBusApp(),
    ),
  );
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
        // home: HomeScreen(),
      ),
    );
  }
}
