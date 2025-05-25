import 'package:flexiops/providers/bus_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '/models/bus.dart';
import '/providers/theme_provider.dart';

class FleetViewScreen extends StatefulWidget {
  const FleetViewScreen({Key? key}) : super(key: key);

  @override
  State<FleetViewScreen> createState() => _FleetViewScreenState();
}

class _FleetViewScreenState extends State<FleetViewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<BusProvider>(context, listen: false).fetchBuses(),
    );
  }

  void _showAddBusForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final uuid = Uuid();

    String modelName = '';
    String company = '';
    String numberPlate = '';
    String exteriorImages = '';
    String interiorImages = '';
    int age = 0;
    int seatingCapacity = 0;
    bool haveCameraEnabled = false;
    String fleetOperatorId = 'default_operator_id';

    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.70,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: StatefulBuilder(
                  builder:
                      (context, setState) => Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_bus_filled,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Add New Bus',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ...[
                              'Bus Name',
                              'Company',
                              'Number Plate',
                              'Age',
                              'Seating Capacity',
                              'Exterior Image URL',
                              'Interior Image URL',
                            ].map(
                              (label) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: label,
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: _getIconForField(label, theme),
                                  ),
                                  keyboardType:
                                      [
                                            'Age',
                                            'Seating Capacity',
                                          ].contains(label)
                                          ? TextInputType.number
                                          : TextInputType.text,
                                  onSaved: (val) {
                                    switch (label) {
                                      case 'Bus Name':
                                        modelName = val ?? '';
                                        break;
                                      case 'Company':
                                        company = val ?? '';
                                        break;
                                      case 'Number Plate':
                                        numberPlate = val ?? '';
                                        break;
                                      case 'Age':
                                        age = int.tryParse(val ?? '') ?? 0;
                                        break;
                                      case 'Seating Capacity':
                                        seatingCapacity =
                                            int.tryParse(val ?? '') ?? 0;
                                        break;
                                      case 'Exterior Image URL':
                                        exteriorImages = val ?? '';
                                        break;
                                      case 'Interior Image URL':
                                        interiorImages = val ?? '';
                                        break;
                                    }
                                  },
                                  validator:
                                      (val) => val!.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.videocam,
                                      size: 20,
                                      color:
                                          haveCameraEnabled
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Camera Enabled',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                value: haveCameraEnabled,
                                onChanged: (val) {
                                  setState(() {
                                    haveCameraEnabled = val ?? false;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  final newBus = Bus(
                                    id: uuid.v4(),
                                    modelName: modelName,
                                    company: company,
                                    numberPlate: numberPlate,
                                    exteriorImages: exteriorImages,
                                    interiorImages: interiorImages,
                                    age: age,
                                    seatingCapacity: seatingCapacity,
                                    haveCameraEnabled: haveCameraEnabled,
                                    fleetOperatorId: fleetOperatorId,
                                  );
                                  Provider.of<BusProvider>(
                                    context,
                                    listen: false,
                                  ).addBus(newBus);
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add),
                                  const SizedBox(width: 8),
                                  const Text('Add Bus'),
                                ],
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
  }

  Widget _getIconForField(String label, ThemeData theme) {
    switch (label) {
      case 'Bus Name':
        return Icon(Icons.directions_bus, color: theme.colorScheme.primary);
      case 'Company':
        return Icon(Icons.business, color: theme.colorScheme.primary);
      case 'Number Plate':
        return Icon(Icons.numbers, color: theme.colorScheme.primary);
      case 'Age':
        return Icon(Icons.calendar_today, color: theme.colorScheme.primary);
      case 'Seating Capacity':
        return Icon(
          Icons.airline_seat_recline_normal,
          color: theme.colorScheme.primary,
        );
      case 'Exterior Image URL':
        return Icon(Icons.image, color: theme.colorScheme.primary);
      case 'Interior Image URL':
        return Icon(Icons.airline_seat_flat, color: theme.colorScheme.primary);
      default:
        return Icon(Icons.info, color: theme.colorScheme.primary);
    }
  }

  void _showEditBusDialog(BuildContext context, Bus bus) {
    final _formKey = GlobalKey<FormState>();

    // Pre-populate form fields with existing bus data
    String modelName = bus.modelName;
    String company = bus.company;
    String numberPlate = bus.numberPlate;
    String exteriorImages = bus.exteriorImages;
    String interiorImages = bus.interiorImages;
    int age = bus.age;
    int seatingCapacity = bus.seatingCapacity;
    bool haveCameraEnabled = bus.haveCameraEnabled;
    String fleetOperatorId = bus.fleetOperatorId;

    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.70,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: StatefulBuilder(
                  builder:
                      (context, setState) => Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Edit Bus',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                  ),
                                  onPressed: () {
                                    // Show confirmation dialog before deletion
                                    showDialog(
                                      context: context,
                                      builder:
                                          (ctx) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text('Delete Bus'),
                                              ],
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this bus?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Text(
                                                  'CANCEL',
                                                  style: TextStyle(
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      theme.colorScheme.error,
                                                  foregroundColor:
                                                      theme.colorScheme.onError,
                                                ),
                                                onPressed: () {
                                                  Provider.of<BusProvider>(
                                                    context,
                                                    listen: false,
                                                  ).deleteBus(bus.id);
                                                  Navigator.of(ctx).pop();
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('DELETE'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Bus Image Preview
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 180,
                                  width: double.infinity,
                                  color:
                                      Colors
                                          .black12, // Optional: background color
                                  child: Image.network(
                                    bus.exteriorImages,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.directions_bus,
                                              size: 60,
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.5),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Image not available',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...[
                              {
                                'label': 'Bus Name',
                                'value': modelName,
                                'icon': Icons.directions_bus,
                              },
                              {
                                'label': 'Company',
                                'value': company,
                                'icon': Icons.business,
                              },
                              {
                                'label': 'Number Plate',
                                'value': numberPlate,
                                'icon': Icons.numbers,
                              },
                              {
                                'label': 'Age',
                                'value': age.toString(),
                                'icon': Icons.calendar_today,
                              },
                              {
                                'label': 'Seating Capacity',
                                'value': seatingCapacity.toString(),
                                'icon': Icons.airline_seat_recline_normal,
                              },
                              {
                                'label': 'Exterior Image URL',
                                'value': exteriorImages,
                                'icon': Icons.image,
                              },
                              {
                                'label': 'Interior Image URL',
                                'value': interiorImages,
                                'icon': Icons.airline_seat_flat,
                              },
                            ].map(
                              (field) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: TextFormField(
                                  initialValue: field['value'] as String,
                                  decoration: InputDecoration(
                                    labelText: field['label'] as String,
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      field['icon'] as IconData,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  keyboardType:
                                      [
                                            'Age',
                                            'Seating Capacity',
                                          ].contains(field['label'])
                                          ? TextInputType.number
                                          : TextInputType.text,
                                  onSaved: (val) {
                                    switch (field['label']) {
                                      case 'Bus Name':
                                        modelName = val ?? '';
                                        break;
                                      case 'Company':
                                        company = val ?? '';
                                        break;
                                      case 'Number Plate':
                                        numberPlate = val ?? '';
                                        break;
                                      case 'Age':
                                        age = int.tryParse(val ?? '') ?? 0;
                                        break;
                                      case 'Seating Capacity':
                                        seatingCapacity =
                                            int.tryParse(val ?? '') ?? 0;
                                        break;
                                      case 'Exterior Image URL':
                                        exteriorImages = val ?? '';
                                        break;
                                      case 'Interior Image URL':
                                        interiorImages = val ?? '';
                                        break;
                                    }
                                  },
                                  validator:
                                      (val) => val!.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.videocam,
                                      size: 20,
                                      color:
                                          haveCameraEnabled
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Camera Enabled',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                value: haveCameraEnabled,
                                onChanged: (val) {
                                  setState(
                                    () => haveCameraEnabled = val ?? false,
                                  );
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.cancel_outlined,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      final updatedBus = Bus(
                                        id: bus.id,
                                        modelName: modelName,
                                        company: company,
                                        numberPlate: numberPlate,
                                        exteriorImages: exteriorImages,
                                        interiorImages: interiorImages,
                                        age: age,
                                        seatingCapacity: seatingCapacity,
                                        haveCameraEnabled: haveCameraEnabled,
                                        fleetOperatorId: fleetOperatorId,
                                      );
                                      Provider.of<BusProvider>(
                                        context,
                                        listen: false,
                                      ).updateBus(updatedBus);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.save, size: 16),
                                      const SizedBox(width: 8),
                                      const Text('Update Bus'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = Provider.of<BusProvider>(context);
    final buses = busProvider.buses;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.directions_bus, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 8),
            const Text('Fleet Manager'),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body:
          busProvider.isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your fleet...',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              )
              : buses.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_bus_filled_outlined,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No buses available',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start building your fleet by adding buses',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddBusForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Bus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.explore,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Available Buses',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_bus,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${buses.length} Buses',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: buses.length,
                        itemBuilder: (context, index) {
                          final bus = buses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => _showEditBusDialog(context, bus),
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                children: [
                                  // Bus Image
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      bus.exteriorImages,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          height: 180,
                                          width: double.infinity,
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.directions_bus,
                                                size: 40,
                                                color: theme.colorScheme.primary
                                                    .withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Image not available',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.directions_bus_filled,
                                                  size: 18,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  bus.modelName,
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.numbers,
                                                    size: 12,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    bus.numberPlate,
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.business,
                                              size: 16,
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              bus.company,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Bus Age
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .surfaceVariant,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 14,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${bus.age} years',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Seating capacity
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .surfaceVariant,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .airline_seat_recline_normal,
                                                    size: 14,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${bus.seatingCapacity} seats',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Camera enabled indicator
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    bus.haveCameraEnabled
                                                        ? theme
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.1)
                                                        : theme
                                                            .colorScheme
                                                            .error
                                                            .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    bus.haveCameraEnabled
                                                        ? Icons.videocam
                                                        : Icons.videocam_off,
                                                    size: 14,
                                                    color:
                                                        bus.haveCameraEnabled
                                                            ? theme
                                                                .colorScheme
                                                                .primary
                                                            : theme
                                                                .colorScheme
                                                                .error,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    bus.haveCameraEnabled
                                                        ? 'Camera'
                                                        : 'No Camera',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              bus.haveCameraEnabled
                                                                  ? theme
                                                                      .colorScheme
                                                                      .primary
                                                                  : theme
                                                                      .colorScheme
                                                                      .error,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.1),
                                  ),
                                  // Edit button section
                                  InkWell(
                                    onTap:
                                        () => _showEditBusDialog(context, bus),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Edit Details',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBusForm(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Add Bus'),
      ),
    );
  }
}
