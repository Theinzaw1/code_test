import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design.dart';
import '../../../l10n/strings.dart';
import '../../home/domain/catalog.dart';
import '../domain/challenge.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  bool gift = false;
  @override
  Widget build(BuildContext context) {
    final member = ref.watch(memberProvider);
    final challenges = ref.watch(challengesProvider);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Strings.of(context).rewardTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (member.value case final value?)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: .6, end: 1),
                        duration: Motion.use(context, Motion.entrance),
                        curve: Motion.pop,
                        builder: (_, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: DonutButton(
                          'Rewards  ${value.badge}',
                          color: Palette.orange,
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    Strings.of(context).rewardPreview,
                                  ),
                                ),
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 23),
                member.when(
                  data: (value) => _Progress(value),
                  loading: () => const SizedBox(
                    height: 170,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => TextButton(
                    onPressed: () => ref.invalidate(memberProvider),
                    child: Text(Strings.of(context).pointsError),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: _RewardTabs(
            gift: gift,
            onChanged: (value) => setState(() => gift = value),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: challenges.when(
            data: (items) {
              final shown = items.where((item) => item.gift == gift).toList();
              return AnimatedSwitcher(
                duration: Motion.use(context, Motion.page),
                child: Column(
                  key: ValueKey(gift),
                  children: [
                    if (shown.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(Strings.of(context).noChallenges),
                      ),
                    for (var i = 0; i < shown.length; i++)
                      Entry(index: i, child: _ChallengeCard(shown[i])),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => TextButton(
              onPressed: () => ref.invalidate(challengesProvider),
              child: Text(Strings.of(context).challengeError),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class _RewardTabs extends StatelessWidget {
  const _RewardTabs({required this.gift, required this.onChanged});
  final bool gift;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 310),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            AnimatedPositioned(
              top: 0,
              bottom: 0,
              left: gift ? box.maxWidth * .65 : 0,
              width: box.maxWidth * (gift ? .35 : .65),
              duration: Motion.use(context, Motion.page),
              curve: Motion.curve,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Palette.blue,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            Row(
              children: [
                for (final (option, flex, label) in [
                  (false, 65, Strings.of(context).eatMore),
                  (true, 35, Strings.of(context).gift),
                ])
                  Expanded(
                    flex: flex,
                    child: Semantics(
                      selected: option == gift,
                      child: TextButton(
                        onPressed: () => onChanged(option),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: option == gift ? Colors.white : Palette.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress(this.member);
  final Member member;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(flex: 5, child: _Tiers(member)),
      Expanded(
        flex: 6,
        child: AspectRatio(
          aspectRatio: 1,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Motion.use(context, Motion.progress),
            curve: Motion.curve,
            builder: (context, progress, _) => CustomPaint(
              painter: RingPainter(
                progress * member.points / member.goal,
                width: 28,
                sprinkles: true,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Strings.of(context).totalPoints,
                          style: TextStyle(color: Palette.pink, fontSize: 13),
                        ),
                        Text(
                          number((member.points * progress).round()),
                          style: const TextStyle(
                            color: Palette.pink,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _Tiers extends StatelessWidget {
  const _Tiers(this.member);
  final Member member;
  static const tiers = ['Silver', 'Gold', 'Platinum'];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < tiers.length; i++) ...[
        Entry(
          index: i,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: [Palette.fog, Palette.gold, Palette.blue][i],
                child: Icon(
                  i == 0 ? Icons.shield : Icons.workspace_premium,
                  size: 14,
                  color: Palette.ink,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tiers[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: tiers[i] == member.tier
                            ? Palette.pink
                            : Palette.ink,
                      ),
                    ),
                    Text(
                      tiers[i] == member.tier
                          ? Strings.of(context).currentTier
                          : i == 1
                          ? '${number(member.remaining)} pts remaining'
                          : Strings.of(context).futureTier,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (i < tiers.length - 1)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: SizedBox(
                width: 2,
                height: 19,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: i == 0
                        ? (member.points / member.goal).clamp(0.0, 1.0)
                        : 0,
                  ),
                  duration: Motion.use(context, Motion.progress),
                  builder: (_, value, _) => ColoredBox(
                    color: Palette.fog,
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 1,
                      child: FractionallySizedBox(
                        heightFactor: value,
                        widthFactor: 1,
                        child: const ColoredBox(color: Palette.pink),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ],
  );
}

// The last row preserves alpha so the artwork filter cannot color its backdrop.
const _grayscale = ColorFilter.matrix(<double>[
  .2126,
  .7152,
  .0722,
  0,
  0,
  .2126,
  .7152,
  .0722,
  0,
  0,
  .2126,
  .7152,
  .0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard(this.challenge);
  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final complete = challenge.current >= challenge.goal;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Space.radius),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 105,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: challenge.current / challenge.goal),
              duration: Motion.use(context, Motion.progress),
              curve: Motion.curve,
              child: FoodImage(challenge.image),
              builder: (context, progress, image) => challenge.coffee
                  ? CustomPaint(
                      painter: RingPainter(
                        progress,
                        color: Palette.orange,
                        width: 7,
                        start: math.pi,
                        sweep: math.pi,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipOval(child: image),
                      ),
                    )
                  : ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColorFiltered(colorFilter: _grayscale, child: image),
                          ClipPath(
                            clipper: _QuarterClip(progress),
                            child: image,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('${challenge.current}/${challenge.goal}'),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Entry(
                      index: complete ? 2 : 0,
                      child: DonutButton(
                        Strings.of(context).earn,
                        onPressed: complete
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      Strings.of(context).challengeComplete,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                    Text('${challenge.points} pts'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuarterClip extends CustomClipper<Path> {
  const _QuarterClip(this.progress);
  final double progress;
  @override
  Path getClip(Size size) {
    final bounds = Offset.zero & size;
    if (progress >= 1) return Path()..addOval(bounds);
    return Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..arcTo(bounds, -math.pi / 2, math.pi * 2 * progress, false)
      ..close();
  }

  @override
  bool shouldReclip(_QuarterClip oldClipper) => oldClipper.progress != progress;
}
