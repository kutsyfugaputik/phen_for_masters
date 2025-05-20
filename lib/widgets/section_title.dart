
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masters/theme/settings.dart';

class CustomTitle extends StatelessWidget {
  final String title;

  const CustomTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<SettingApp>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24 * settings.fontSizeMultiplier,
            fontWeight: FontWeight.bold,
            fontFamily: settings.selectedFontFamily,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
