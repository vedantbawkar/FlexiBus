import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool showAppBar;
  const SubscriptionScreen({super.key, this.showAppBar = false});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  void _showSubscriptionOptions(
    BuildContext context,
    Map<String, dynamic> plan,
    GlobalKey buttonKey,
  ) {
    final List<Map<String, dynamic>> durations =
        [
              {'type': 'Daily', 'cost': plan['dailyCost'] ?? 0},
              {'type': 'Weekly', 'cost': plan['weeklyCost'] ?? 0},
              {'type': 'Monthly', 'cost': plan['monthlyCost'] ?? 0},
              {'type': 'Annual', 'cost': plan['annualCost'] ?? 0},
            ]
            .where(
              (duration) =>
                  duration['cost'] > 0 && duration['type'] != 'Monthly',
            )
            .toList();

    if (durations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other subscription durations available'),
        ),
      );
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
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 200,
      ),
      items:
          durations.asMap().entries.map((entry) {
            final index = entry.key;
            final duration = entry.value;
            return PopupMenuItem(
              value: duration,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom:
                        index < durations.length - 1
                            ? BorderSide(color: Colors.grey[200]!, width: 1)
                            : BorderSide.none,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${duration['type']} Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${duration['cost']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        color: gradient.colors.last,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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

  void _handleSubscription(
    Map<String, dynamic> plan,
    String durationType,
    num cost,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Subscribing to ${plan['name']} - $durationType plan at ₹$cost',
        ),
      ),
    );
    // TODO: Implement actual subscription logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:
          widget.showAppBar
              ? AppBar(
                title: Text(
                  'Subscription Plans',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
              : null,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('subscription_plans')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading plans', style: GoogleFonts.poppins()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index].data() as Map<String, dynamic>;
              final benefits = List<String>.from(plan['benefits'] ?? []);
              final monthlyCost = plan['monthlyCost'] ?? 0;
              final dropdownKey = GlobalKey();

              return Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            plan['name'] ?? 'Unknown Plan',
                            style: GoogleFonts.poppins(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹$monthlyCost/month',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              color: gradient.colors.last,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Divider(thickness: 1, color: Colors.grey[300]),
                      const SizedBox(height: 8.0),
                      Text(
                        'Benefits:',
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      ...List.generate(
                        benefits.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18.0,
                                color: gradient.colors[1],
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  benefits[i],
                                  style: GoogleFonts.poppins(fontSize: 14.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
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
                                backgroundColor: gradient.colors.last,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.horizontal(
                                    left: const Radius.circular(10.0),
                                    right: const Radius.circular(0),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Subscribe Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Material(
                            key: dropdownKey,
                            color: gradient.colors.last,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(10.0),
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
                                  right: Radius.circular(10.0),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 14.0,
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
                                  Icons.arrow_drop_down,
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
              );
            },
          );
        },
      ),
    );
  }
}
