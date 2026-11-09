import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design.dart';
import '../../../core/result.dart';
import '../../../l10n/strings.dart';
import '../domain/validation.dart';
import 'onboarding.dart';
import 'verification_input.dart';

class Registration extends ConsumerStatefulWidget {
  const Registration({super.key, required this.register, this.initialPhone});
  final bool register;
  final String? initialPhone;

  @override
  ConsumerState<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends ConsumerState<Registration> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  final first = TextEditingController();
  final last = TextEditingController();
  final month = TextEditingController();
  final day = TextEditingController();
  final year = TextEditingController();
  final phoneFocus = FocusNode();
  final nameFocus = FocusNode();
  final lastFocus = FocusNode();
  late OtpChallenge challenge;
  Timer? timer;
  String? challengePhone;
  int step = 0;
  int shake = 0;
  bool busy = false;
  bool unknown = false;
  bool phoneBlurred = false;
  bool nameBlurred = false;
  bool lastBlurred = false;
  String? error;

  DateTime? get birth =>
      birthDate(month.text, day.text, year.text, DateTime.now());
  String? get normalized => normalizePhone(phone.text);
  int get remaining => math.max(
    0,
    (challenge.resendAt.difference(DateTime.now()).inMilliseconds / 1000)
        .ceil(),
  );
  bool get ready => switch (step) {
    0 => normalized != null,
    1 => otp.text.length == otpLength && !challenge.locked,
    2 =>
      nameError(first.text, required: true) == null &&
          nameError(last.text, required: false) == null,
    _ => birth != null,
  };

  @override
  void initState() {
    super.initState();
    phone.text = widget.initialPhone ?? '';
    challenge = OtpChallenge(DateTime.now());
    phoneFocus.addListener(() {
      if (!phoneFocus.hasFocus && mounted) setState(() => phoneBlurred = true);
    });
    nameFocus.addListener(() {
      if (!nameFocus.hasFocus && mounted) setState(() => nameBlurred = true);
    });
    lastFocus.addListener(() {
      if (!lastFocus.hasFocus && mounted) setState(() => lastBlurred = true);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final controller in [phone, otp, first, last, month, day, year]) {
      controller.dispose();
    }
    phoneFocus.dispose();
    nameFocus.dispose();
    lastFocus.dispose();
    super.dispose();
  }

  void back() {
    if (busy) return;
    if (step == 0) {
      context.go('/onboarding');
    } else {
      FocusScope.of(context).unfocus();
      setState(() {
        step--;
        error = null;
      });
    }
  }

  void startTimer() {
    challengePhone = normalized;
    challenge = OtpChallenge(DateTime.now());
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
      if (remaining == 0) timer.cancel();
    });
  }

  Future<void> submit() async {
    if (!ready || busy) return;
    setState(() {
      busy = true;
      error = null;
      unknown = false;
    });
    FocusScope.of(context).unfocus();
    final repo = ref.read(authProvider);
    try {
      switch (step) {
        case 0:
          switch (await repo.requestCode(
            normalized!,
            register: widget.register,
          )) {
            case Ok(value: true) when mounted:
              if (challengePhone != normalized) {
                otp.clear();
                startTimer();
              }
              setState(() => step++);
            case Ok(value: false) when mounted:
              setState(() => unknown = true);
            case Failure(:final message) when mounted:
              setState(() => error = message);
            default:
              break;
          }
        case 1:
          final code = otp.text;
          if (!challenge.verify(code)) {
            await Future<void>.delayed(const Duration(seconds: 1));
            if (!mounted) return;
            otp.clear();
            setState(() {
              shake++;
              error = challenge.locked
                  ? Strings.of(context).locked
                  : Strings.of(context).wrongCode;
            });
            return;
          }
          switch (await repo.verify(
            normalized!,
            code,
            register: widget.register,
          )) {
            case Ok(:final value) when mounted:
              if (value == null) {
                if (widget.register) {
                  setState(() => step++);
                } else {
                  setState(() {
                    step = 0;
                    unknown = true;
                  });
                }
              } else {
                ref.read(sessionProvider.notifier).signIn(value);
                context.go('/home');
              }
            case Failure(:final message) when mounted:
              setState(() => error = message);
            default:
              break;
          }
        case 2:
          setState(() => step++);
        case _:
          final result = await repo.register((
            phone: normalized!,
            firstName: first.text.trim(),
            lastName: last.text.trim(),
            birth: birth!,
          ));
          if (!mounted) return;
          switch (result) {
            case Ok(:final value):
              ref.read(sessionProvider.notifier).signIn(value);
              context.go('/welcome');
            case Failure(:final message):
              setState(() => error = message);
          }
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resend() async {
    if (remaining > 0 || busy) return;
    setState(() => busy = true);
    final result = await ref
        .read(authProvider)
        .requestCode(normalized!, register: widget.register);
    if (!mounted) return;
    setState(() {
      busy = false;
      switch (result) {
        case Ok(value: true):
          otp.clear();
          error = null;
          startTimer();
        case Ok(value: false):
          step = 0;
          unknown = true;
        case Failure(:final message):
          error = message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: Scaffold(
        backgroundColor: Palette.blush,
        appBar: AppBar(
          backgroundColor: Palette.blush,
          leading: IconButton(
            onPressed: back,
            icon: const Icon(Icons.arrow_back),
            tooltip: Strings.of(context).back,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: Space.gutter),
              child: _StepRing(step: step),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      AnimatedSwitcher(
                        duration: Motion.use(context, Motion.page),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(.13, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Column(
                          key: ValueKey(step),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              [s.phone, s.verify, s.name, s.birthday][step],
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 22),
                            ...fields(),
                          ],
                        ),
                      ),
                      if (error case final message?)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const Spacer(),
                      const SizedBox(height: 22),
                      DonutButton(
                        s.continueLabel,
                        onPressed: ready ? submit : null,
                        busy: busy,
                      ),
                      const SizedBox(height: 12),
                      const Legal(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> fields() => switch (step) {
    0 => [
      field(
        phone,
        Strings.of(context).phoneField,
        focus: phoneFocus,
        keyboard: TextInputType.phone,
        prefix: '+95   ',
        errorText: phoneBlurred && normalized == null
            ? Strings.of(context).phoneError
            : null,
      ),
      if (unknown) ...[
        Text(Strings.of(context).unknownNumber),
        TextButton(
          onPressed: () => context.go('/auth/register', extra: phone.text),
          child: Text(Strings.of(context).registerNumber),
        ),
      ],
    ],
    1 => [
      Text(Strings.of(context).otpSent(normalized!)),
      const SizedBox(height: 14),
      VerificationInput(
        controller: otp,
        enabled: !challenge.locked && !busy,
        shake: shake,
        onChanged: (_) => setState(() {}),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: remaining == 0 && !busy ? resend : null,
          child: Text(
            remaining == 0
                ? Strings.of(context).resend
                : 'Resend in ${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}',
          ),
        ),
      ),
    ],
    2 => [
      field(
        first,
        Strings.of(context).firstName,
        focus: nameFocus,
        errorText: nameBlurred || first.text.isNotEmpty
            ? nameError(first.text, required: true)
            : null,
      ),
      field(
        last,
        Strings.of(context).lastName,
        focus: lastFocus,
        errorText: lastBlurred || last.text.isNotEmpty
            ? nameError(last.text, required: false)
            : null,
      ),
    ],
    _ => birthFields(),
  };

  List<Widget> birthFields() {
    final strings = Strings.of(context);
    final now = DateTime.now();
    final yearValue = int.tryParse(year.text);
    final completeYear = year.text.length == birthYearDigits;
    final invalidYear =
        completeYear &&
        (yearValue == null || yearValue < 1 || yearValue > now.year);
    final date = calendarDate(month.text, day.text, year.text);
    final invalidDay =
        completeYear &&
        !invalidYear &&
        (int.tryParse(month.text) ?? 0) > 0 &&
        day.text.isNotEmpty &&
        date == null;

    return [
      field(
        month,
        strings.month,
        digits: 2,
        maxValue: monthsPerYear,
        errorText: month.text == '0' ? strings.monthRange : null,
      ),
      field(
        day,
        strings.day,
        digits: 2,
        maxValue: maxDayOfMonth,
        errorText: day.text == '0'
            ? strings.dayRange
            : invalidDay
            ? strings.dayForMonth
            : null,
      ),
      field(
        year,
        strings.year,
        digits: birthYearDigits,
        errorText: invalidYear ? strings.yearRange(now.year) : null,
      ),
      if (!invalidYear && date != null && birth == null)
        Text(
          strings.birthError(minimumAge),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
    ];
  }

  Widget field(
    TextEditingController controller,
    String label, {
    FocusNode? focus,
    String? errorText,
    String? prefix,
    TextInputType? keyboard,
    int? digits,
    int? maxValue,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      focusNode: focus,
      enabled: !busy,
      keyboardType: digits != null ? TextInputType.number : keyboard,
      inputFormatters: digits == null
          ? null
          : [
              FilteringTextInputFormatter.digitsOnly,
              TextInputFormatter.withFunction((previous, next) {
                if (next.text.length > digits) return previous;
                if (maxValue == null || next.text.isEmpty || next.text == '0') {
                  return next;
                }
                final value = int.tryParse(next.text);
                return value != null && value >= 1 && value <= maxValue
                    ? next
                    : previous;
              }),
            ],
      onChanged: (_) => setState(() {
        error = null;
        unknown = false;
      }),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: prefix == null
            ? null
            : Padding(padding: const EdgeInsets.all(15), child: Text(prefix)),
      ),
    ),
  );
}

class _StepRing extends StatelessWidget {
  const _StepRing({required this.step});
  final int step;
  @override
  Widget build(BuildContext context) => Semantics(
    label: Strings.of(context).stepCount(step + 1),
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: (step + 1) / 4),
      duration: Motion.use(context, Motion.entrance),
      curve: Motion.curve,
      builder: (_, progress, _) => CustomPaint(
        painter: RingPainter(progress, width: 4),
        child: SizedBox.square(
          dimension: 32,
          child: AnimatedSwitcher(
            duration: Motion.use(context, Motion.quick),
            child: progress == 1
                ? const Icon(Icons.check, size: 18, color: Palette.pink)
                : Center(
                    child: Text(
                      '${step + 1}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
          ),
        ),
      ),
    ),
  );
}
