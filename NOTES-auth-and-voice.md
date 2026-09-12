# Auth + Voice input — what was added and how to use it

Branch: `aditya/contrib` (based on `backend-integration`).

## What changed

**Sign-in flow** (replaces the anonymous "tap a role" entry)

```
AuthGate (lib/screens/auth/auth_gate.dart)
  no session        → IntroScreen  → SignUpScreen / LoginScreen
  session, no role  → RoleSelectionScreen (language + farmer/buyer)
  session + role    → FarmerDashboard / BuyerDashboard
```

- Email + password via Supabase Auth. No Google, no anonymous.
- Name (from sign-up) and language ('en'/'hi') are stored in the **auth user
  metadata**, so there is no SQL to run. `profiles.name` is filled from it.
- Sign-out icon on both dashboards and on the role screen → back to intro.
- Old `Navigator.pop` back-arrow on the buyer dashboard removed (it is now a
  root screen; there is nothing to pop to).

**Language** — `lib/l10n/`
- `AppLanguage` holds the current code; `AppStrings.get('key')` returns the
  string. Only the new screens (intro, sign-in, sign-up, role, voice messages)
  are translated. To translate another screen: add keys to **both** maps in
  `app_strings.dart`, then `Text(AppStrings.get('key'))`.

**Voice input** — `lib/widgets/voice_text_field.dart`
- Drop-in replacement for `TextFormField` with a mic button. Already used on
  the location field of *Create Lot* and *Post Demand*.
- Hindi mode: listens in `hi_IN` → translates to English on-device
  (Google ML Kit) → fills the field. The Hindi that was heard is shown under
  the field. English mode: listens in `en_IN`, no translation.
- To add it to any other text field, change `TextFormField(` to
  `VoiceTextField(` and import the widget. Same `controller`, `decoration`,
  `validator` parameters.
- Service: `lib/services/voice_input_service.dart`.

## Test on a real phone

Speech works on Android, iOS, web and macOS. **Translation only works on
Android and iOS**, on other platforms the field keeps the Hindi text and
shows a note. First use downloads two language packs (~30 MB each, once).

```bash
flutter pub get
flutter run            # on a connected Android phone
```

iOS only: ML Kit needs iOS 15.5+. In `ios/Podfile` set
`platform :ios, '15.5'` before `pod install`.

## Supabase

- Auth → Providers → Email → "Confirm email" is currently **off** — keep it
  off for the demo (sign-up logs in immediately). If it is turned on, the app
  shows a "check your email" dialog and the user signs in after clicking the
  link.
- Two test users were created while verifying this branch, please delete
  them in Auth → Users: `t-aditya-kisansetu@example.com` and
  `test-aditya-kisansetu@example.com`.

## Files

```
lib/l10n/app_language.dart        language notifier
lib/l10n/app_strings.dart         en/hi strings
lib/screens/auth/auth_gate.dart   start-screen decision + AuthFlow helpers
lib/screens/auth/intro_screen.dart
lib/screens/auth/login_screen.dart
lib/screens/auth/signup_screen.dart
lib/screens/auth/auth_layout.dart auth page frame + error banner
lib/screens/auth/auth_errors.dart error → message, validators
lib/screens/role_selection_screen.dart   (rewritten)
lib/services/auth_service.dart    + displayName, preferredLanguage, updateLanguage
lib/services/profile_service.dart + getMyProfile, getMyRole, real name
lib/services/voice_input_service.dart
lib/widgets/voice_text_field.dart
lib/widgets/language_toggle.dart
lib/widgets/app_logo.dart
lib/widgets/sign_out_button.dart
android/.../AndroidManifest.xml   RECORD_AUDIO + speech service query
ios/Runner/Info.plist             mic + speech usage strings
test/widget_test.dart             replaced (old one needed a live Supabase)
```
