import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding1_screen.dart';
import 'screens/onboarding2_screen.dart';
import 'screens/onboarding3_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/phone_verification_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/add_job_screen.dart';
import 'screens/my_active_services_screen.dart';
import 'screens/my_services_requests_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/unified_chat_list_screen.dart';
import 'detalle_candidato_screen.dart';
import 'detalle_puesto_trabajo_screen.dart';
import 'screens/forgot_password_email_screen.dart';
import 'screens/forgot_password_code_screen.dart';
import 'screens/forgot_password_change_screen.dart';
import 'mapa_servicios_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Manos Locales',
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding1': (context) => const Onboarding1Screen(),
          '/onboarding2': (context) => const Onboarding2Screen(),
          '/onboarding3': (context) => const Onboarding3Screen(),
          '/terms': (context) => const TermsScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/verify-email': (context) => const EmailVerificationScreen(),
          '/verify-phone': (context) => const PhoneVerificationScreen(),
          '/home': (context) => const HomeDashboardScreen(),
          '/discover': (context) => const DiscoverScreen(),
          '/add-job': (context) => const AddJobScreen(),
          '/my-active-services': (context) => const MyActiveServicesScreen(),
          '/my-service-requests': (context) => const MyServicesRequestsScreen(),
          '/profile': (context) => ProfileScreen(),
          '/chat': (context) => const UnifiedChatListScreen(),
          '/detalle_candidato': (context) => const DetalleCandidatoScreen(),
          '/detalle_puesto': (context) => const DetallePuestoScreen(),
          '/forgot-password-email': (context) =>
              const ForgotPasswordEmailScreen(),
          '/forgot-password-code': (context) =>
              const ForgotPasswordCodeScreen(),
          '/forgot-password-change': (context) =>
              const ForgotPasswordChangeScreen(),
          '/mapa-servicios': (context) => const MapaServiciosScreen(),
        },
      ),
    );
  }
}
