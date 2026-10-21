import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pop(BookAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final year = book.year;

    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.book),
            title: Text(book.title),
            subtitle: const Text('Title'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(book.author),
            subtitle: const Text('Author'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text('${book.pages} pp.'),
            subtitle: const Text('Pages'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(year == null ? 'Year unknown' : '$year'),
            subtitle: const Text('Year'),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(book.read ? 'Read' : 'Unread'),
            subtitle: const Text('Status'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _confirmDelete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
