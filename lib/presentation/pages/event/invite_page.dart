import 'package:flutter/material.dart';

class InvitePage extends StatelessWidget {
  const InvitePage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inviter')),
      body: Center(child: Text('Invitation : $eventId')),
    );
  }
}
