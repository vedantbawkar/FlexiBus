import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flexiops/models/driver.dart';
import 'package:flexiops/providers/operator_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FleetDriversScreen extends StatefulWidget {
  final String fleetOperatorId;
  FleetDriversScreen({required this.fleetOperatorId});

  @override
  _FleetDriversScreenState createState() => _FleetDriversScreenState();
}

class _FleetDriversScreenState extends State<FleetDriversScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<DriverProvider>(
      context,
      listen: false,
    ).loadDrivers(widget.fleetOperatorId);
  }

  void _showDriverForm({DriverModel? driver}) {
    final nameController = TextEditingController(text: driver?.name ?? '');
    final phoneController = TextEditingController(text: driver?.phone ?? '');
    final licenseController = TextEditingController(
      text: driver?.license ?? '',
    );
    final statusController = TextEditingController(
      text: driver?.status ?? 'active',
    );
    final busController = TextEditingController(
      text: driver?.busAssigned ?? '',
    );

    // Use StatefulBuilder to handle state changes within the dialog
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => StatefulBuilder(
            builder: (dialogContext, setState) {
              return AlertDialog(
                title: Text(driver == null ? 'Add Driver' : 'Edit Driver'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFormField(nameController, 'Name', Icons.person),
                      SizedBox(height: 16),
                      _buildFormField(phoneController, 'Contact', Icons.phone),
                      SizedBox(height: 16),
                      _buildFormField(
                        licenseController,
                        'License',
                        Icons.credit_card,
                      ),
                      SizedBox(height: 16),
                      _buildFormField(
                        busController,
                        'Assigned Bus ID',
                        Icons.directions_bus,
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              dialogContext,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<String>(
                          value: statusController.text,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(Icons.toggle_on),
                            border: InputBorder.none,
                          ),
                          items:
                              ['active', 'inactive'].map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status.capitalize()),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                statusController.text = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final newDriver = DriverModel(
                        id:
                            driver?.id ??
                            FirebaseFirestore.instance
                                .collection('opusers')
                                .doc()
                                .id,
                        name: nameController.text,
                        phone: phoneController.text,
                        license: licenseController.text,
                        busAssigned:
                            busController.text.isEmpty
                                ? null
                                : busController.text,
                        status: statusController.text,
                        fleetOperatorId: widget.fleetOperatorId,
                      );
                      if (driver == null) {
                        Provider.of<DriverProvider>(
                          context,
                          listen: false,
                        ).addDriver(newDriver);
                      } else {
                        Provider.of<DriverProvider>(
                          context,
                          listen: false,
                        ).updateDriver(newDriver);
                      }
                      Navigator.pop(dialogContext);
                    },
                    child: Text('Save'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildFormField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // This method is now removed as we're handling the dropdown directly in the dialog

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.person_2_rounded, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 8),
            const Text('Driver Manager'),
          ],
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
            onPressed: () => provider.loadDrivers(widget.fleetOperatorId),
          ),
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
            onPressed: () {
              // Implement search functionality if needed
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body:
          provider.drivers.isEmpty
              ? _buildEmptyState()
              : _buildDriversList(provider, theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDriverForm(),
        label: Text('Add Driver'),
        icon: Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
          ),
          SizedBox(height: 16),
          Text(
            'No drivers added yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Add your first driver to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showDriverForm(),
            icon: Icon(Icons.add),
            label: Text('Add Driver'),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList(DriverProvider provider, ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.drivers.length,
      itemBuilder: (context, index) {
        final driver = provider.drivers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DriverCard(
            driver: driver,
            onEdit: () => _showDriverForm(driver: driver),
            onDelete: () => _confirmDelete(driver),
            theme: theme,
          ),
        );
      },
    );
  }

  void _confirmDelete(DriverModel driver) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Driver'),
            content: Text('Are you sure you want to delete ${driver.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Provider.of<DriverProvider>(
                    context,
                    listen: false,
                  ).deleteDriver(driver.id);
                  Navigator.pop(context);
                },
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ThemeData theme;

  const DriverCard({
    required this.driver,
    required this.onEdit,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = driver.status.toLowerCase() == 'active';
    final statusColor = isActive ? Colors.green : theme.colorScheme.error;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    driver.name[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 4,
                                  backgroundColor: statusColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  driver.status.capitalize(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
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
                _buildPopupMenu(context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, 'Contact', driver.phone),
                Divider(height: 24),
                _buildInfoRow(Icons.credit_card, 'License', driver.license),
                Divider(height: 24),
                _buildInfoRow(
                  Icons.directions_bus,
                  'Bus Assigned',
                  driver.busAssigned ?? 'None',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit),
                  label: Text('Edit'),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline),
                  label: Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: theme.colorScheme.error),
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
