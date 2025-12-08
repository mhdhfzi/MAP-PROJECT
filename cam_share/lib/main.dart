import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/renter_beginner_dashboard.dart';
import 'screens/renter_pro_dashboard.dart';
import 'screens/owner_dashboard.dart';
import 'screens/booking_request_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CamShare',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/renterBeginnerDashboard': (context) => const RenterDashboard(),
        '/renterProDashboard': (context) => const RenterProDashboard(),
        '/ownerDashboard': (context) => const OwnerDashboard(),
        '/bookingRequest': (context) => const BookingRequestPage(),

      },
    );
  }
}
