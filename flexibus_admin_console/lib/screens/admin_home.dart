import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tab1_passengers.dart';
import 'tab4_routes.dart';
import 'tab5_subscriptions.dart';
import 'tab6_coupons.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  final List<Tab> tabs = [
    Tab(
      child: Text(
        'Passengers',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    ),
    Tab(
      child: Text(
        'Fleet Operators',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    ),
    Tab(
      child: Text(
        'RidePilots',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    ),
    Tab(
      child: Text(
        'Routes',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    ),
    Tab(
      child: Text(
        'Subscriptions',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    ),
    Tab(
      child: Text(
        'Coupons',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    ),
  ];

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'FlexiBus Admin Console',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            tabs: tabs,
            isScrollable: true,
            labelColor: gradient.colors[1],
            unselectedLabelColor: Colors.black54,
            indicatorColor: gradient.colors[1],
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: gradient.colors[1].withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            const Tab1Passengers(),
            Center(
              child: Text(
                'Fleet Operators (Coming Soon)',
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            ),
            Center(
              child: Text(
                'RidePilots (Coming Soon)',
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            ),
            const Tab4Routes(),
            const Tab5Subscriptions(),
            const Tab6Coupons(),
          ],
        ),
      ),
    );
  }
}
