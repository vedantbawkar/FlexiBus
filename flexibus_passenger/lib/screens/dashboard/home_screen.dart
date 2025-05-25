import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../profile/profile_screen.dart';
import '../subscription/subscription_screen.dart';
import '../subscription/wallet_screen.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  int _selectedIndex = 0;
  bool hasBooked = false; // Variable to store the "hasBooked" attribute

  static const List<Widget> _widgetOptions = <Widget>[
    MainScreen(),
    BusBookingOrTrackingScreen(),
    SubscriptionScreen(showAppBar: false),
    WalletScreen(showAppBar: false),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
  }

  Future<void> _fetchUserData() async {
    try {
      // Replace 'users' with your Firestore collection name and 'userId' with the actual user ID
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance
              .collection('passengers')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get();

      if (userSnapshot.exists) {
        setState(() {
          hasBooked = userSnapshot['hasBooked'] ?? false;
          print('hasBooked value: $hasBooked'); // Print the value to console
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FlexiBus',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
        automaticallyImplyLeading: false, // To remove back button if any
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: hasBooked ? 'Track' : 'Book',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Subscription',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Wallet',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: gradient.colors.last,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class BusBookingOrTrackingScreen extends StatelessWidget {
  const BusBookingOrTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _HomeScreenState? homeScreenState =
        context.findAncestorStateOfType<_HomeScreenState>();

    if (homeScreenState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    homeScreenState._fetchUserData(); // Fetch user data if not already done
    return homeScreenState.hasBooked
        ? const TrackingScreen()
        : const BusBookingScreen();
  }
}

class BusBookingScreen extends StatelessWidget {
  const BusBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.directions_bus, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Bus Booking Feature', style: GoogleFonts.poppins(fontSize: 20)),
          const SizedBox(height: 8),
          const Text('Implementation in progress...'),
        ],
      ),
    );
  }
}

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.map, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Bus Tracking Feature',
            style: GoogleFonts.poppins(fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text('Stay tuned for live tracking!'),
        ],
      ),
    );
  }
}

// BusBookingScreen and TrackingScreen to be developed further. The above code provides a basic structure for the HomeScreen with a BottomNavigationBar and placeholders for the Bus Booking and Tracking features. The `hasBooked` variable is used to determine which screen to show in the BottomNavigationBar. The `gradient` variable is used to create a gradient effect for the AppBar. The `fetchUserData` method retrieves the user's data from Firestore, specifically checking if they have booked a bus or not.
//
