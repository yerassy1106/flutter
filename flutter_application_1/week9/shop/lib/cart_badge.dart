import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // Level 4: Выбираем только количество книг (count), чтобы бейдж не перерисовывался при изменении total/quantity
    final count = context.select<Cart, int>((c) => c.count);

    return IconButton(
      icon: Badge(
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart),
      ),
      onPressed: () => Navigator.of(context).pushNamed('/cart'),
    );
  }
}
