import '../../../l10n/strings.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design.dart';
import '../domain/catalog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(memberProvider);
    final home = ref.watch(homeProvider);
    ref.listen(onlineProvider, (previous, next) {
      if (previous?.asData?.value == false && next.asData?.value == true) {
        ref.invalidate(homeProvider);
        ref.invalidate(memberProvider);
      }
    });
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(memberProvider);
        ref.invalidate(homeProvider);
        await ref
            .read(homeProvider.future)
            .then<void>((_) {}, onError: (Object _, StackTrace _) {});
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          member.when(
            data: (value) => _MemberHeader(
              value,
              ref.watch(sessionProvider).value?.firstName,
            ),
            loading: () => const _Shimmer(height: 108),
            error: (_, _) => _Unavailable(
              Strings.of(context).memberProfile,
              onRetry: () => ref.invalidate(memberProvider),
            ),
          ),
          const SizedBox(height: 14),
          ...home.when(
            data: (data) => [
              Entry(
                index: 0,
                child: data.banners.isEmpty
                    ? _Unavailable(Strings.of(context).offers)
                    : _Banners(data.banners),
              ),
              for (var i = 0; i < data.sections.length; i++)
                Entry(index: i + 1, child: _Section(data.sections[i], i)),
              Entry(index: 4, child: _Nearby(data.shops)),
            ],
            loading: () => const [
              _Shimmer(height: 170),
              _Shimmer(height: 148),
              _Shimmer(height: 148),
            ],
            error: (_, _) => [
              for (final label in [
                Strings.of(context).offers,
                Strings.of(context).seasonal,
                Strings.of(context).popular,
                Strings.of(context).orderAgain,
                Strings.of(context).shops,
              ])
                _Unavailable(
                  label,
                  onRetry: () => ref.invalidate(homeProvider),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader(this.member, this.firstName);
  final Member member;
  final String? firstName;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Palette.peach,
      borderRadius: BorderRadius.circular(Space.radius),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: 48,
          child: ClipOval(child: FoodImage(member.image)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstName ?? member.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('${member.tier} member'),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: (member.points / member.goal).clamp(0.0, 1.0),
                color: Palette.orange,
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 4),
              Text(
                '${number(member.remaining)} points to Gold',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          label: '${member.notifications} notifications',
          child: Badge(
            label: Text('${member.notifications}'),
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
      ],
    ),
  );
}

class _Banners extends StatefulWidget {
  const _Banners(this.offers);
  final List<BannerOffer> offers;
  @override
  State<_Banners> createState() => _BannersState();
}

class _BannersState extends State<_Banners> {
  final controller = PageController();
  Timer? timer;
  int page = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) return;
    timer = Timer.periodic(Motion.carousel, (_) {
      if (controller.hasClients && widget.offers.length > 1) {
        controller.animateToPage(
          (page + 1) % widget.offers.length,
          duration: Motion.page,
          curve: Motion.curve,
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 158,
        child: PageView.builder(
          controller: controller,
          onPageChanged: (index) => setState(() => page = index),
          itemCount: widget.offers.length,
          itemBuilder: (context, index) {
            final offer = widget.offers[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(Space.radius),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: ColoredBox(
                      color: Palette.lavender,
                      child: SizedBox.expand(
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 4, child: FoodImage(offer.image)),
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 5,
        children: [
          for (var i = 0; i < widget.offers.length; i++)
            AnimatedContainer(
              duration: Motion.use(context, Motion.quick),
              width: page == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: page == i ? Palette.blue : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  const _Section(this.section, this.index);
  final ProductSection section;
  final int index;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (section.products.isEmpty)
          Text(Strings.of(context).noProducts)
        else
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: section.products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (context, i) {
                final product = section.products[i];
                final hero = '${product.id}:$index:$i';
                return SizedBox(
                  width: 128,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push(
                        '/product/${product.id}',
                        extra: (hero: hero, product: product),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 108,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Hero(
                                  tag: hero,
                                  child: FoodImage(product.image),
                                ),
                                if (product.discount case final discount?)
                                  Positioned(
                                    top: 7,
                                    right: 7,
                                    child: Badge(
                                      backgroundColor: Palette.orange,
                                      label: Text('-$discount%'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(9, 7, 9, 0),
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 9),
                            child: Text(
                              mmk(product.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}

class _Nearby extends StatelessWidget {
  const _Nearby(this.shops);
  final List<Shop> shops;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 19),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Palette.blue,
      borderRadius: BorderRadius.circular(Space.radius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'There are ${shops.length} J’Donut shops near you',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: Colors.white),
        ),
        Text(
          Strings.of(context).exploreNow,
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 10),
        if (shops.isEmpty)
          Text(Strings.of(context).noShops)
        else
          SizedBox(
            height: 172,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shops.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final shop = shops[i];
                return SizedBox(
                  width: 175,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ColoredBox(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 77, child: FoodImage(shop.image)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                            child: Text(
                              shop.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              shop.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              Strings.of(context).orderOnline,
                              style: TextStyle(
                                color: Palette.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );
}

class _Unavailable extends StatelessWidget {
  const _Unavailable(this.label, {this.onRetry});
  final String label;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text('$label unavailable'),
    trailing: onRetry == null
        ? null
        : TextButton(
            onPressed: onRetry,
            child: Text(Strings.of(context).retry),
          ),
  );
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: -1, end: 1),
    duration: Motion.use(context, Motion.progress),
    builder: (_, value, _) => Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Space.radius),
        gradient: LinearGradient(
          begin: Alignment(value - 1, 0),
          end: Alignment(value + 1, 0),
          colors: const [Palette.fog, Colors.white, Palette.fog],
        ),
      ),
    ),
  );
}
