import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = books.where((book) {
      final query = _query.trim().toLowerCase();
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Search books',
            border: InputBorder.none,
          ),
        ),
        actions: const [CartBadge()],
      ),
      body: filteredBooks.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView.builder(
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added')),
                              );
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
