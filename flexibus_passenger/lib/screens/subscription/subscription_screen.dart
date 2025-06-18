import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  String _selectedTicketFilter = 'Active';
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTicketsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "My Tickets and Passes",
                  style: GoogleFonts.poppins(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              _buildFilterDropdown(),
            ],
          ),
          const SizedBox(height: 20.0),
          _buildTicketCard(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTicketFilter,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: gradient.colors[1],
            size: 20,
          ),
          dropdownColor: Colors.white,
          elevation: 3,
          menuMaxHeight: 200,
          borderRadius: BorderRadius.circular(12),
          items:
              ['Active', 'Expired'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: gradient.colors[0].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            value == 'Active'
                                ? Icons.confirmation_num_outlined
                                : Icons.history,
                            size: 16,
                            color: gradient.colors[1],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTicketFilter = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTicketCard() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return _buildEmptyState('Please sign in to view tickets');
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('passengers')
              .doc(currentUser.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error loading tickets');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildEmptyState('No tickets found');
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final tickets =
            List<Map<String, dynamic>>.from(
              userData['tickets_and_passes'] ?? [],
            ).where((ticket) => ticket['type'] == 'ticket').toList();

        if (tickets.isEmpty) return _buildEmptyState('No tickets found');

        final now = DateTime.now();
        final activeTickets =
            tickets.where((ticket) {
              final validTill = (ticket['valid_till'] as Timestamp).toDate();
              return validTill.isAfter(now);
            }).toList();

        final expiredTickets =
            tickets.where((ticket) {
              final validTill = (ticket['valid_till'] as Timestamp).toDate();
              return validTill.isBefore(now);
            }).toList();

        // Sort active and expired tickets by booked_at timestamp in descending order
        activeTickets.sort((a, b) {
          final aTime = (a['booked_at'] as Timestamp).toDate();
          final bTime = (b['booked_at'] as Timestamp).toDate();
          return bTime.compareTo(aTime);
        });

        expiredTickets.sort((a, b) {
          final aTime = (a['booked_at'] as Timestamp).toDate();
          final bTime = (b['booked_at'] as Timestamp).toDate();
          return bTime.compareTo(aTime);
        });

        final ticketsToShow =
            _selectedTicketFilter == 'Active' ? activeTickets : expiredTickets;

        if (ticketsToShow.isEmpty) {
          return _buildEmptyState(
            _selectedTicketFilter == 'Active'
                ? 'No active tickets'
                : 'No expired tickets',
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ticketsToShow.length,
          itemBuilder: (context, index) {
            final ticket = ticketsToShow[index];
            return _buildSingleTicket(ticket);
          },
        );
      },
    );
  }

  Widget _buildSingleTicket(Map<String, dynamic> ticket) {
    final validTill = (ticket['valid_till'] as Timestamp).toDate();
    final bookedAt = (ticket['booked_at'] as Timestamp).toDate();
    final isExpired = validTill.isBefore(DateTime.now());

    final ticketGradient =
        isExpired
            ? const LinearGradient(
              colors: [
                Color(0xFF9E9E9E),
                Color(0xFF757575),
                Color(0xFF757575),
                Color(0xFF757575),
                Color(0xFF757575),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
            : gradient;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: ticketGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isExpired ? Icons.history : Icons.confirmation_num_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route ${ticket['route_no']}',
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isExpired ? 'Expired' : 'Valid',
                        style: GoogleFonts.poppins(
                          fontSize: 12.0,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    '₹${ticket['fare']}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTicketInfo(
                  'From',
                  ticket['source'],
                  Icons.location_on_outlined,
                  ticket,
                ),
                const SizedBox(height: 12.0),
                _buildTicketInfo(
                  'To',
                  ticket['destination'],
                  Icons.location_on,
                  ticket,
                ),
                const SizedBox(height: 12.0),
                _buildTicketInfo(
                  'Time',
                  ticket['timing'],
                  Icons.access_time,
                  ticket,
                ),
                const Divider(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimestamp('Booked', bookedAt),
                    _buildTimestamp('Valid Till', validTill),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfo(
    String label,
    String value,
    IconData icon,
    Map<String, dynamic> ticket,
  ) {
    final validTill = (ticket['valid_till'] as Timestamp).toDate();
    final isExpired = validTill.isBefore(DateTime.now());

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isExpired ? Colors.grey[600] : gradient.colors[1],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimestamp(String label, DateTime timestamp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
        ),
        Text(
          DateFormat('dd MMM, hh:mm a').format(timestamp),
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(color: gradient.colors[1]),
          const SizedBox(height: 16.0),
          Text(
            "Loading tickets...",
            style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.red[400]),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: gradient.colors[0].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              _selectedTicketFilter == 'Active'
                  ? Icons.confirmation_num_outlined
                  : Icons.history_outlined,
              size: 40,
              color: gradient.colors[1],
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _selectedTicketFilter == 'Active'
                ? "Book a ticket to see it here"
                : "Your expired tickets will appear here",
            style: GoogleFonts.poppins(
              fontSize: 14.0,
              color: Colors.black54,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSubscriptionOptions(
    BuildContext context,
    Map<String, dynamic> plan,
    GlobalKey buttonKey,
  ) {
    final List<Map<String, dynamic>> durations =
        [
          {
            'type': 'Daily',
            'cost': plan['dailyCost'] ?? 0,
            'icon': Icons.today,
          },
          {
            'type': 'Weekly',
            'cost': plan['weeklyCost'] ?? 0,
            'icon': Icons.date_range,
          },
          {
            'type': 'Annual',
            'cost': plan['annualCost'] ?? 0,
            'icon': Icons.calendar_view_month,
          },
        ].where((duration) => duration['cost'] > 0).toList();

    if (durations.isEmpty) {
      _showSnackBar('No other subscription durations available', isError: true);
      return;
    }

    final RenderBox button =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);
    final Size size = button.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height + 8,
        position.dx + size.width,
        position.dy + size.height + 250,
      ),
      items:
          durations.map((duration) {
            return PopupMenuItem(
              value: duration,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 8.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: gradient.colors[0].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(
                        duration['icon'],
                        size: 20,
                        color: gradient.colors[1],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${duration['type']} Plan',
                            style: GoogleFonts.poppins(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _getDurationDescription(duration['type']),
                            style: GoogleFonts.poppins(
                              fontSize: 12.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${duration['cost']}',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        color: gradient.colors[2],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      elevation: 12.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white,
    ).then((selectedDuration) {
      if (selectedDuration != null) {
        _handleSubscription(
          plan,
          selectedDuration['type'],
          selectedDuration['cost'],
        );
      }
    });
  }

  String _getDurationDescription(String type) {
    switch (type) {
      case 'Daily':
        return 'Renews every day';
      case 'Weekly':
        return 'Renews every week';
      case 'Annual':
        return 'Best value - Save more!';
      default:
        return '';
    }
  }

  void _handleSubscription(
    Map<String, dynamic> plan,
    String durationType,
    num cost,
  ) {
    _showSnackBar(
      'Subscribing to ${plan['name']} - $durationType plan at ₹$cost',
      isError: false,
    );
    // TODO: Implement actual subscription logic
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : gradient.colors[1],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> plan, int index) {
    final benefits = List<String>.from(plan['benefits'] ?? []);
    final monthlyCost = plan['monthlyCost'] ?? 0;
    final dropdownKey = GlobalKey();

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(gradient: gradient),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['name'] ?? 'Unknown Plan',
                          style: GoogleFonts.poppins(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Premium Features Included',
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      '₹$monthlyCost/mo',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        color: gradient.colors[1],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Benefits section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you get:',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ...List.generate(
                    benefits.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: gradient.colors[2].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 16.0,
                              color: gradient.colors[2],
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              benefits[i],
                              style: GoogleFonts.poppins(
                                fontSize: 15.0,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Subscribe button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              monthlyCost > 0
                                  ? () => _handleSubscription(
                                    plan,
                                    'Monthly',
                                    monthlyCost,
                                  )
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gradient.colors[1],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(14.0),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Subscribe Now',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        key: dropdownKey,
                        color: gradient.colors[1],
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(14.0),
                        ),
                        child: InkWell(
                          onTap:
                              () => _showSubscriptionOptions(
                                context,
                                plan,
                                dropdownKey,
                              ),
                          customBorder: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(14.0),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Status bar spacing
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: gradient.colors[1],
              labelColor: gradient.colors[1],
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: "My Tickets"),
                Tab(text: "Subscription Plans"),
              ],
            ),
          ),

          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index);
              },
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      _buildTicketsSection(),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      // Subscription Plans Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Choose Your Plan",
                              style: GoogleFonts.poppins(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "Unlock premium features with our subscription plans",
                              style: GoogleFonts.poppins(
                                fontSize: 16.0,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      // Subscription Plans Stream Builder
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('subscription_plans')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _buildErrorState(
                              'Error loading subscription plans',
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildLoadingState();
                          }
                          final plans = snapshot.data?.docs ?? [];
                          if (plans.isEmpty) {
                            return _buildEmptyState(
                              'No subscription plans available',
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              children: List.generate(plans.length, (index) {
                                final plan =
                                    plans[index].data() as Map<String, dynamic>;
                                return _buildSubscriptionCard(plan, index);
                              }),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
