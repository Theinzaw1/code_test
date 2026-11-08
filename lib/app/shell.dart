import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design.dart';
import '../core/result.dart';
import '../l10n/strings.dart';
import 'providers.dart';

class DonutShell extends ConsumerWidget {
  const DonutShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = Strings.of(context);
    final tabs = [
      ('/home', s.home, Icons.home_outlined),
      ('/rewards', s.rewards, Icons.workspace_premium_outlined),
      ('/menu', Strings.of(context).menu, Icons.donut_small),
      ('/orders', Strings.of(context).orders, Icons.receipt_long_outlined),
      ('/settings', s.settings, Icons.settings_outlined),
    ];
    final active = tabs.indexWhere((tab) => tab.$1 == location);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (ref.watch(onlineProvider).value == false)
              Container(
                width: double.infinity,
                color: Palette.peach,
                padding: const EdgeInsets.all(5),
                child: Text(
                  s.offline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Palette.blue,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            height: 61,
            child: LayoutBuilder(
              builder: (context, box) {
                final width = box.maxWidth / tabs.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      left: width * active + 4,
                      top: 8,
                      bottom: 8,
                      width: width - 8,
                      duration: Motion.use(context, Motion.page),
                      curve: Motion.curve,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Palette.pink,
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < tabs.length; i++)
                          Expanded(
                            child: Semantics(
                              selected: i == active,
                              label: tabs[i].$2,
                              button: true,
                              child: Tooltip(
                                message: tabs[i].$2,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () => context.go(tabs[i].$1),
                                  child: SizedBox.expand(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          tabs[i].$3,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        if (i == active)
                                          Text(
                                            tabs[i].$2,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context);
    return ListView(
      padding: const EdgeInsets.all(Space.gutter),
      children: [
        Text(s.settings, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 15),
        DonutButton(
          s.logout,
          busy: busy,
          onPressed: () async {
            setState(() => busy = true);
            final result = await ref.read(authProvider).logout();
            if (!context.mounted) return;
            setState(() => busy = false);
            switch (result) {
              case Ok():
                ref.read(sessionProvider.notifier).clear();
                context.go('/onboarding');
              case Failure(:final message):
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));
            }
          },
        ),
      ],
    );
  }
}
