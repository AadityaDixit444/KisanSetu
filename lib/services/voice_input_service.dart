import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Thrown when on-device translation is not available (web / desktop).
class VoiceTranslationUnavailable implements Exception {
  const VoiceTranslationUnavailable();
}

/// Thrown when the microphone / speech permission was refused.
class VoicePermissionDenied implements Exception {
  const VoicePermissionDenied();
}

/// Speech → text (device recogniser) and Hindi → English (ML Kit, on-device).
///
/// Speech works on Android, iOS, web (Chrome) and macOS.
/// Translation works on Android and iOS only; elsewhere
/// [translateHindiToEnglish] throws [VoiceTranslationUnavailable].
class VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();
  OnDeviceTranslator? _translator;

  bool _initialized = false;
  bool _permissionDenied = false;

  bool get isListening => _speech.isListening;

  static bool get translationSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Prepares the recogniser (asks for mic permission on first call).
  /// Returns false if speech recognition is unavailable on this device.
  Future<bool> initialize({void Function(String status)? onStatus}) async {
    if (_initialized) return true;

    _initialized = await _speech.initialize(
      onStatus: (status) => onStatus?.call(status),
      onError: (SpeechRecognitionError error) {
        debugPrint('KisanSetu voice error: ${error.errorMsg}');
        if (error.errorMsg.contains('permission') ||
            error.errorMsg == 'error_permission') {
          _permissionDenied = true;
        }
      },
    );

    if (!_initialized && !(await _speech.hasPermission)) {
      _permissionDenied = true;
    }
    if (_permissionDenied) throw const VoicePermissionDenied();
    return _initialized;
  }

  /// Picks the device's locale id for a language ('hi' / 'en').
  /// Android uses `hi_IN`, iOS/web use `hi-IN`, so look it up rather than guess.
  Future<String> resolveLocaleId(String languageCode) async {
    try {
      final locales = await _speech.locales();
      final match = locales.where((l) {
        final id = l.localeId.toLowerCase();
        return id.startsWith('${languageCode}_') ||
            id.startsWith('$languageCode-') ||
            id == languageCode;
      });
      // Prefer the India variant when several exist.
      for (final locale in match) {
        if (locale.localeId.toUpperCase().endsWith('IN')) return locale.localeId;
      }
      if (match.isNotEmpty) return match.first.localeId;
    } catch (error) {
      debugPrint('KisanSetu voice: could not list locales: $error');
    }
    final separator = kIsWeb ? '-' : '_';
    return '$languageCode${separator}IN';
  }

  /// Starts listening. [onResult] is called with interim text while the user
  /// speaks and once more with `isFinal == true` when they stop.
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
  }) async {
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
      ),
    );
  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();

  /// True when the Hindi + English packs are already on the device.
  Future<bool> isTranslationModelReady() async {
    if (!translationSupported) return false;
    final hi = await _modelManager
        .isModelDownloaded(TranslateLanguage.hindi.bcpCode);
    final en = await _modelManager
        .isModelDownloaded(TranslateLanguage.english.bcpCode);
    return hi && en;
  }

  /// Downloads the language packs (~30 MB each, once). Safe to call again.
  Future<void> ensureTranslationModel() async {
    if (!translationSupported) throw const VoiceTranslationUnavailable();
    for (final language in [TranslateLanguage.hindi, TranslateLanguage.english]) {
      final downloaded = await _modelManager.isModelDownloaded(language.bcpCode);
      if (!downloaded) {
        final ok = await _modelManager.downloadModel(language.bcpCode);
        if (!ok) {
          throw Exception('Could not download the ${language.name} language pack');
        }
      }
    }
  }

  Future<String> translateHindiToEnglish(String hindiText) async {
    if (!translationSupported) throw const VoiceTranslationUnavailable();
    if (hindiText.trim().isEmpty) return '';

    await ensureTranslationModel();
    _translator ??= OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.hindi,
      targetLanguage: TranslateLanguage.english,
    );
    return (await _translator!.translateText(hindiText)).trim();
  }

  void dispose() {
    if (_speech.isListening) _speech.cancel();
    _translator?.close();
    _translator = null;
  }
}
