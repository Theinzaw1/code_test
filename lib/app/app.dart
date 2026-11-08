import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design.dart';
import '../features/auth/presentation/onboarding.dart';
import '../features/auth/presentation/registration.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/product/domain/product.dart';
import '../features/product/presentation/product_screen.dart';
import '../features/rewards/presentation/rewards_screen.dart';
import '../l10n/strings.dart';
import 'providers.dart';
import 'shell.dart';

final routerProvider = Provider((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    initialLocation: '/loading',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final path = state.uri.path;
      if (session.isLoading || session.hasError) {
        return path == '/loading' ? null : '/loading';
      }
      final public = path == '/onboarding' || path.startsWith('/auth/');
      if (session.value == null) return public ? null : '/onboarding';
      return public || path == '/loading' ? '/home' : null;
    },
    routes: [
      GoRoute(path: '/loading', builder: (_, _) => const _Loading()),
      GoRoute(path: '/onboarding', builder: (_, _) => const Onboarding()),
      GoRoute(
        path: '/auth/:mode',
        pageBuilder: (_, state) => MaterialPage(
          key: ValueKey(state.uri.path),
          child: Registration(
            register: state.pathParameters['mode'] == 'register',
            initialPhone: state.extra as String?,
          ),
        ),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const Onboarding(welcome: true),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) {
          final args = state.extra as ({String hero, Product product})?;
          return ProductScreen(
            id: state.pathParameters['id']!,
            hero: args?.hero,
            initial: args?.product,
          );
        },
      ),
      ShellRoute(
        builder: (_, state, child) =>
            DonutShell(location: state.uri.path, child: child),
        routes: [
          _tab('/home', const HomeScreen()),
          _tab('/rewards', const RewardsScreen()),
          _tab('/settings', const SettingsScreen()),
          _tab(
            '/menu',
            Builder(
              builder: (context) =>
                  Center(child: Text(Strings.of(context).menuPreview)),
            ),
          ),
          _tab(
            '/orders',
            Builder(
              builder: (context) =>
                  Center(child: Text(Strings.of(context).ordersPreview)),
            ),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

GoRoute _tab(String path, Widget child) => GoRoute(
  path: path,
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: Motion.use(context, Motion.quick),
    reverseTransitionDuration: Motion.use(context, Motion.quick),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  ),
);

class DonutApp extends ConsumerWidget {
  const DonutApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'J’Donuts',
    theme: donutTheme,
    routerConfig: ref.watch(routerProvider),
    localizationsDelegates: Strings.localizationsDelegates,
    supportedLocales: Strings.supportedLocales,
    debugShowCheckedModeBanner: false,
  );
}

class _Loading extends ConsumerWidget {
  const _Loading();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: ref.watch(sessionProvider).hasError
          ? DonutButton(
              Strings.of(context).restoreError,
              onPressed: () => ref.invalidate(sessionProvider),
            )
          : const CircularProgressIndicator(),
    ),
  );
}
