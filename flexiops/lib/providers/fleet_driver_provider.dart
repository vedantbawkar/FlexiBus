// providers/driver_provider.dart
import 'package:flexiops/models/driver.dart';
import 'package:flexiops/services/driver_service.dart';
import 'package:flutter/material.dart';

class DriverProvider with ChangeNotifier {
  final DriverService _service = DriverService();
  List<DriverModel> _drivers = [];

  List<DriverModel> get drivers => _drivers;

  void loadDrivers(String fleetOperatorId) {
    _service.getDrivers(fleetOperatorId).listen((driverList) {
      _drivers = driverList;
      notifyListeners();
    });
  }

  Future<void> addDriver(DriverModel driver) async {
    await _service.addDriver(driver);
  }

  Future<void> updateDriver(DriverModel driver) async {
    await _service.updateDriver(driver);
  }

  Future<void> deleteDriver(String id) async {
    await _service.deleteDriver(id);
  }
}