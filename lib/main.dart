import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'police_map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Environment variables loaded successfully");
  } catch (e) {
    print("⚠️ Failed to load .env file: $e");
    // Continue anyway - app can still work with hardcoded fallbacks
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency SOS',
      debugShowCheckedModeBanner: false,
      home: RadarHomePage(),
    );
  }
}

class RadarHomePage extends StatelessWidget {
  final double imageSize = 150;
  final Telephony telephony = Telephony.instance;

  final List<String> emergencyContacts = [
    '+919811403774',
    '+919404738170'
  ];

  void _launchDialer() async {
    final Uri uri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Dialer could not be launched");
    }
  }

  Future<void> _sendEmergencySMS() async {
    // SMS sending only works on Android
    if (!Platform.isAndroid) {
      print("ℹ️ SMS auto-send is only available on Android");
      // On iOS, open Messages app with pre-filled text
      _openMessagesApp();
      return;
    }

    try {
      final bool? smsPermission = await telephony.requestSmsPermissions;

      if (smsPermission == null || !smsPermission) {
        print("❌ SMS permission not granted");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final message =
          "🚨 Emergency!\nLat: ${position.latitude}, Long: ${position.longitude}";

      for (final number in emergencyContacts) {
        await telephony.sendSms(to: number, message: message);
      }

      print("✅ SMS sent to emergency contacts.");
    } catch (e) {
      print("⚠️ Error sending SMS: $e");
    }
  }

  void _openMessagesApp() async {
    try {
      // Get location for the message
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        print("⚠️ Could not get location: $e");
      }

      final message = position != null
          ? "🚨 Emergency! Lat: ${position.latitude}, Long: ${position.longitude}"
          : "🚨 Emergency! Please help!";

      // Open Messages app with pre-filled text (iOS)
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: emergencyContacts.first,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        print("📱 Opened Messages app");
      } else {
        print("❌ Could not open Messages app");
      }
    } catch (e) {
      print("⚠️ Error opening Messages: $e");
    }
  }

  void _handleRadarTap(BuildContext context) {
    _launchDialer(); // 1. Open dialer
    _sendEmergencySMS(); // 2. Send auto SMS
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PoliceMapScreen()),
    ); // 3. Show police station map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => _handleRadarTap(context),
          child: Image.asset(
            'assets/radar.png',
            width: imageSize,
            height: imageSize,
          ),
        ),
      ),
    );
  }
}
