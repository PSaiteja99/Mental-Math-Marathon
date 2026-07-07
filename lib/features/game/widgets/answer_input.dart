import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mental_math_marathon/app/constants.dart';

class AnswerInput extends StatefulWidget {
  final void Function(int answer) onSubmit;

  const AnswerInput({super.key, required this.onSubmit});

  @override
  State<AnswerInput> createState() => _AnswerInputState();
}

class _AnswerInputState extends State<AnswerInput> {
  final FocusNode _focusNode = FocusNode();
  String _input = '';
  bool _isNegative = false;

  void _onDigit(String digit) {
    setState(() {
      if (_input.length < 6) {
        _input += digit;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      } else if (_isNegative) {
        _isNegative = false;
      }
    });
  }

  void _onToggleSign() {
    setState(() {
      _isNegative = !_isNegative;
    });
  }

  void _onSubmit() {
    if (_input.isEmpty) return;
    final answer = (_isNegative ? -1 : 1) * int.parse(_input);
    widget.onSubmit(answer);
    setState(() {
      _input = '';
      _isNegative = false;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    final keyId = key.keyId;
    if (keyId >= LogicalKeyboardKey.digit0.keyId && keyId <= LogicalKeyboardKey.digit9.keyId) {
      final digit = String.fromCharCode(keyId & 0xFFFF);
      _onDigit(digit);
      return KeyEventResult.handled;
    }

    if (keyId >= LogicalKeyboardKey.numpad0.keyId && keyId <= LogicalKeyboardKey.numpad9.keyId) {
      final digit = String.fromCharCode(keyId & 0xFFFF);
      _onDigit(digit);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.backspace) {
      _onBackspace();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      _onSubmit();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.minus || key == LogicalKeyboardKey.numpadSubtract) {
      _onToggleSign();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF334155)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isNegative)
                Text(
                  '-',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                _input.isEmpty ? '?' : _input,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _input.isEmpty
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]
                          : Colors.grey[400])
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (final row in [
                ['7', '8', '9'],
                ['4', '5', '6'],
                ['1', '2', '3'],
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: row.map((digit) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _NumPadButton(
                            label: digit,
                            onTap: () => _onDigit(digit),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _NumPadButton(
                          label: '+/-',
                          onTap: _onToggleSign,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _NumPadButton(
                          label: '0',
                          onTap: () => _onDigit('0'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _NumPadButton(
                          label: '⌫',
                          onTap: _onBackspace,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _input.isEmpty ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('SUBMIT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

class _NumPadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumPadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
      borderRadius: BorderRadius.circular(12),
      elevation: isDark ? 0 : 1,
      shadowColor: isDark ? Colors.transparent : AppConstants.primaryBlue.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: isDark
            ? AppConstants.primaryBlue.withValues(alpha: 0.15)
            : AppConstants.primaryBlue.withValues(alpha: 0.08),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFE2E8F0) : AppConstants.secondaryNightBlue,
            ),
          ),
        ),
      ),
    );
  }
}
