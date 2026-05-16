import 'package:flutter/material.dart';

class PollResultsPage extends StatelessWidget {
  const PollResultsPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Résultats')),
      body: Center(child: Text('Résultats : $eventId')),
    );
  }
}
