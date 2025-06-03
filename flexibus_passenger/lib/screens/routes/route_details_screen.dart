import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../booking/book_ticket.dart'; // Add this import

class RouteDetailsScreen extends StatefulWidget {
  final String routeId;
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  const RouteDetailsScreen({super.key, required this.routeId});

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  int? selectedSourceIndex;
  int? selectedDestinationIndex;

  bool get isBookingEnabled =>
      selectedSourceIndex != null &&
      selectedDestinationIndex != null &&
      selectedSourceIndex != selectedDestinationIndex;

  void _selectSource(int index) {
    setState(() {
      selectedSourceIndex = index;
      // Clear destination if it's the same as source
      if (selectedDestinationIndex == index) {
        selectedDestinationIndex = null;
      }
    });
  }

  void _selectDestination(int index) {
    setState(() {
      selectedDestinationIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: widget.gradient),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('routes')
                  .doc(widget.routeId)
                  .snapshots(),
          builder: (context, snapshot) {
            final routeData =
                snapshot.data?.data() as Map<String, dynamic>? ?? {};
            return Text(
              'Route ${routeData['routeNumber'] ?? widget.routeId} Details',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('routes')
                .doc(widget.routeId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Route not found',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final routeData = snapshot.data!.data() as Map<String, dynamic>;

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Map Preview (placeholder)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(gradient: widget.gradient),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 64, color: Colors.white),
                            Text(
                              'Route Map Preview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            'Stops',
                            _buildStopsSection(routeData['stops'] as List),
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            'Fare Details',
                            Column(
                              children: [
                                _buildFareDetail(
                                  'Base Fare',
                                  '₹${routeData['baseFare']}',
                                ),
                                const SizedBox(height: 8),
                                _buildFareDetail(
                                  'Maximum Fare',
                                  '₹${routeData['maxFare']}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            'Schedule',
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Operating Days',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children:
                                      (routeData['weekdays'] as List)
                                          .map(
                                            (day) => Chip(
                                              label: Text(
                                                day,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor:
                                                  widget.gradient.colors[1],
                                            ),
                                          )
                                          .toList(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Timings',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children:
                                      (routeData['timings'] as List)
                                          .map(
                                            (time) => Chip(
                                              label: Text(
                                                time,
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      widget.gradient.colors[1],
                                                ),
                                              ),
                                              backgroundColor: widget
                                                  .gradient
                                                  .colors[1]
                                                  .withOpacity(0.1),
                                              side: BorderSide(
                                                color:
                                                    widget.gradient.colors[1],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Selection Summary
                          if (selectedSourceIndex != null ||
                              selectedDestinationIndex != null)
                            _buildSelectionSummary(routeData['stops'] as List),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        isBookingEnabled
                            ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BookTicket(
                                        routeNumber: routeData['routeNumber'],
                                        source:
                                            routeData['stops'][selectedSourceIndex!],
                                        destination:
                                            routeData['stops'][selectedDestinationIndex!],
                                      ),
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isBookingEnabled
                              ? widget.gradient.colors[1]
                              : Colors.grey[400],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Book This Route',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStopsSection(List stops) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          stops.length,
          (index) => _buildStopItem(stops[index], index, stops.length),
        ),
      ),
    );
  }

  Widget _buildStopItem(String stopName, int index, int totalStops) {
    bool isSource = selectedSourceIndex == index;
    bool isDestination = selectedDestinationIndex == index;
    bool isDestinationEnabled =
        selectedSourceIndex != null && selectedSourceIndex != index;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom:
              index < totalStops - 1
                  ? BorderSide(color: Colors.grey[200]!, width: 1)
                  : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          // Stop number with connecting line
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      (isSource || isDestination)
                          ? widget.gradient.colors[1]
                          : widget.gradient.colors[1].withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (index < totalStops - 1)
                Container(
                  width: 2,
                  height: 20,
                  color: widget.gradient.colors[1].withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Stop name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stopName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (isSource || isDestination)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSource
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isSource ? 'Source' : 'Destination',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isSource ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              // Source selection button
              GestureDetector(
                onTap: () => _selectSource(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSource ? Colors.green : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: isSource ? Colors.white : Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Destination selection button
              GestureDetector(
                onTap:
                    isDestinationEnabled
                        ? () => _selectDestination(index)
                        : null,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isDestination
                            ? Colors.red
                            : isDestinationEnabled
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.stop,
                    size: 20,
                    color:
                        isDestination
                            ? Colors.white
                            : isDestinationEnabled
                            ? Colors.red[700]
                            : Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionSummary(List stops) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.gradient.colors[1].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.gradient.colors[1].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedSourceIndex != null)
            Row(
              children: [
                Icon(Icons.play_arrow, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'From: ${stops[selectedSourceIndex!]}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          if (selectedDestinationIndex != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.stop, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'To: ${stops[selectedDestinationIndex!]}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildFareDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
