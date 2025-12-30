import 'package:flutter/material.dart';

/// Coming Soon screen for unimplemented features
class ComingSoonScreen extends StatelessWidget {
  final String? moduleName;

  const ComingSoonScreen({super.key, this.moduleName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(moduleName ?? 'Coming Soon')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 100,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              moduleName != null
                  ? 'The $moduleName module is under development'
                  : 'This feature is under development',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
