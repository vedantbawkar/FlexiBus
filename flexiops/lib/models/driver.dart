// models/driver_model.dart
class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String license;
  final String? busAssigned;
  final String status;
  final String fleetOperatorId;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.license,
    this.busAssigned,
    required this.status,
    required this.fleetOperatorId,
  });

  factory DriverModel.fromMap(Map<String, dynamic> data, String documentId) {
    return DriverModel(
      id: documentId,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      license: data['license'] ?? '',
      busAssigned: data['busAssigned'],
      status: data['status'] ?? 'inactive',
      fleetOperatorId: data['fleetOperatorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'license': license,
      'busAssigned': busAssigned,
      'status': status,
      'fleetOperatorId': fleetOperatorId,
    };
  }
}