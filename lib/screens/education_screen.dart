import 'package:flutter/material.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Education'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Emergency Preparedness Tips',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTipCard(
            'Stay Calm',
            'In an emergency, staying calm helps you think clearly and make better decisions.',
          ),
          _buildTipCard(
            'Know Your Exits',
            'Familiarize yourself with emergency exits in your home, workplace, and public spaces.',
          ),
          _buildTipCard(
            'Emergency Contacts',
            'Keep important phone numbers saved and easily accessible.',
          ),
          _buildTipCard(
            'First Aid Basics',
            'Learn basic first aid techniques to help yourself and others in critical situations.',
          ),
          _buildTipCard(
            'Emergency Kit',
            'Prepare an emergency kit with essentials like water, food, medications, and flashlights.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
