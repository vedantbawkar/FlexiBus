// screens/fleet_operator_dashboard.dart
import 'package:flexiops/configs/theme.dart';
import 'package:flexiops/providers/auth_provider.dart';
import 'package:flexiops/screens/fleet/fleet_drivers_screen.dart';
import 'package:flexiops/screens/fleet/fleet_profile_screen.dart';
import 'package:flexiops/screens/fleet/fleet_screen.dart';
import 'package:flexiops/screens/fleet/fleet_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FleetOperatorDashboard extends StatefulWidget {
  const FleetOperatorDashboard({super.key});

  @override
  State<FleetOperatorDashboard> createState() => _FleetOperatorDashboardState();
}

class _FleetOperatorDashboardState extends State<FleetOperatorDashboard> {
  int _selectedIndex = 0;
  late AuthProvider authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = Provider.of<AuthProvider>(context);
  }

  List<Widget> get _screens => [
    const FleetHomeScreen(),
    FleetViewScreen(),
    FleetDriversScreen(fleetOperatorId: authProvider.user?.uid ?? ''),
    const FleetReportsScreen(),
    const FleetProfileScreen(),
    // const BusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.business_rounded, color: lightYellowColor),
            const SizedBox(width: 8),
            const Text(
              'FlexiOps - Fleet',
              style: TextStyle(color: lightYellowColor),
            ),
          ],
        ),
        actions: [
          // Notifications Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {
              // Show notifications
            },
          ),
          // Profile Icon
          IconButton(
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 20, color: Color(0xFF310052)),
            ),
            onPressed: () {
              // Show profile options
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        // selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_outlined),
            activeIcon: Icon(Icons.directions_bus),
            label: 'Fleet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Drivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// HOME SCREEN ///
class FleetHomeScreen extends StatelessWidget {
  const FleetHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: lightCoralColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.auto_graph, color: primaryColor, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Metro Transit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tuesday, May 6 • Fleet overview',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Dashboard Cards / Summary Tiles
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildSummaryCard(
                  '42',
                  'Active Buses',
                  Icons.directions_bus_outlined,
                  Colors.blue[700]!,
                  '3 in maintenance',
                ),
                _buildSummaryCard(
                  '58',
                  'Total Drivers',
                  Icons.person_outline,
                  Colors.green[600]!,
                  '5 on leave',
                ),
                _buildSummaryCard(
                  '23',
                  'Rides in Progress',
                  Icons.timeline_outlined,
                  Colors.amber[700]!,
                  '2 delayed',
                ),
                _buildSummaryCard(
                  '\$5,280',
                  'Today\'s Earnings',
                  Icons.attach_money,
                  burgundyColor,
                  '↑ 12% from yesterday',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Title - Quick Actions
            _buildSectionTitle('Quick Actions', () {}),

            const SizedBox(height: 16),

            // Action Shortcuts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  context,
                  'Manage Buses',
                  Icons.directions_bus,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FleetViewScreen(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  'Manage Drivers',
                  Icons.people_alt_outlined,
                  () {
                    AuthProvider authProvider = Provider.of<AuthProvider>(
                      context,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FleetDriversScreen(
                              fleetOperatorId: authProvider.user?.uid ?? '',
                            ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  'Create Routes',
                  Icons.map_outlined,
                  () {},
                ),
                _buildActionButton(
                  context,
                  'Schedule',
                  Icons.calendar_month_outlined,
                  () {},
                ),
                _buildActionButton(
                  context,
                  'Reports',
                  Icons.bar_chart_outlined,
                  () {},
                ),
                _buildActionButton(
                  context,
                  'Settings',
                  Icons.settings_outlined,
                  () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Live Feed / Ride Monitor
            _buildSectionTitle('Live Ride Monitor', () {}),

            const SizedBox(height: 16),

            // Map Container
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // This would be your actual map
                    Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.map,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    // Map overlay elements
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '21 On Time',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '2 Delayed',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton.small(
                        backgroundColor: primaryColor,
                        child: const Icon(Icons.my_location),
                        onPressed: () {
                          // Center map on current location
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Alerts Section
            _buildSectionTitle('Recent Alerts', () {}),

            const SizedBox(height: 16),

            // Alert Items
            _buildAlertItem(
              'Maintenance Required',
              'Bus #B-2104 needs scheduled maintenance',
              Icons.build_outlined,
              Colors.orange,
              context,
            ),

            const SizedBox(height: 12),

            _buildAlertItem(
              'Driver Check-in Missed',
              'Driver Alex Thompson missed check-in on Route 42',
              Icons.warning_amber_outlined,
              Colors.red,
              context,
            ),

            const SizedBox(height: 12),

            _buildAlertItem(
              'Customer Feedback',
              'New feedback received for Route 15 service',
              Icons.feedback_outlined,
              Colors.blue,
              context,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  _buildAlertItem(
    String s,
    String t,
    IconData feedback_outlined,
    MaterialColor blue,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feedback_outlined, size: 24, color: blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
        ],
      ),
    );
  }

  // Action Button Component
  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  // Section Title Component
  Widget _buildSectionTitle(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              'View All',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Summary Card Component
  Widget _buildSummaryCard(
    String value,
    String title,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
