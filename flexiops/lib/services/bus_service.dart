import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus.dart';

class BusService {
  final CollectionReference _busRef = FirebaseFirestore.instance.collection(
    'buses',
  );

  // Add a new bus
  Future<void> addBus(Bus bus) async {
    try {
      await _busRef.doc(bus.id).set(bus.toMap());
    } catch (e) {
      throw Exception("Error adding bus: $e");
    }
  }

  // Fetch all buses
  Future<List<Bus>> fetchAllBuses(String fleetOperatorId) async {
    try {
      final querySnapshot =
          await _busRef
              .where('fleetOperatorId', isEqualTo: fleetOperatorId)
              .get();
      return querySnapshot.docs
          .where((doc) => doc.exists)
          .map((doc) => Bus.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception("Error fetching buses: $e");
    }
  }

  // Update an existing bus
  Future<void> updateBus(Bus bus) async {
    try {
      await _busRef.doc(bus.id).update(bus.toMap());
    } catch (e) {
      throw Exception("Error updating bus: $e");
    }
  }

  // Delete a bus by ID
  Future<void> deleteBus(String busId) async {
    try {
      await _busRef.doc(busId).delete();
    } catch (e) {
      throw Exception("Error deleting bus: $e");
    }
  }
}
