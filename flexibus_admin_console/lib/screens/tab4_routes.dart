import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tab4Routes extends StatefulWidget {
  const Tab4Routes({super.key});

  @override
  State<Tab4Routes> createState() => _Tab4RoutesState();
}

class _Tab4RoutesState extends State<Tab4Routes> {
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
      appBar: AppBar(
        title: Text(
          "Manage Bus Routes",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: gradient.colors[1]),
            onPressed: () => _showRouteForm(),
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
                  decoration: InputDecoration(
                    hintText: "Search route or stop...",
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
                  style: GoogleFonts.poppins(),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase().trim();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('routes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: gradient.colors[1]),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No routes found.",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final filteredDocs =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final routeNumber =
                    data['routeNumber']?.toString().toLowerCase() ?? '';
                final stops =
                    (data['stops'] as List<dynamic>).join(', ').toLowerCase();
                return routeNumber.contains(searchQuery) ||
                    stops.contains(searchQuery);
              }).toList();

          if (filteredDocs.isEmpty) {
            return Center(
              child: Text(
                "No matching routes found",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final route = filteredDocs[index];
              final data = route.data() as Map<String, dynamic>;

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
                              "Route ${data['routeNumber'] ?? 'N/A'}",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
                          _info(
                            "Stops",
                            (data['stops'] as List<dynamic>).join(', '),
                          ),
                          _info("Base Fare", "₹${data['baseFare']}"),
                          _info("Max Fare", "₹${data['maxFare']}"),
                          _info(
                            "Timings",
                            (data['timings'] as List<dynamic>).join(', '),
                          ),
                          _info(
                            "Weekdays",
                            (data['weekdays'] as List<dynamic>).join(', '),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _actionButton(
                                "Edit",
                                gradient.colors[1],
                                () => _showRouteForm(
                                  routeId: route.id,
                                  existingData: data,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _actionButton(
                                "Delete",
                                Colors.red,
                                () => _deleteRoute(route.id),
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

  Widget _info(String label, String value) {
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

  void _deleteRoute(String id) {
    FirebaseFirestore.instance.collection('routes').doc(id).delete();
  }

  void _showRouteForm({String? routeId, Map<String, dynamic>? existingData}) {
    final routeNumberController = TextEditingController(
      text: existingData?['routeNumber'],
    );
    final stopsController = TextEditingController(
      text:
          existingData != null
              ? (existingData['stops'] as List).join(', ')
              : '',
    );
    final baseFareController = TextEditingController(
      text: existingData?['baseFare']?.toString(),
    );
    final maxFareController = TextEditingController(
      text: existingData?['maxFare']?.toString(),
    );
    final timingsController = TextEditingController(
      text:
          existingData != null
              ? (existingData['timings'] as List).join(', ')
              : '',
    );
    final weekdaysController = TextEditingController(
      text:
          existingData != null
              ? (existingData['weekdays'] as List).join(', ')
              : '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              routeId == null ? "Add Route" : "Edit Route",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(routeNumberController, "Route Number"),
                  _field(stopsController, "Stops (comma-separated)"),
                  _field(baseFareController, "Base Fare"),
                  _field(maxFareController, "Max Fare"),
                  _field(timingsController, "Timings (comma-separated)"),
                  _field(weekdaysController, "Weekdays (comma-separated)"),
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
                  final newRoute = {
                    'routeNumber': routeNumberController.text.trim(),
                    'stops':
                        stopsController.text
                            .trim()
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                    'baseFare':
                        int.tryParse(baseFareController.text.trim()) ?? 0,
                    'maxFare': int.tryParse(maxFareController.text.trim()) ?? 0,
                    'timings':
                        timingsController.text
                            .trim()
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                    'weekdays':
                        weekdaysController.text
                            .trim()
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                  };

                  if (routeId == null) {
                    FirebaseFirestore.instance
                        .collection('routes')
                        .add(newRoute);
                  } else {
                    FirebaseFirestore.instance
                        .collection('routes')
                        .doc(routeId)
                        .update(newRoute);
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
                  routeId == null ? "Add" : "Update",
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
