import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class Tab6Coupons extends StatefulWidget {
  const Tab6Coupons({super.key});

  @override
  State<Tab6Coupons> createState() => _Tab6CouponsState();
}

class _Tab6CouponsState extends State<Tab6Coupons> {
  final _searchController = TextEditingController();
  String searchText = '';

  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Manage Coupons",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: _showAddCouponDialog,
            child: Text(
              "Add a new coupon",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: gradient.colors[1],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: gradient.colors[1]),
            onPressed: _showAddCouponDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    hintText: "Search by name or code...",
                    hintStyle: GoogleFonts.poppins(color: Colors.black54),
                    prefixIcon: Icon(Icons.search, color: gradient.colors[1]),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: gradient.colors.first),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase().trim();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: gradient.colors[1]),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No coupons found",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final filteredDocs =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name']?.toLowerCase() ?? '';
                final code = data['couponCode']?.toLowerCase() ?? '';
                return name.contains(searchText) || code.contains(searchText);
              }).toList();

          if (filteredDocs.isEmpty) {
            return Center(
              child: Text(
                "No matching coupons found",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: CouponClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.colors[1].withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left section with gradient background (25% width)
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(gradient: gradient),
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      data['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Vertical dotted line separator
                              CustomPaint(
                                painter: DottedLinePainter(
                                  color: Colors.black12,
                                ),
                                child: const SizedBox(
                                  width: 1,
                                  height: double.infinity,
                                ),
                              ),
                              // Right section with details (75% width)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _infoRow("Code", data['couponCode']),
                                      _infoRow(
                                        "Expiry",
                                        DateFormat.yMMMd().format(
                                          (data['expiryDate'] as Timestamp)
                                              .toDate(),
                                        ),
                                      ),
                                      _infoRow(
                                        "Benefits",
                                        (data['benefits'] as List).join(', '),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          _actionButton(
                                            "Edit",
                                            gradient.colors[1],
                                            () =>
                                                _editCouponDialog(doc.id, data),
                                          ),
                                          const SizedBox(width: 8),
                                          _actionButton(
                                            "Delete",
                                            Colors.red,
                                            () => _deleteCoupon(doc.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Top circle
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.2 - 10,
                      top: -10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                    ),
                    // Bottom circle
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.2 - 10,
                      bottom: -10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
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

  Widget _infoRow(String label, String value) {
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
              value,
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

  void _deleteCoupon(String id) {
    FirebaseFirestore.instance.collection('coupons').doc(id).delete();
  }

  void _showAddCouponDialog() {
    _couponDialog();
  }

  void _editCouponDialog(String docId, Map<String, dynamic> data) {
    _couponDialog(docId: docId, existing: data);
  }

  void _couponDialog({String? docId, Map<String, dynamic>? existing}) {
    final nameController = TextEditingController(text: existing?['name']);
    final codeController = TextEditingController(text: existing?['couponCode']);
    final benefitsController = TextEditingController(
      text: existing != null ? (existing['benefits'] as List).join(', ') : '',
    );
    DateTime? selectedDate =
        existing?['expiryDate'] != null
            ? (existing!['expiryDate'] as Timestamp).toDate()
            : null;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              docId == null ? "Add Coupon" : "Edit Coupon",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(nameController, "Coupon Name"),
                  _field(codeController, "Coupon Code"),
                  _field(benefitsController, "Benefits (comma separated)"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Expiry Date:",
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        selectedDate != null
                            ? DateFormat.yMMMd().format(selectedDate!)
                            : "Not selected",
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: gradient.colors[1],
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                            Navigator.pop(context);
                            _couponDialog(
                              docId: docId,
                              existing: {
                                'name': nameController.text,
                                'couponCode': codeController.text,
                                'benefits':
                                    benefitsController.text
                                        .split(',')
                                        .map((e) => e.trim())
                                        .toList(),
                                'expiryDate': Timestamp.fromDate(picked),
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: Colors.black54),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newData = {
                    'name': nameController.text.trim(),
                    'couponCode': codeController.text.trim(),
                    'benefits':
                        benefitsController.text
                            .trim()
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                    'expiryDate': Timestamp.fromDate(
                      selectedDate ?? DateTime.now(),
                    ),
                  };

                  if (docId == null) {
                    FirebaseFirestore.instance
                        .collection('coupons')
                        .add(newData);
                  } else {
                    FirebaseFirestore.instance
                        .collection('coupons')
                        .doc(docId)
                        .update(newData);
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: gradient.colors[1],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  docId == null ? "Add" : "Update",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: gradient.colors.first),
          ),
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }
}

class CouponClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Main rectangle with rounded corners
    path.moveTo(10, 0);
    path.lineTo(size.width - 10, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 10);
    path.lineTo(size.width, size.height - 10);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - 10,
      size.height,
    );
    path.lineTo(10, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 10);
    path.lineTo(0, 10);
    path.quadraticBezierTo(0, 0, 10, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const dashHeight = 5;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
