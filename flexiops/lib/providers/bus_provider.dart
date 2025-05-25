import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../services/bus_service.dart';

class BusProvider extends ChangeNotifier {
  final BusService _busService = BusService();
  List<Bus> _buses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Bus> get buses => _buses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBuses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _buses = await _busService.fetchAllBuses();
    } catch (e) {
      debugPrint("Error fetching buses: $e");
      _errorMessage = "Failed to fetch buses. Please try again.";
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetBuses() {
    _buses = [];
    notifyListeners();
  }

  Bus? getBusById(String id) {
    try {
      return _buses.firstWhere((bus) => bus.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addBus(Bus bus) async {
    try {
      await _busService.addBus(bus);
      await fetchBuses();
    } catch (e) {
      debugPrint("Error adding bus: $e");
      _errorMessage = "Failed to add bus. Please try again.";
      notifyListeners();
    }
  }

  Future<void> deleteBus(String id) async {
    try {
      await _busService.deleteBus(id);
      _buses.removeWhere((bus) => bus.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting bus: $e");
      _errorMessage = "Failed to delete bus. Please try again.";
      notifyListeners();
    }
  }

  Future<void> updateBus(Bus updatedBus) async {
    try {
      await _busService.updateBus(updatedBus);
      int index = _buses.indexWhere((bus) => bus.id == updatedBus.id);
      if (index != -1) {
        _buses[index] = updatedBus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating bus: $e");
      _errorMessage = "Failed to update bus. Please try again.";
      notifyListeners();
    }
  }
}
