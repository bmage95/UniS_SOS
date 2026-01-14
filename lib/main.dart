import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/police_map_screen.dart';
import 'pages/newsletter_screen.dart';
import 'pages/sos_screen.dart';
import 'pages/settings_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widget/bottomnavbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ Environment variables loaded successfully");
  } catch (e) {
    print("⚠️ Failed to load .env file: $e");
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: buildBottomNavBar(_currentIndex, _onTabSelected),
      ),
    );
  }
}