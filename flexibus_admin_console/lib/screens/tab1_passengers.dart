import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class Tab1Passengers extends StatefulWidget {
  const Tab1Passengers({super.key});

  @override
  State<Tab1Passengers> createState() => _Tab1PassengersState();
}

class _Tab1PassengersState extends State<Tab1Passengers> {
  String searchQuery = '';

  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('passengers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: gradient.colors[1]),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No passengers found.",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final filteredDocs =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name']?.toString().toLowerCase() ?? '';
                final email = data['email']?.toString().toLowerCase() ?? '';
                return name.contains(searchQuery) ||
                    email.contains(searchQuery);
              }).toList();

          if (filteredDocs.isEmpty) {
            return Center(
              child: Text(
                "No matching passengers found.",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final passenger = filteredDocs[index];
              final data = passenger.data() as Map<String, dynamic>;

              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final formattedDate =
                  createdAt != null
                      ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)
                      : 'N/A';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors[1].withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['name'] ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data['isVerified'] == true
                                  ? "Verified"
                                  : "Unverified",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Email", data['email']),
                          _infoRow("Phone", data['phone']),
                          _infoRow("Gender", data['gender']),
                          _infoRow("Created At", formattedDate),
                          _infoRow(
                            "ID Proof",
                            "${data['idProofType']}: ${data['idProofValue']}",
                          ),
                          _infoRow(
                            "Has Booked",
                            data['hasBooked'] == true ? "Yes" : "No",
                          ),
                          _infoRow(
                            "Wallet Balance",
                            "₹${data['wallet_balance'] ?? 0}",
                          ),
                          _infoRow(
                            "Security Deposit",
                            data['isSecurityDepositPaid'] == true
                                ? "Paid"
                                : "Not Paid",
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (data['isVerified'] != true)
                                _actionButton("Verify", gradient.colors[2], () {
                                  FirebaseFirestore.instance
                                      .collection('passengers')
                                      .doc(passenger.id)
                                      .update({'isVerified': true});
                                }),
                              const SizedBox(width: 8),
                              _actionButton(
                                data['isBanned'] == true ? "Unban" : "Ban",
                                data['isBanned'] == true
                                    ? gradient.colors[1]
                                    : Colors.red,
                                () {
                                  FirebaseFirestore.instance
                                      .collection('passengers')
                                      .doc(passenger.id)
                                      .update({
                                        'isBanned': !(data['isBanned'] == true),
                                      });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
  }
}
