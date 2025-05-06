import 'package:flutter/material.dart';
import 'tab1_passengers.dart';
import 'tab4_routes.dart';
// import 'tab5_subscriptions.dart';
// import 'tab6_coupons.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> tabs = const [
    Tab(text: 'Passengers'),
    Tab(text: 'Fleet Operators'),
    Tab(text: 'Ride Pilots'),
    Tab(text: 'Routes'),
    Tab(text: 'Subscriptions'),
    Tab(text: 'Coupons'),
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
      appBar: AppBar(
        title: const Text('FlexiBus Admin Console'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Tab1Passengers(),
          Center(child: Text('Fleet Operators (Coming Soon)')),
          Center(child: Text('Ride Pilots (Coming Soon)')),
          Tab4Routes(),
          Center(
            child: Text('Subscriptions (Coming Soon)'),
          ), // Tab5Subscriptions(),
          Center(child: Text('Coupons (Coming Soon)')), // Tab6Coupons(),
        ],
      ),
    );
  }
}
