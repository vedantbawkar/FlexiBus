import 'package:flexiops/providers/auth_provider.dart';
import 'package:flexiops/screens/auth/login_screen.dart';
import 'package:flexiops/screens/drivers/dashboard_screen.dart';
import 'package:flexiops/screens/operator/dashboard_screen.dart';
import 'package:flutter/material.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    final stat = await fetchStatus();
    if (stat == 'approved') {
      // Navigate to the appropriate screen based on role
      final role =
          await fetchRole(); // you can create a similar method for role
      if (role == 'RidePilot') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DriverDashboard()),
        );
      } else if (role == 'FleetOperator') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FleetOperatorDashboard()),
        );
      }
    } else if (stat == 'pending') {
      // Stay on pending approval screen
    } else {
      // Navigate to login or fallback screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Approval Pending")),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/pending.jpg"),
                Text(
                  "Approval is pending by Fleet Operator",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(
                  "Till then complete your profile",
                  style: TextStyle(color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Profile"),
        ),
        icon: Icon(Icons.person, size: 36),
      ),
    );
  }

  Future<String> fetchStatus() async {
    try {
      AuthProvider authProvider = AuthProvider();
      return authProvider.status ?? "pending";
    } catch (e) {
      return "error"; // Handle error gracefully
    }
  }

  Future<String?> fetchRole() async {
    try {
      AuthProvider authProvider = AuthProvider();
      return authProvider.role;
    } catch (e) {
      return null;
    }
  }
}
