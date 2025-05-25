import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final double iconSize;
  
  const ThemeToggleWidget({
    Key? key, 
    this.showLabel = false,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            size: iconSize,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          }, 
          tooltip: 'Toggle Theme',
        ),
      ],
    );
  }
}

class ThemeSettingsBottomSheet extends StatelessWidget {
  const ThemeSettingsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          _buildThemeOption(
            context,
            title: 'Light',
            icon: Icons.light_mode,
            isSelected: themeProvider.themeMode == ThemeMode.light,
            onTap: () {
              themeProvider.setLightTheme();
              Navigator.pop(context);
            },
          ),
          _buildThemeOption(
            context,
            title: 'Dark',
            icon: Icons.dark_mode,
            isSelected: themeProvider.themeMode == ThemeMode.dark,
            onTap: () {
              themeProvider.setDarkTheme();
              Navigator.pop(context);
            },
          ),
          _buildThemeOption(
            context,
            title: 'System Default',
            icon: Icons.settings_suggest,
            isSelected: themeProvider.themeMode == ThemeMode.system,
            onTap: () {
              themeProvider.setSystemTheme();
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// Usage example:
// void showThemeOptions(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) => ThemeSettingsBottomSheet(),
//   );
// }