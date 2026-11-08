import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design.dart';
import '../../../l10n/strings.dart';

void comingSoon(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('$label is a preview.')));
}

class Legal extends StatelessWidget {
  const Legal({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(Strings.of(context).legalIntro, style: TextStyle(fontSize: 11)),
      Wrap(
        alignment: WrapAlignment.center,
        children: [
          TextButton(
            onPressed: () => comingSoon(context, Strings.of(context).terms),
            child: Text(Strings.of(context).terms),
          ),
          TextButton(
            onPressed: () => comingSoon(context, Strings.of(context).privacy),
            child: Text(Strings.of(context).privacy),
          ),
        ],
      ),
    ],
  );
}

class Onboarding extends StatelessWidget {
  const Onboarding({super.key, this.welcome = false});
  final bool welcome;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context);
    final title = welcome ? s.welcome : s.onboarding;
    return Scaffold(
      backgroundColor: Palette.blush,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: Column(
                  children: [
                    _Artwork(
                      welcome: welcome,
                      height: viewport.maxHeight * .48,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Entry(
                            index: 1,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Entry(
                            index: 2,
                            child: DonutButton(
                              welcome ? s.explore : s.start,
                              onPressed: () => context.go(
                                welcome ? '/home' : '/auth/register',
                              ),
                            ),
                          ),
                          if (!welcome) ...[
                            Entry(
                              index: 3,
                              child: TextButton(
                                onPressed: () => context.go('/auth/login'),
                                child: Text(
                                  'Already have an account? ${s.login}',
                                ),
                              ),
                            ),
                            const Entry(index: 4, child: _Social()),
                            const Legal(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Social extends StatelessWidget {
  const _Social();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (final (label, icon) in [
        (Strings.of(context).google, Icons.g_mobiledata),
        (Strings.of(context).apple, Icons.apple),
        (Strings.of(context).facebook, Icons.facebook),
      ])
        IconButton(
          tooltip: label,
          onPressed: () => comingSoon(context, label),
          icon: Icon(
            icon,
            color: label == Strings.of(context).facebook
                ? Palette.lavender
                : Palette.ink,
          ),
        ),
    ],
  );
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.welcome, required this.height});
  final bool welcome;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: LayoutBuilder(
      builder: (context, bounds) {
        final w = bounds.maxWidth;
        final artwork = welcome
            ? ['violet', 'coconut', 'strawberry', 'orange']
            : ['violet', 'coconut', 'strawberry', 'orange', 'candy'];
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            for (var i = 0; i < artwork.length; i++)
              Positioned(
                left: welcome
                    ? 10 + i % 2 * w / 2
                    : [-w * .18, w * .79, w * .22, w * .24, -w * .2][i],
                top: welcome
                    ? i ~/ 2 * height / 2
                    : [
                        -15.0,
                        -32.0,
                        height * .16,
                        height * .78,
                        height * .53,
                      ][i],
                width: welcome ? w / 2 - 20 : w * (i == 2 ? .56 : .42),
                height: welcome ? height / 2 - 10 : w * (i == 2 ? .56 : .42),
                child: Entry(
                  index: i,
                  offset: i.isEven ? -46 : 46,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(welcome ? 24 : w),
                    child: FoodImage(artwork[i]),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
