class Bus {
  final String id;
  final String modelName;
  final String company;
  final int seatingCapacity;
  final String numberPlate;
  final int age;
  final bool haveCameraEnabled;
  final String exteriorImages;
  final String interiorImages;
  final String fleetOperatorId; // Foreign key reference

  Bus({
    required this.id,
    required this.modelName,
    required this.company,
    required this.seatingCapacity,
    required this.numberPlate,
    required this.age,
    required this.haveCameraEnabled,
    required this.exteriorImages,
    required this.interiorImages,
    required this.fleetOperatorId,
  });

  factory Bus.fromMap(Map<String, dynamic> data, String id) {
    return Bus(
      id: id,
      modelName: data['bus_name'] ?? '',
      company: data['company'] ?? '',
      seatingCapacity: data['seating-capacity'] ?? 0,
      numberPlate: data['number_plate'] ?? '',
      age: data['age'] ?? 0,
      haveCameraEnabled: data['haveCameraEnabled'] ?? false,
      exteriorImages: data['exterior_images'] ?? '',
      interiorImages: data['interior_images'] ?? '',
      fleetOperatorId: data['fleetOperatorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bus_name': modelName,
      'company': company,
      'seating-capacity': seatingCapacity,
      'number_plate': numberPlate,
      'age': age,
      'haveCameraEnabled': haveCameraEnabled,
      'exterior_images': exteriorImages,
      'interior_images': interiorImages,
      'fleetOperatorId': fleetOperatorId,
    };
  }
}
