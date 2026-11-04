import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Cart'),
                  content: const Text(
                    'Are you sure you want to clear the cart?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                context.read<Cart>().clear();
              }
            },
          ),
        ],
      ),
      body: Consumer<Cart>(
        builder: (context, cart, child) {
          final items = cart.items;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final book = items[index];
                    final qty = cart.qtyOf(book);

                    return ListTile(
                      title: Text(book.title),
                      subtitle: Text('${book.price * qty} ₸'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('×$qty'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => cart.increment(book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => cart.remove(book),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              child!, // Используем переданный константный виджет
            ],
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade50,
          child: Consumer<Cart>(
            builder: (context, cart, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${cart.total} ₸',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
