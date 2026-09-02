import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../otp_flow_state.dart';

/// Six-cell OTP input (§6.2): one hidden TextField holds focus and owns
/// the real text — cells are pure projections of it. That makes paste,
/// backspace and auto-advance all fall out of a single source of truth.
///
/// On [OtpStatus.invalid] the row shakes and the field clears (§6.2).
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    required this.otp,
    required this.status,
    required this.onChanged,
    required this.onSubmit,
    super.key,
  });

  final String otp;
  final OtpStatus status;
  final ValueChanged<String> onChanged;

  /// Fired when the code transitions from incomplete to complete —
  /// exactly once per filled code (§6.2).
  final VoidCallback onSubmit;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  final TweenSequence<double> _shakeTween = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 0, end: -10)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 25,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: -10, end: 10)
          .chain(CurveTween(curve: Curves.easeInOut)),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 10, end: 0)
          .chain(CurveTween(curve: Curves.easeIn)),
      weight: 25,
    ),
  ]);

  /// Tracks the previous length so auto-submit fires on the fill
  /// transition only — never on rebuilds or repeated input events.
  int _previousLength = 0;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.otp;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void didUpdateWidget(OtpInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // State-driven clears (invalid/expired/resend) mirror back into the
    // hidden field so the view never diverges from the controller.
    if (widget.otp != oldWidget.otp && widget.otp != _controller.text) {
      _controller.text = widget.otp;
      _previousLength = widget.otp.length;
    }
    if (widget.status == OtpStatus.invalid &&
        oldWidget.status != OtpStatus.invalid) {
      _shake.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final otp = digits.length > 6 ? digits.substring(0, 6) : digits;
    _controller.value = TextEditingValue(
      text: otp,
      selection: TextSelection.collapsed(offset: otp.length),
    );
    widget.onChanged(otp);

    final filled = otp.length == 6 && _previousLength < 6;
    _previousLength = otp.length;
    if (filled) {
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeTween.evaluate(_shake), 0),
        child: child,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final filled = index < widget.otp.length;
              final digit = filled ? widget.otp[index] : '';
              final isNext = index == widget.otp.length;
              final focused = isNext &&
                  (widget.status == OtpStatus.idle ||
                      widget.status == OtpStatus.invalid);
              return Container(
                key: ValueKey('otp_cell_$index'),
                width: 46,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.glassFill,
                  border: Border.all(
                    color: filled || focused
                        ? AppTheme.neonCyan
                        : AppTheme.glassBorder,
                    width: filled || focused ? 1.5 : 1,
                  ),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: filled ? 1 : 0,
                  child: Text(
                    digit,
                    style: AppTheme.num(24, weight: FontWeight.w700,
                        color: AppTheme.textPrimary),
                  ),
                ),
              );
            }),
          ),
          // The real input: invisible but focused so the keyboard opens
          // and every digit/paste lands in one place.
          TextField(
            key: const ValueKey('otp_hidden_field'),
            controller: _controller,
            focusNode: _focusNode,
            showCursor: false,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            style: const TextStyle(color: Colors.transparent),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              filled: false,
            ),
            onChanged: _handleChanged,
          ),
        ],
      ),
    );
  }
}
