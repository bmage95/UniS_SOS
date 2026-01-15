import 'package:flutter/material.dart';
import 'pages/police_map_screen.dart';
import 'pages/newsletter_screen.dart';
import 'pages/sos_screen.dart';
import 'pages/settings_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widget/bottomnavbar.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ Environment variables loaded successfully");
  } catch (e) {
    print("⚠️ Failed to load .env file: $e");
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("⚠️ Failed to initialize Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency SOS',
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    InShortsScreen(),
    RadarHomePage(onNavigateToMap: _navigateToMap),
    const SettingsScreen(),
  ];

  void _navigateToMap() {
    setState(() {
      _currentIndex = 1;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PoliceMapScreen()),
      );
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        backgroundColor: Colors.grey[600],
        extendBody: true, // Crucial for the glass effect to see content behind
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(
          left: 16, 
          right: 16, 
          top: 16, 
          bottom: 4, 
        ),
          child: buildBottomNavBar(context,_currentIndex, _onTabSelected),
        ),
      ),
    );
  }
}