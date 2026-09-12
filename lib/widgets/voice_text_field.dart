import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../localization/language_scope.dart';
import '../services/voice_input_service.dart';
import '../theme/app_colors.dart';

enum _VoiceState { idle, starting, listening, downloading, translating }

/// A [TextFormField] with a microphone button.
///
/// Tap the mic → speak → the field is filled with English text.
/// In Hindi mode the recogniser listens in Hindi and the words are translated
/// to English on-device, so what is saved to Supabase is always English.
/// The Hindi that was heard is shown under the field for the farmer to check.
///
/// Drop-in replacement for a plain [TextFormField]:
/// ```dart
/// VoiceTextField(
///   controller: _locationController,
///   decoration: const InputDecoration(labelText: 'Location'),
///   validator: ...,
/// )
/// ```
class VoiceTextField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLines;

  /// Optional: called with the final English text after a successful capture.
  final ValueChanged<String>? onVoiceResult;

  const VoiceTextField({
    super.key,
    required this.controller,
    this.decoration = const InputDecoration(),
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLines = 1,
    this.onVoiceResult,
  });

  @override
  State<VoiceTextField> createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends State<VoiceTextField>
    with SingleTickerProviderStateMixin {
  final VoiceInputService _voice = VoiceInputService();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  _VoiceState _state = _VoiceState.idle;
  String _heard = '';

  /// Translation key of the status line under the field, translated in
  /// [build] so it follows the language toggle and never reads a
  /// BuildContext after an await.
  String? _messageKey;
  bool _messageIsError = false;

  @override
  void dispose() {
    _pulse.dispose();
    _voice.dispose();
    super.dispose();
  }

  bool get _busy => _state != _VoiceState.idle;

  void _setState(_VoiceState state, {String? messageKey, bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _state = state;
      _messageKey = messageKey;
      _messageIsError = isError;
    });
  }

  Future<void> _onMicPressed() async {
    if (_state == _VoiceState.listening) {
      await _voice.stop();
      return;
    }
    if (_busy) return;
    await _startListening();
  }

  Future<void> _startListening() async {
    // Read everything that needs a BuildContext before the first await.
    final languageCode = context.currentLanguage.code;
    final isHindi = context.isHindi;

    _setState(_VoiceState.starting);
    setState(() => _heard = '');

    try {
      final available = await _voice.initialize(onStatus: _onSpeechStatus);
      if (!available) {
        _setState(_VoiceState.idle,
            messageKey: 'voice_unavailable', isError: true);
        return;
      }

      final localeId = await _voice.resolveLocaleId(languageCode);
      _setState(_VoiceState.listening, messageKey: 'voice_listening');

      await _voice.listen(
        localeId: localeId,
        onResult: (words, isFinal) => _onSpeechResult(words, isFinal, isHindi),
      );
    } on VoicePermissionDenied {
      _setState(_VoiceState.idle,
          messageKey: 'voice_permission_denied', isError: true);
    } catch (error) {
      debugPrint('KisanSetu voice: start failed: $error');
      _setState(_VoiceState.idle,
          messageKey: 'voice_unavailable', isError: true);
    }
  }

  void _onSpeechStatus(String status) {
    // The recogniser stops on its own after a pause; if we never got a final
    // result, drop back to idle so the mic is usable again.
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      if (_state == _VoiceState.listening) {
        _setState(
          _VoiceState.idle,
          messageKey: _heard.isEmpty ? 'voice_nothing_heard' : null,
          isError: _heard.isEmpty,
        );
      }
    }
  }

  Future<void> _onSpeechResult(String words, bool isFinal, bool isHindi) async {
    if (!mounted) return;
    setState(() => _heard = words);

    if (!isFinal) return;
    if (words.trim().isEmpty) {
      _setState(_VoiceState.idle,
          messageKey: 'voice_nothing_heard', isError: true);
      return;
    }

    if (!isHindi) {
      _applyResult(words.trim());
      return;
    }

    await _translateAndApply(words.trim());
  }

  Future<void> _translateAndApply(String hindi) async {
    try {
      if (!await _voice.isTranslationModelReady()) {
        _setState(_VoiceState.downloading, messageKey: 'voice_downloading');
      } else {
        _setState(_VoiceState.translating, messageKey: 'voice_translating');
      }

      final english = await _voice.translateHindiToEnglish(hindi);
      _applyResult(english.isEmpty ? hindi : english);
    } on VoiceTranslationUnavailable {
      // Web / desktop: keep the Hindi so the demo still shows something.
      widget.controller.text = hindi;
      _setState(_VoiceState.idle,
          messageKey: 'voice_translate_unavailable', isError: true);
    } catch (error) {
      debugPrint('KisanSetu voice: translation failed: $error');
      widget.controller.text = hindi;
      _setState(_VoiceState.idle,
          messageKey: 'auth_err_generic', isError: true);
    }
  }

  void _applyResult(String text) {
    widget.controller.text = text;
    widget.controller.selection = TextSelection.collapsed(offset: text.length);
    _setState(_VoiceState.idle);
    widget.onVoiceResult?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listening = _state == _VoiceState.listening;
    final working = _state == _VoiceState.starting ||
        _state == _VoiceState.downloading ||
        _state == _VoiceState.translating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          maxLines: widget.maxLines,
          decoration: widget.decoration.copyWith(
            suffixIcon: _MicButton(
              listening: listening,
              working: working,
              pulse: _pulse,
              onPressed: working ? null : _onMicPressed,
            ),
          ),
        ),
        if (_messageKey != null || _heard.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_messageKey != null)
                  Text(
                    context.tr(_messageKey!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color:
                          _messageIsError ? AppColors.error : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (_heard.isNotEmpty)
                  Text(
                    '${context.tr('voice_heard')}: $_heard',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool listening;
  final bool working;
  final Animation<double> pulse;
  final VoidCallback? onPressed;

  const _MicButton({
    required this.listening,
    required this.working,
    required this.pulse,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (working) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }

    final icon = IconButton(
      tooltip: listening
          ? context.tr('voice_listening')
          : context.tr('voice_tap_to_speak'),
      onPressed: onPressed,
      icon: Icon(
        listening ? Icons.stop_circle_rounded : Icons.mic_rounded,
        color: listening ? AppColors.error : AppColors.primary,
      ),
    );

    if (!listening) return icon;

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.error.withValues(alpha: 0.10 + 0.15 * pulse.value),
          ),
          child: child,
        );
      },
      child: icon,
    );
  }
}
