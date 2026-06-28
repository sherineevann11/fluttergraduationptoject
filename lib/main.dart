import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:graduationproject/features/loading_screen/presentation_layer/LoadingScreenview.dart';
import 'package:graduationproject/features/auth/view/reset_email_screen.dart';
import 'package:graduationproject/features/auth/view/otp_screen.dart';
import 'package:graduationproject/features/auth/view/new_password_screen.dart';
import 'package:graduationproject/features/lognIn_screen/presentation_layer/loginScreenView.dart';
import 'package:graduationproject/features/signup_screen/presentation_layer/signupscreemView.dart';
import 'package:graduationproject/features/main_screen.dart';
import 'package:graduationproject/features/splashscreen/presentationlayer/Splashscreenview.dart';

// ✅ Anti-Tampering: Expected official package name (6.1 - Penetration Report)
const String _expectedPackageName = 'com.example.graduationproject';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // ✅ Root/Jailbreak Detection Security Check (6.3 - Penetration Report)
  await checkDeviceSafety();

  // ✅ Anti-Tampering: Package Integrity Check (6.1 - Penetration Report)
  final bool isTampered = await checkAppIntegrity();

  runApp(App(isTampered: isTampered));
}

Future<void> checkDeviceSafety() async {
  final detector = RootJailbreakDetector();
  bool isCompromised = false;

  try {
    if (Platform.isAndroid) {
      isCompromised = (await detector.isRooted()) ?? false;
    } else if (Platform.isIOS) {
      isCompromised = (await detector.isJailbreaked()) ?? false;
    }
  } on PlatformException {
    isCompromised = false;
  }

  if (isCompromised) {
    debugPrint('⚠️ SECURITY WARNING: Device is rooted/jailbroken - Security risk detected');
  }
}

Future<bool> checkAppIntegrity() async {
  try {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentPackageName = packageInfo.packageName;

    if (currentPackageName != _expectedPackageName) {
      debugPrint(
        '🚨 TAMPERING DETECTED: Package name mismatch. '
        'Expected: $_expectedPackageName, Found: $currentPackageName',
      );
      return true;
    }
    return false;
  } catch (e) {
    debugPrint('⚠️ Could not verify app integrity: $e');
    return false;
  }
}

class App extends StatelessWidget {
  final bool isTampered;
  const App({super.key, this.isTampered = false});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: isTampered
                    ? _TamperedAppWarning()
                    : widget!,
              ),
            );
          },
          home: const LoadingScreen(),
          getPages: [
            GetPage(
              name: '/SplashScreenView',
              page: () => const SplashScreenView(),
            ),
            GetPage(
              name: '/login',
              page: () => const LoginScreenView(),
            ),
            GetPage(
              name: '/signup',
              page: () => const SignUpScreenView(),
            ),
            GetPage(
              name: '/mainscreen',
              page: () => const MainScreen(),
            ),
            GetPage(
              name: '/reset-email',
              page: () => ResetEmailScreen(),
            ),
            GetPage(
              name: '/otp',
              page: () => OtpScreen(),
            ),
            GetPage(
              name: '/new-password',
              page: () => ResetPasswordScreen(),
            ),
          ],
        );
      },
    );
  }
}

/// ✅ Anti-Tampering: Shown when package integrity check fails (6.1)
class _TamperedAppWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'تم اكتشاف نسخة غير رسمية من التطبيق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'لأسباب أمنية، لا يمكن تشغيل هذه النسخة. '
                  'يرجى تحميل التطبيق من المصدر الرسمي.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
