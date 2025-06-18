import 'package:flexibus_passenger/screens/subscription/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookTicket extends StatefulWidget {
  final String? routeNumber;
  final String? source;
  final String? destination;
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  const BookTicket({
    super.key,
    this.routeNumber,
    this.source,
    this.destination,
  });

  @override
  State<BookTicket> createState() => _BookTicketState();
}

class _BookTicketState extends State<BookTicket> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _routeNumberController;
  late TextEditingController _sourceController;
  late TextEditingController _destinationController;
  String? _selectedTiming;
  List<String> _availableTimings = [];
  List<String> _availableStops = [];
  String? _routeNumberError;
  bool? _isRouteNumberValid; // Changed to nullable boolean
  bool _isSourceFocused = false;
  bool _isDestinationFocused = false;
  final FocusNode _sourceFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  bool _isRouteDataLoaded = false;

  final double _ticketFare = 100.0;
  double _walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _routeNumberController = TextEditingController(text: widget.routeNumber);
    _sourceController = TextEditingController(text: widget.source);
    _destinationController = TextEditingController(text: widget.destination);
    _loadWalletBalance();

    _sourceFocusNode.addListener(() {
      setState(() {
        _isSourceFocused = _sourceFocusNode.hasFocus;
        if (!_isSourceFocused &&
            !_availableStops.contains(_sourceController.text)) {
          _sourceController.clear();
        }
      });
    });

    _destinationFocusNode.addListener(() {
      setState(() {
        _isDestinationFocused = _destinationFocusNode.hasFocus;
        if (!_isDestinationFocused &&
            !_availableStops.contains(_destinationController.text)) {
          _destinationController.clear();
        }
      });
    });

    if (widget.routeNumber != null) {
      _fetchTimings(_routeNumberController.text);
    }
  }

  Future<void> _loadWalletBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('passengers')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        setState(() {
          _walletBalance = (doc.data()?['wallet_balance'] ?? 0).toDouble();
        });
      }
    }
  }

  @override
  void dispose() {
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();
    _routeNumberController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTimings(String routeNumber) async {
    if (routeNumber.isEmpty) {
      setState(() {
        _isRouteNumberValid = false;
        _isRouteDataLoaded = false;
        _availableTimings = [];
        _availableStops = [];
      });
      return;
    }

    try {
      final routeDoc =
          await FirebaseFirestore.instance
              .collection('routes')
              .where('routeNumber', isEqualTo: routeNumber)
              .get();

      setState(() {
        if (routeDoc.docs.isEmpty) {
          _routeNumberError = "We don't serve on this route yet";
          _isRouteNumberValid = false;
          _isRouteDataLoaded = false;
          _availableTimings = [];
          _availableStops = [];
        } else {
          _routeNumberError = null;
          _isRouteNumberValid = true;
          _isRouteDataLoaded = true;
          final routeData = routeDoc.docs.first.data();
          _availableTimings = List<String>.from(routeData['timings'] ?? []);
          _availableStops = List<String>.from(routeData['stops'] ?? []);

          // Clear source and destination if not pre-filled
          if (widget.source == null) {
            _sourceController.clear();
          }
          if (widget.destination == null) {
            _destinationController.clear();
          }
        }
      });
    } catch (e) {
      setState(() {
        _routeNumberError = "Error fetching route details";
        _isRouteNumberValid = false;
        _isRouteDataLoaded = false;
        _availableTimings = [];
        _availableStops = [];
      });
      debugPrint('Error fetching timings: $e');
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool enabled = true,
    bool isRouteNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              color:
                  isRouteNumber && _isRouteNumberValid == false
                      ? Colors.red
                      : Colors.black54,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color:
                  isRouteNumber && _isRouteNumberValid == false
                      ? Colors.red
                      : widget.gradient.colors[1],
            ),
            suffixIcon:
                isRouteNumber
                    ? IconButton(
                      icon: Icon(
                        Icons.search,
                        color: widget.gradient.colors[1],
                      ),
                      onPressed: () {
                        _fetchTimings(controller.text);
                        FocusScope.of(context).unfocus();
                      },
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isRouteNumber && _isRouteNumberValid == false
                        ? Colors.red
                        : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isRouteNumber && _isRouteNumberValid == false
                        ? Colors.red
                        : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isRouteNumber && _isRouteNumberValid == false
                        ? Colors.red
                        : widget.gradient.colors[1],
              ),
            ),
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey[100],
          ),
          style: GoogleFonts.poppins(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (isRouteNumber && _routeNumberError != null) {
              return _routeNumberError;
            }
            return null;
          },
          onChanged:
              isRouteNumber
                  ? (value) {
                    if (_isRouteNumberValid == false) {
                      setState(() {
                        _isRouteNumberValid = null;
                        _routeNumberError = null;
                        _isRouteDataLoaded = false;
                      });
                    }
                  }
                  : null,
          onEditingComplete:
              isRouteNumber
                  ? () {
                    _fetchTimings(controller.text);
                    FocusScope.of(context).unfocus();
                  }
                  : null,
        ),
        if (isRouteNumber && _routeNumberError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              _routeNumberError!,
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTimingSelector() {
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
        children:
            _availableTimings.map((timing) {
              bool isSelected = _selectedTiming == timing;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedTiming = timing;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    color:
                        isSelected
                            ? widget.gradient.colors[1].withOpacity(0.1)
                            : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color:
                            isSelected
                                ? widget.gradient.colors[1]
                                : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timing,
                        style: GoogleFonts.poppins(
                          color:
                              isSelected
                                  ? widget.gradient.colors[1]
                                  : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: widget.gradient.colors[1],
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFareSection() {
    bool showFare =
        _sourceController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty;
    if (!showFare) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fare Details'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ticket Fare',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '₹${_ticketFare.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.gradient.colors[1],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wallet Balance',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '₹${_walletBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color:
                          _walletBalance >= _ticketFare
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              if (_walletBalance < _ticketFare)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Insufficient wallet balance. Please add funds to continue.',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    bool isInsufficientBalance = _walletBalance < _ticketFare;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            (_selectedTiming == null ||
                    isInsufficientBalance ||
                    !_isRouteDataLoaded)
                ? null
                : () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please login to book tickets',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Create booking timestamp
                      final now = DateTime.now();
                      final validTill = now.add(const Duration(minutes: 15));

                      // Create ticket data
                      final ticketData = {
                        'source': _sourceController.text,
                        'destination': _destinationController.text,
                        'route_no': _routeNumberController.text,
                        'timing': _selectedTiming,
                        'fare': _ticketFare,
                        'type': 'ticket',
                        'booked_at': Timestamp.fromDate(now),
                        'valid_till': Timestamp.fromDate(validTill),
                      };

                      // Update wallet balance and add ticket
                      await FirebaseFirestore.instance
                          .collection('passengers')
                          .doc(user.uid)
                          .update({
                            'tickets_and_passes': FieldValue.arrayUnion([
                              ticketData,
                            ]),
                            'wallet_balance': FieldValue.increment(
                              -_ticketFare,
                            ),
                            'transaction_logs': FieldValue.arrayUnion([
                              {
                                'type': 'Debit',
                                'amount': _ticketFare,
                                'date': DateTime.now().toIso8601String(),
                                'description': 'Ticket Booking',
                              },
                            ]),
                          });

                      // Show success message and navigate to home
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Ticket booked successfully!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: widget.gradient.colors[1],
                          ),
                        );

                        // Navigate to tickets screen while preserving home screen
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                          // Keep home screen in stack
                          (Route<dynamic> route) => route.isFirst,
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error booking ticket: ${e.toString()}',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.gradient.colors[1],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: Text(
          isInsufficientBalance ? 'Insufficient Balance' : 'Confirm Booking',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStopTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    required bool isSource,
    required FocusNode focusNode,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled:
              enabled &&
              _isRouteDataLoaded, // Changed to use _isRouteDataLoaded
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
              color:
                  _isRouteDataLoaded
                      ? Colors.black54
                      : Colors.grey, // Grey out label when disabled
            ),
            prefixIcon: Icon(
              prefixIcon,
              color:
                  _isRouteDataLoaded
                      ? widget.gradient.colors[1]
                      : Colors.grey, // Grey out icon when disabled
            ),
            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.gradient.colors[1]),
            ),
            filled: !_isRouteDataLoaded, // Fill when disabled
            fillColor: _isRouteDataLoaded ? null : Colors.grey[100],
            hintText:
                _isRouteDataLoaded
                    ? null
                    : 'Enter route number first', // Hint when disabled
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
          ),
          style: GoogleFonts.poppins(
            color:
                _isRouteDataLoaded
                    ? Colors.black
                    : Colors.grey, // Grey out text when disabled
          ),
          readOnly: true,
          onTap:
              enabled && _isRouteDataLoaded
                  ? () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => _buildSearchDialog(
                            isSource: isSource,
                            controller: controller,
                          ),
                    );
                  }
                  : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (!_availableStops.contains(value)) {
              return 'Please select a valid stop';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSearchDialog({
    required bool isSource,
    required TextEditingController controller,
  }) {
    // Get the stop to exclude based on what's already selected
    final stopToExclude =
        isSource ? _destinationController.text : _sourceController.text;

    // Filter out the already selected stop
    var availableStops =
        _availableStops.where((stop) => stop != stopToExclude).toList();

    return StatefulBuilder(
      builder: (context, setDialogState) {
        List<String> filteredStops = availableStops;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select ${isSource ? "Source" : "Destination"}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search stop...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: widget.gradient.colors[1],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      filteredStops =
                          availableStops
                              .where(
                                (stop) => stop.toLowerCase().startsWith(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                    });
                  },
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredStops.length,
                    itemBuilder: (context, index) {
                      final stop = filteredStops[index];
                      return ListTile(
                        dense: true,
                        title: Text(stop, style: GoogleFonts.poppins()),
                        onTap: () {
                          controller.text = stop;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: widget.gradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Ticket',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Journey Details'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _routeNumberController,
                  label: 'Route Number',
                  enabled: widget.routeNumber == null,
                  prefixIcon: Icons.route,
                  isRouteNumber: true,
                ),
                const SizedBox(height: 16),
                _buildStopTextField(
                  controller: _sourceController,
                  label: 'Source',
                  enabled: widget.source == null,
                  prefixIcon: Icons.location_on_outlined,
                  isSource: true,
                  focusNode: _sourceFocusNode,
                ),
                const SizedBox(height: 16),
                _buildStopTextField(
                  controller: _destinationController,
                  label: 'Destination',
                  enabled: widget.destination == null,
                  prefixIcon: Icons.location_on,
                  isSource: false,
                  focusNode: _destinationFocusNode,
                ),
                const SizedBox(height: 24),
                if (_sourceController.text.isNotEmpty &&
                    _destinationController.text.isNotEmpty) ...[
                  _buildFareSection(),
                  const SizedBox(height: 24),
                ],
                if (_isRouteDataLoaded) ...[
                  _buildSectionTitle('Select Timing'),
                  const SizedBox(height: 16),
                  _buildTimingSelector(),
                  const SizedBox(height: 32),
                ],
                _buildBookButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
