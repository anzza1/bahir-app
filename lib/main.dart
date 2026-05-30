import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: BahirTheme.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const BahirApp()));
}

class BahirApp extends StatelessWidget {
  const BahirApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BAHIR',
    debugShowCheckedModeBanner: false,
    theme: BahirTheme.dark,
    builder: (context, child) => Directionality(
      textDirection: TextDirection.rtl, child: child!),
    home: const SplashScreen(),
  );
}
