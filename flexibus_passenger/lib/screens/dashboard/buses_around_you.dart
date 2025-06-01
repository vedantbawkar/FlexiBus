import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusesAroundYouSection extends StatelessWidget {
  const BusesAroundYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            "Buses around you",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Map Container
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Map Background (placeholder)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey.shade100,
                    child: Image.network(
                      'https://maps.googleapis.com/maps/api/staticmap?center=19.0760,72.8777&zoom=14&size=600x400&maptype=roadmap&markers=color:green%7Clabel:B%7C19.0760,72.8777&markers=color:blue%7Clabel:S%7C19.0800,72.8850&key=YOUR_API_KEY',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildMapPlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildMapPlaceholder();
                      },
                    ),
                  ),

                  // Map Overlay Elements
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_bus,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Live Buses",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Location markers
                  Positioned(
                    top: 60,
                    left: 80,
                    child: _buildLocationMarker(
                      "Sector 22",
                      "सेक्टर २२",
                      Colors.grey.shade600,
                    ),
                  ),

                  Positioned(
                    top: 40,
                    right: 60,
                    child: _buildLocationMarker(
                      "Rock Garden",
                      "",
                      Colors.green.shade600,
                    ),
                  ),

                  Positioned(
                    bottom: 40,
                    left: 60,
                    child: _buildLocationMarker(
                      "Sector 21",
                      "सेक्टर २१",
                      Colors.grey.shade600,
                    ),
                  ),

                  Positioned(
                    bottom: 30,
                    right: 40,
                    child: _buildLocationMarker(
                      "Wonders Park",
                      "",
                      Colors.purple.shade400,
                    ),
                  ),

                  // Google attribution
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        "Google",
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.green.shade50,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Simulated map roads
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(height: 3, color: Colors.white),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Container(height: 2, color: Colors.white70),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 100,
            child: Container(width: 3, color: Colors.white),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 80,
            child: Container(width: 2, color: Colors.white70),
          ),

          // Center location indicator
          Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMarker(String title, String subtitle, Color color) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(Icons.location_on, size: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
              ],
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
