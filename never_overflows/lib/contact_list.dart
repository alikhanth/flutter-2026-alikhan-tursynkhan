import 'package:flutter/material.dart';

import 'contacts.dart';
import 'contact_card.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '20 contacts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) =>
                ContactCard(contact: contacts[index]),
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ],
    );
  }
}
