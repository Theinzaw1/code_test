import '../../../l10n/strings.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design.dart';
import '../domain/validation.dart';

class VerificationInput extends StatelessWidget {
  const VerificationInput({
    super.key,
    required this.controller,
    required this.enabled,
    required this.shake,
    required this.onChanged,
  });
  final TextEditingController controller;
  final bool enabled;
  final int shake;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    key: ValueKey(shake),
    tween: Tween(begin: shake == 0 ? 1 : 0, end: 1),
    duration: Motion.use(context, Motion.page),
    builder: (_, value, child) => Transform.translate(
      offset: Offset(math.sin(value * math.pi * 6) * (1 - value) * 13, 0),
      child: child,
    ),
    child: SizedBox(
      height: 56,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < otpLength; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: Motion.use(context, Motion.quick),
                      margin: EdgeInsets.only(
                        right: i == otpLength - 1 ? 0 : 6,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: enabled ? Colors.white : Palette.fog,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: i == controller.text.length && enabled
                              ? Palette.blue
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        i < controller.text.length ? controller.text[i] : '',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Opacity(
            opacity: 0,
            alwaysIncludeSemantics: true,
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              onChanged: onChanged,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(otpLength),
              ],
              decoration: InputDecoration(
                labelText: Strings.of(context).otpField,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
