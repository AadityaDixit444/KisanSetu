import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/role_selection_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pdfmhiwulroqdwzmjzfw.supabase.co',
    publishableKey: 'sb_publishable_4PbJLGc9CwALqwm3i65lkA_w8jxuPAC',
  );

  runApp(const KisanSetuApp());
}

class KisanSetuApp extends StatelessWidget {
  const KisanSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KisanSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RoleSelectionScreen(),
    );
  }
}