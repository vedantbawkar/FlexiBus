import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Footer Text
          Text(
            "FlexiBus",
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade300,
              height: 0.9,
            ),
          ),
          Text(
            "Hop On,",
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade300,
              height: 0.9,
            ),
          ),
          const SizedBox(height: 8), // Added margin between lines
          Text(
            "Ride Smart.",
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade300,
              height: 0.9,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            "Crafted with 💙 in India",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
