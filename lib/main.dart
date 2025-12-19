import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/dashboard_screen.dart';
import 'providers/stock_provider.dart';
import 'services/gemini_service.dart';
import 'services/aws_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StockProvider(
            geminiService: GeminiService(),
            awsService: AWSService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'StockPulse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0a0e27),
          primaryColor: const Color(0xFF00d4aa),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF00d4aa),
            secondary: const Color(0xFF0099ff),
            surface: const Color(0xFF1a1f3a),
            surfaceDim: const Color(0xFF0a0e27),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}