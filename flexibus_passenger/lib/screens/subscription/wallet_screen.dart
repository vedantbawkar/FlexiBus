import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  double _currentBalance = 155.75; // Example balance

  // Dummy transaction data
  final List<Map<String, dynamic>> _transactions = [
    {
      'type': 'Credit',
      'amount': 50.00,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'description': 'Subscription Payment',
    },
    {
      'type': 'Debit',
      'amount': 12.50,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'Bus Ticket - Mumbai to Pune',
    },
    {
      'type': 'Credit',
      'amount': 100.00,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'description': 'Funds Added',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'FlexiBus Wallet',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Wallet Balance Header
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradient.colors.first.withOpacity(0.8),
                    gradient.colors[1].withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Current Balance',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '₹${_currentBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement Add Funds functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add Funds pressed')),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Add Funds',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gradient.colors.last,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement Withdraw Funds functionality (if applicable)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Withdraw pressed')),
                          );
                        },
                        icon: const Icon(Icons.remove, color: Colors.white),
                        label: Text(
                          'Withdraw',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange[400], // A contrasting color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Transaction History
            Text(
              'Transaction History',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12.0),
            _transactions.isEmpty
                ? Center(
                  child: Text(
                    'No transactions yet.',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  separatorBuilder:
                      (context, index) =>
                          const Divider(color: Colors.grey, height: 1),
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    final isCredit = transaction['type'] == 'Credit';
                    return ListTile(
                      leading: Icon(
                        isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isCredit ? Colors.green : Colors.redAccent,
                      ),
                      title: Text(
                        transaction['description'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                      ),
                      subtitle: Text(
                        '${transaction['date'].toString().split(' ').first}',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        '${isCredit ? '+' : '-'}₹${transaction['amount'].toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: isCredit ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
