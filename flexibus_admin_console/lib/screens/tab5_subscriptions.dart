import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tab5Subscriptions extends StatefulWidget {
  const Tab5Subscriptions({super.key});

  @override
  State<Tab5Subscriptions> createState() => _Tab5SubscriptionsState();
}

class _Tab5SubscriptionsState extends State<Tab5Subscriptions> {
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
          "Manage Subscription Plans",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () => _showPlanForm(),
            child: Text(
              "Add a new plan",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: gradient.colors[1],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: gradient.colors[1]),
            onPressed: () => _showPlanForm(),
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
                    hintText: "Search plan...",
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
        stream:
            FirebaseFirestore.instance
                .collection('subscription_plans')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: gradient.colors[1]),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No subscription plans found.",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          final filteredDocs =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name']?.toLowerCase() ?? '';
                final benefits =
                    (data['benefits'] as List<dynamic>)
                        .join(', ')
                        .toLowerCase();
                return name.contains(searchQuery) ||
                    benefits.contains(searchQuery);
              }).toList();

          if (filteredDocs.isEmpty) {
            return Center(
              child: Text(
                "No matching subscription plans found",
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
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _info(
                            "Benefits",
                            (data['benefits'] as List<dynamic>).join(', '),
                          ),
                          _info("Weekly Cost", "₹${data['weeklyCost']}"),
                          _info("Monthly Cost", "₹${data['monthlyCost']}"),
                          _info("Annual Cost", "₹${data['annualCost']}"),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _actionButton(
                                "Edit",
                                gradient.colors[1],
                                () => _showPlanForm(
                                  planId: doc.id,
                                  existingData: data,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _actionButton(
                                "Delete",
                                Colors.red,
                                () => _deletePlan(doc.id),
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

  void _deletePlan(String id) {
    FirebaseFirestore.instance
        .collection('subscription_plans')
        .doc(id)
        .delete();
  }

  void _showPlanForm({String? planId, Map<String, dynamic>? existingData}) {
    // Use search query as initial name if adding new plan and search query is not empty
    final initialName =
        planId == null && searchQuery.isNotEmpty
            ? searchQuery
            : existingData?['name'];

    final nameController = TextEditingController(text: initialName);
    final benefitsController = TextEditingController(
      text:
          existingData != null
              ? (existingData['benefits'] as List).join(', ')
              : '',
    );
    final weeklyCostController = TextEditingController(
      text: existingData?['weeklyCost']?.toString(),
    );
    final monthlyCostController = TextEditingController(
      text: existingData?['monthlyCost']?.toString(),
    );
    final annualCostController = TextEditingController(
      text: existingData?['annualCost']?.toString(),
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              planId == null ? "Add Plan" : "Edit Plan",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(nameController, "Plan Name"),
                  _field(benefitsController, "Benefits (comma-separated)"),
                  _field(weeklyCostController, "Weekly Cost"),
                  _field(monthlyCostController, "Monthly Cost"),
                  _field(annualCostController, "Annual Cost"),
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
                  final planData = {
                    'name': nameController.text.trim().replaceFirst(
                      nameController.text.trim()[0],
                      nameController.text.trim()[0].toUpperCase(),
                    ),
                    'benefits':
                        benefitsController.text
                            .trim()
                            .split(',')
                            .map(
                              (e) => e.trim().replaceFirst(
                                e.trim()[0],
                                e.trim()[0].toUpperCase(),
                              ),
                            )
                            .toList(),
                    'weeklyCost':
                        int.tryParse(weeklyCostController.text.trim()) ?? 0,
                    'monthlyCost':
                        int.tryParse(monthlyCostController.text.trim()) ?? 0,
                    'annualCost':
                        int.tryParse(annualCostController.text.trim()) ?? 0,
                  };

                  if (planId == null) {
                    FirebaseFirestore.instance
                        .collection('subscription_plans')
                        .add(planData);
                  } else {
                    FirebaseFirestore.instance
                        .collection('subscription_plans')
                        .doc(planId)
                        .update(planData);
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
                  planId == null ? "Add" : "Update",
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
