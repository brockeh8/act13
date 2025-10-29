import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String userName;
  final IconData avatarIcon;
  final Color avatarColor;
  final List<String> badges;
  const SuccessScreen({super.key, required this.userName, required this.avatarIcon, required this.avatarColor, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: avatarColor.withOpacity(0.15),
                child: Icon(avatarIcon, color: avatarColor, size: 44),
              ),
              const SizedBox(height: 16),
              Text('Welcome, $userName!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 8),
              const Text('Your adventure begins now!', style: TextStyle(color: Colors.grey)),
              if (badges.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Achievements', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: badges.map((b) => Chip(label: Text(b), avatar: const Icon(Icons.emoji_events))).toList(),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
