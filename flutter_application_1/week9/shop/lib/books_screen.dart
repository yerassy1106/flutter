import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Books'), actions: const [CartBadge()]),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final inCart = context.watch<Cart>().items.contains(book);

          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: inCart
                ? const Text('Added')
                : OutlinedButton(
                    onPressed: () {
                      final ok = context.read<Cart>().add(book);
                      if (ok) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Added')));
                      }
                    },
                    child: const Text('Add'),
                  ),
          );
        },
      ),
    );
  }
}
