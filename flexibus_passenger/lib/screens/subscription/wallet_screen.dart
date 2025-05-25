import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  final bool showAppBar;
  const WalletScreen({super.key, this.showAppBar = true});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  double _currentBalance = 0;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('passengers')
            .doc(uid)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _currentBalance = (data['wallet_balance'] ?? 0).toDouble();
        _transactions = List<Map<String, dynamic>>.from(
          data['transaction_logs'] ?? [],
        );
        _transactions.sort(
          (a, b) =>
              DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
        );
      });
    }
  }

  void _showTransactionDialog(String type) {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$type Funds',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Amount',
                    hintStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel', style: GoogleFonts.poppins()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            () => _processTransaction(
                              type,
                              amountController.text,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gradient.colors.last,
                        ),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _processTransaction(String type, String amountText) async {
    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Navigator.of(context).pop();
      _showSnackBar('Invalid amount entered.', Colors.red);
      return;
    }

    if (type == 'Withdraw' && _currentBalance < amount) {
      Navigator.of(context).pop();
      _showSnackBar('Insufficient balance.', Colors.red);
      return;
    }

    setState(() {
      if (type == 'Add') {
        _currentBalance += amount;
        _transactions.insert(0, {
          'type': 'Credit',
          'amount': amount,
          'date': DateTime.now().toIso8601String(),
          'description': 'Funds Added',
        });
      } else if (type == 'Withdraw') {
        _currentBalance -= amount;
        _transactions.insert(0, {
          'type': 'Debit',
          'amount': amount,
          'date': DateTime.now().toIso8601String(),
          'description': 'Funds Withdrawn',
        });
      }
    });

    await FirebaseFirestore.instance
        .collection('passengers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
          'transaction_logs': FieldValue.arrayUnion([
            {
              'type': type == 'Add' ? 'Credit' : 'Debit',
              'amount': amount,
              'date': DateTime.now().toIso8601String(),
              'description': type == 'Add' ? 'Funds Added' : 'Funds Withdrawn',
            },
          ]),
          'wallet_balance': _currentBalance,
        });

    Navigator.of(context).pop();
    _showSnackBar('Transaction successful.', Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: color,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:
          widget.showAppBar
              ? AppBar(
                title: Text(
                  'Wallet',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
              : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: gradient,
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
                        onPressed: () => _showTransactionDialog('Add'),
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
                        onPressed: () => _showTransactionDialog('Withdraw'),
                        icon: const Icon(Icons.remove, color: Colors.white),
                        label: Text(
                          'Withdraw',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
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
                        DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(DateTime.parse(transaction['date'])),
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
