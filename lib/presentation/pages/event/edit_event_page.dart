import 'package:flutter/material.dart';

class EditEventPage extends StatelessWidget {
  const EditEventPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier')),
      body: Center(child: Text('Édition : $eventId')),
    );
  }
}
