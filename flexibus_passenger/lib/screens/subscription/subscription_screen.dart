import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'name': 'Basic',
      'price': 99.00,
      'duration': 'Monthly',
      'benefits': [
        'Priority Booking',
        '5% Discount on all trips',
        'Early access to new routes',
      ],
    },
    {
      'name': 'Premium',
      'price': 249.00,
      'duration': 'Monthly',
      'benefits': [
        'Highest Booking Priority',
        '15% Discount on all trips',
        'Exclusive route access',
        'Dedicated customer support',
      ],
    },
    {
      'name': 'Annual',
      'price': 999.00,
      'duration': 'Yearly',
      'benefits': [
        'Highest Booking Priority',
        '20% Discount on all trips',
        'Exclusive route access',
        'Dedicated customer support',
        'Free cancellation on 2 trips/month',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Subscription Plans',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _subscriptionPlans.length,
        itemBuilder: (context, index) {
          final plan = _subscriptionPlans[index];
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
                        plan['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${plan['price'].toStringAsFixed(2)}/${plan['duration']}',
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
                    plan['benefits'].length,
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
                              plan['benefits'][i],
                              style: GoogleFonts.poppins(fontSize: 14.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Subscribe to ${plan['name']}'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradient.colors.last,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
