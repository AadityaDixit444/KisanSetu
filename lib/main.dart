import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'localization/app_localizations.dart';
import 'localization/language_controller.dart';
import 'localization/language_scope.dart';
import 'screens/role_selection_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pdfmhiwulroqdwzmjzfw.supabase.co',
    publishableKey: 'sb_publishable_4PbJLGc9CwALqwm3i65lkA_w8jxuPAC',
  );

  final languageController = LanguageController();
  await languageController.initialize();

  runApp(KisanSetuApp(languageController: languageController));
}

class KisanSetuApp extends StatefulWidget {
  final LanguageController? languageController;

  const KisanSetuApp({super.key, this.languageController});

  @override
  State<KisanSetuApp> createState() => _KisanSetuAppState();
}

class _KisanSetuAppState extends State<KisanSetuApp> {
  late final LanguageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.languageController ?? LanguageController();
  }

  @override
  void dispose() {
    if (widget.languageController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      controller: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return MaterialApp(
            title: 'KisanSetu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: _controller.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const RoleSelectionScreen(),
          );
        },
      ),
    );
  }
}