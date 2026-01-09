import 'package:flutter/material.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ice_storage/ice_storage.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'firebase_options.dart';
import 'design/themes/app_themes.dart';
import 'design/responsive/responsive_scaler.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Registrar fvp para soporte de videos con transparencia
  fvp.registerWith(
    options: {
      'video.decoders': ['FFmpeg'],
      'ao': 'AudioTrack',
      'avtrack.audio': -1,
    },
  );

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar IceStorage y Firestore Gateway
  await IceStorage.init();
  await IceStorage.initFirestoreGateway();

  runApp(RefenaScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        AppThemes.init(context);
        ResponsiveScaler.init(context);

        return child!;
      },
      // Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
      ),

      // Tema oscuro
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF131524),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),

      initialRoute: AppRouter.getInitialRoute(),
      routes: AppRouter.routes,
    );
  }
}
