import 'package:flutter/material.dart';

/// 404 Not Found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '404',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/dashboard', (route) => false),
              icon: const Icon(Icons.home),
              label: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
