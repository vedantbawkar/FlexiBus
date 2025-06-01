import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PopularRoutesSection extends StatelessWidget {
  const PopularRoutesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Popular Routes",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const HorizontalButtonSlider(),
        ],
      ),
    );
  }
}

class HorizontalButtonSlider extends StatefulWidget {
  const HorizontalButtonSlider({super.key});

  @override
  State<HorizontalButtonSlider> createState() => _HorizontalButtonSliderState();
}

class _HorizontalButtonSliderState extends State<HorizontalButtonSlider> {
  final ScrollController _scrollController = ScrollController();

  final List<Color> gradientColors = const [
    Color(0xFF00B4D8),
    Color(0xFF00B4D8),
    Color(0xFF00B4D8),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('routes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No routes available',
                style: GoogleFonts.poppins(color: Colors.black54),
              ),
            );
          }

          final routes = snapshot.data!.docs;
          final List<List<DocumentSnapshot>> columns = [];
          for (var i = 0; i < routes.length; i += 3) {
            columns.add(routes.skip(i).take(3).toList());
          }

          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: columns.length,
            itemBuilder: (context, columnIndex) {
              return Padding(
                padding: EdgeInsets.only(
                  left: columnIndex == 0 ? 0 : 4,
                  right: columnIndex == columns.length - 1 ? 0 : 4,
                ),
                child: Column(
                  children:
                      columns[columnIndex].map((route) {
                        final data = route.data() as Map<String, dynamic>;
                        return Expanded(
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2.2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/route-details',
                                      arguments: route.id,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_bus,
                                          color: gradientColors[1],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            "${data['routeNumber']}",
                                            style: GoogleFonts.poppins(
                                              color: gradientColors[0],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
