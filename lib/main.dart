import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design/themes/app_themes.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    RefenaScope(
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppThemes.init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
      ),

      // Tema oscuro
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),

      initialRoute: AppRouter.getInitialRoute(),
      routes: AppRouter.routes,
    );
  }
}