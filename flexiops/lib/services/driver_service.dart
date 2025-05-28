// services/driver_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flexiops/models/driver.dart';

class DriverService {
  final CollectionReference driversCollection = FirebaseFirestore.instance.collection('opusers');

  Future<void> addDriver(DriverModel driver) async {
    await driversCollection.doc(driver.id).set(driver.toMap());
  }

  Future<void> updateDriver(DriverModel driver) async {
    await driversCollection.doc(driver.id).update(driver.toMap());
  }

  Future<void> deleteDriver(String id) async {
    await driversCollection.doc(id).delete();
  }

  Stream<List<DriverModel>> getDrivers(String fleetOperatorId) {
    return driversCollection
        .where('fleetOperatorId', isEqualTo: fleetOperatorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DriverModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}