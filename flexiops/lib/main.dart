import 'package:firebase_core/firebase_core.dart';
import 'package:flexiops/configs/theme.dart';
import 'package:flexiops/firebase_options.dart';
import 'package:flexiops/providers/bus_provider.dart';
import 'package:flexiops/providers/operator_provider.dart';
import 'package:flexiops/screens/drivers/pending_approval_screen.dart';
import 'package:flexiops/screens/operator/dashboard_screen.dart';
import 'package:flexiops/screens/auth/login_screen.dart';
import 'package:flexiops/screens/auth/register_screen.dart';
import 'package:flexiops/screens/drivers/dashboard_screen.dart';
import 'package:flexiops/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize services after Firebase
  await AuthService.initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BusProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        // Add other providers here if needed
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // Access the current system UI style based on theme
          final currentSystemUiStyle =
              themeProvider.isDarkMode
                  ? SystemUiOverlayStyle(
                    statusBarColor: primaryColor,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: Color(0xFF121212),
                    systemNavigationBarIconBrightness: Brightness.light,
                  )
                  : SystemUiOverlayStyle(
                    statusBarColor: primaryColor,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: lightYellowColor,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  );

          // Apply system UI style globally
          SystemChrome.setSystemUIOverlayStyle(currentSystemUiStyle);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FlexiOps',
            themeMode: ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routes: {
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
              '/fleetOperatorDashboard': (_) => FleetOperatorDashboard(),
              '/ridePilotDashboard': (_) => DriverDashboard(),
            },
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                // Check if the user is logged in and navigate accordingly
                if (authProvider.isAuthenticated) {
                  print(authProvider.role);
                  if (authProvider.role == 'FleetOperator') {
                    return FleetOperatorDashboard();
                  } else if (authProvider.role == 'RidePilot') {
                    return DriverDashboard();
                  } 
                  // else {
                  //   return PendingApprovalScreen();
                  // }
                  // return PendingApprovalScreen();
                } else {
                  return LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
