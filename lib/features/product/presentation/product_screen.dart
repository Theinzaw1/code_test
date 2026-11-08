import '../../../l10n/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design.dart';
import '../domain/product.dart';

class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.id, this.hero, this.initial});
  final String id;
  final String? hero;
  final Product? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(backgroundColor: Palette.fog),
    body: ref
        .watch(productProvider(id))
        .when(
          data: (p) => p == null
              ? Center(child: Text(Strings.of(context).unavailableProduct))
              : _ProductBody(p, hero),
          loading: () => initial != null
              ? _ProductBody(initial!, hero)
              : const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(productProvider(id)),
              child: Text(Strings.of(context).productError),
            ),
          ),
        ),
  );
}

class _ProductBody extends StatefulWidget {
  const _ProductBody(this.product, this.hero);
  final Product product;
  final String? hero;
  @override
  State<_ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends State<_ProductBody> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final text = Theme.of(context).textTheme;
    final image = FoodImage(p.image, fit: BoxFit.contain);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Space.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.code, style: text.labelMedium),
                  if (p.isNew)
                    Badge(
                      label: Text(Strings.of(context).newBadge),
                      backgroundColor: Palette.orange,
                    ),
                ],
              ),
              Text(p.name, style: text.headlineMedium),
              Text(mmk(p.price), style: text.titleMedium),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 1.35,
                child: widget.hero == null
                    ? image
                    : Hero(tag: widget.hero!, child: image),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              tooltip: Strings.of(context).decreaseQuantity,
              onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 55,
              child: AnimatedSwitcher(
                duration: Motion.use(context, Motion.quick),
                child: Text(
                  '$quantity',
                  key: ValueKey(quantity),
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
              ),
            ),
            IconButton.filled(
              tooltip: Strings.of(context).increaseQuantity,
              onPressed: () => setState(() => quantity++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(Strings.of(context).description, style: text.titleMedium),
        const SizedBox(height: 6),
        Text(p.description),
        const SizedBox(height: 22),
        DonutButton(
          Strings.of(context).addToCart(mmk(productTotal(p.price, quantity))),
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(Strings.of(context).added(quantity, p.name)),
                ),
              );
          },
        ),
      ],
    );
  }
}
