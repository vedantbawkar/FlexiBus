import 'package:flexibus_passenger/screens/dashboard/home_screen.dart';
import 'package:flexibus_passenger/screens/dashboard/custom_footer.dart';
import 'package:flexibus_passenger/screens/dashboard/buses_around_you.dart';
import 'package:flexibus_passenger/screens/dashboard/popular_routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
// Import your screens
import '../profile/profile_screen.dart';
// import '../settings/settings_screen.dart';
import '../subscription/subscription_screen.dart';
import '../subscription/wallet_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
    } else {
      return const LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('passengers')
              .doc(user?.uid)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final displayName = userData['name'] ?? 'User';
        final hasBooked = userData['hasBooked'] ?? false;

        return Scaffold(
          backgroundColor: Colors.white,

          // Add this to your existing MainScreen.dart file
          // Replace the existing body section with this updated version
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section with Gradient Background and User Info
                Container(
                  padding: const EdgeInsets.only(
                    top: 60.0,
                    left: 24.0,
                    right: 24.0,
                    bottom: 24.0,
                  ),
                  decoration: BoxDecoration(gradient: gradient),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, $displayName!",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Ready for your next journey?",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        backgroundColor: Colors.white30,
                        radius: 30,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Single Wide Quick Action Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: _buildWideActionButton(
                    context,
                    icon: !hasBooked ? Icons.event_seat : Icons.map,
                    title: !hasBooked ? "Book A Seat" : "Track Your Bus",
                    subtitle:
                        !hasBooked
                            ? "Booked a seat now!"
                            : "See your upcoming trip status",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  !hasBooked
                                      ? const BusBookingScreen()
                                      : const TrackingScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Additional Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.star,
                        title: "Subscription",
                        subtitle: "View  benefits & plans",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const SubscriptionScreen(
                                    // showAppBar: true,
                                  ),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.wallet,
                        title: "Wallet",
                        subtitle: "Manage your funds",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const WalletScreen(showAppBar: true),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                const BusesAroundYouSection(),
                const SizedBox(height: 30),

                const PopularRoutesSection(),
                const SizedBox(height: 30),

                // Account Management Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Account",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          tileColor: Colors.white,
                          leading: const Icon(Icons.person_outline),
                          title: Text("Profile", style: GoogleFonts.poppins()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        Divider(height: 1, color: gradient.colors[2]),
                        ListTile(
                          tileColor: Colors.white,
                          leading: const Icon(Icons.settings_outlined),
                          title: Text("Settings", style: GoogleFonts.poppins()),
                          onTap: () {
                            Navigator.push(
                              context,
                              ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Settings screen is under construction',
                                      ),
                                    ),
                                  )
                                  as Route<Object?>,
                            );
                          },
                        ),
                        Divider(height: 1, color: gradient.colors[2]),
                        ListTile(
                          tileColor: Colors.white,
                          leading: const Icon(Icons.logout),
                          title: Text("Logout", style: GoogleFonts.poppins()),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Add the Custom Footer here
                const CustomFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: gradient.colors[1], size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: gradient.colors[1], size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
