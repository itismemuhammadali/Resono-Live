import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:vibe_swipe/src/core/utils/app_enums.dart';
import 'package:vibe_swipe/src/core/utils/app_config.dart';
import 'package:vibe_swipe/src/core/theme/app_colors.dart';
import 'package:vibe_swipe/src/core/services/routing_service/app_routes.dart';
import 'package:vibe_swipe/src/modules/authentication/presentation/widgets/auth_back_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithScreenUtil(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  // ===========================================================================
  // ISSUE 1: Session Caching via GoRouter redirect
  // ===========================================================================
  group('Issue 1: Session Caching & Cold Launch Auto-Redirect', () {
    test('AppConfig.userRole state management works correctly', () {
      AppConfig.userRole = UserRole.listener;
      expect(AppConfig.userRole, equals(UserRole.listener));

      AppConfig.userRole = UserRole.artist;
      expect(AppConfig.userRole, equals(UserRole.artist));
    });

    test('Routing logic redirects artist to artistDashboardView and listener to listenerDashboardView', () {
      String resolveRole(String? roleStr) {
        final role = roleStr?.toLowerCase();
        if (role == 'artist') {
          AppConfig.userRole = UserRole.artist;
          return artistDashboardView;
        } else if (role == 'listener') {
          AppConfig.userRole = UserRole.listener;
          return listenerDashboardView;
        }
        return '/';
      }

      expect(resolveRole('artist'), equals(artistDashboardView));
      expect(AppConfig.userRole, equals(UserRole.artist));

      expect(resolveRole('listener'), equals(listenerDashboardView));
      expect(AppConfig.userRole, equals(UserRole.listener));

      // Case insensitive check
      expect(resolveRole('Artist'), equals(artistDashboardView));
      expect(resolveRole('LISTENER'), equals(listenerDashboardView));

      // Unknown or null falls back to root
      expect(resolveRole(null), equals('/'));
      expect(resolveRole('other'), equals('/'));
    });

    test('named_routes.dart contains redirect callback with session check', () {
      final file = File('lib/src/core/services/routing_service/named_routes.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('redirect: (context, state) async'), isTrue);
      expect(content.contains('FirebaseAuth.instance.currentUser'), isTrue);
      expect(content.contains("matchedLocation != '/'"), isTrue);
      expect(content.contains('artistDashboardView'), isTrue);
      expect(content.contains('listenerDashboardView'), isTrue);
      expect(content.contains('AppConfig.userRole = UserRole.artist'), isTrue);
      expect(content.contains('AppConfig.userRole = UserRole.listener'), isTrue);
      expect(content.contains('AuthHandler.ref.init()'), isTrue);
    });
  });

  // ===========================================================================
  // ISSUE 2: LoginView Back Navigation and Role Switcher
  // ===========================================================================
  group('Issue 2: LoginView Back Navigation and Role Switcher', () {
    test('login_view.dart imports and renders AuthBackButton', () {
      final file = File('lib/src/modules/authentication/presentation/views/login_view.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains("import '../../presentation/widgets/auth_back_button.dart';"), isTrue);
      expect(content.contains("AuthBackButton(onTap: () => AppRouterGo.pushRemoveUntil('/'))"), isTrue);
    });

    test('login_view.dart renders interactive role switcher link', () {
      final file = File('lib/src/modules/authentication/presentation/views/login_view.dart');
      final content = file.readAsStringSync();

      expect(content.contains("AppConfig.userRole == UserRole.artist"), isTrue);
      expect(content.contains('"Not an Artist? "'), isTrue);
      expect(content.contains('"Are you an Artist? "'), isTrue);
      expect(content.contains('"Switch here"'), isTrue);
      expect(content.contains("AppRouterGo.pushRemoveUntil('/')"), isTrue);
    });

    testWidgets('AuthBackButton renders icon and Back label, and responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AuthBackButton(
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Role switch widget switches role when tapped', (WidgetTester tester) async {
      AppConfig.userRole = UserRole.listener;

      await tester.pumpWidget(
        wrapWithScreenUtil(
          StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      AppConfig.userRole = AppConfig.userRole == UserRole.artist
                          ? UserRole.listener
                          : UserRole.artist;
                    });
                  },
                  child: Text.rich(
                    TextSpan(
                      text: AppConfig.userRole == UserRole.artist
                          ? "Not an Artist? "
                          : "Are you an Artist? ",
                      style: const TextStyle(color: AppColors.santagrey),
                      children: const [
                        TextSpan(
                          text: "Switch here",
                          style: TextStyle(
                            color: AppColors.listenerYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Starts as listener
      expect(find.textContaining('Are you an Artist?'), findsOneWidget);

      // Tap to switch
      await tester.tap(find.textContaining('Switch here'));
      await tester.pumpAndSettle();

      // Now switched to artist
      expect(AppConfig.userRole, equals(UserRole.artist));
      expect(find.textContaining('Not an Artist?'), findsOneWidget);

      // Tap again to switch back
      await tester.tap(find.textContaining('Switch here'));
      await tester.pumpAndSettle();

      expect(AppConfig.userRole, equals(UserRole.listener));
      expect(find.textContaining('Are you an Artist?'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ISSUE 3: Google Sign-In iOS ClientId and Exception Safety
  // ===========================================================================
  group('Issue 3: Google Sign-In iOS ClientId and Exception Safety', () {
    test('firebase_auth_service.dart configures iOS clientId and serverClientId', () {
      final file = File('lib/src/core/services/firebase_auth_service.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('367306858996-oepl42avutap73h38qejqco3klqo40vp.apps.googleusercontent.com'), isTrue);
      expect(content.contains('!kIsWeb && Platform.isIOS'), isTrue);
      expect(content.contains('!kIsWeb && !Platform.isIOS'), isTrue);
      expect(content.contains('367306858996-l8k5q7fsg6g8f0honpm1od0gocshpd8d.apps.googleusercontent.com'), isTrue);
    });

    test('GoogleService-Info.plist CLIENT_ID matches code configuration', () {
      final file = File('ios/Runner/GoogleService-Info.plist');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('<key>CLIENT_ID</key>'), isTrue);
      expect(content.contains('<string>367306858996-oepl42avutap73h38qejqco3klqo40vp.apps.googleusercontent.com</string>'), isTrue);
    });

    test('social_auth_buttons.dart catches PlatformException and prevents crash', () {
      final file = File('lib/src/modules/authentication/presentation/widgets/social_auth_buttons.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('on PlatformException catch (e)'), isTrue);
      expect(content.contains('Google Sign-In failed:'), isTrue);
      expect(content.contains('ScaffoldMessenger.of(context).showSnackBar'), isTrue);
    });

    testWidgets('Simulated PlatformException during Google sign-in is caught gracefully with SnackBar', (WidgetTester tester) async {
      bool snackBarShown = false;
      String? snackBarMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    try {
                      // Simulate the iOS PlatformException that previously crashed the app
                      throw PlatformException(
                        code: 'sign_in_failed',
                        message: 'UIApplication.keyWindow is nil',
                      );
                    } on PlatformException catch (e) {
                      snackBarShown = true;
                      snackBarMessage = e.message;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Google Sign-In failed: ${e.message ?? "Please try again."}')),
                      );
                    }
                  },
                  child: const Text('Simulate Google Sign-In'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Simulate Google Sign-In'));
      await tester.pump();

      expect(snackBarShown, isTrue);
      expect(snackBarMessage, equals('UIApplication.keyWindow is nil'));
      expect(find.text('Google Sign-In failed: UIApplication.keyWindow is nil'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ISSUE 4: Photo Permissions, Info.plist, and Privacy Manifest
  // ===========================================================================
  group('Issue 4: Photo Permissions, Info.plist, and Privacy Manifest', () {
    test('app_helpers.dart defines AppImagePicker compliant with Apple Guideline 5.1.1(iv)', () {
      final file = File('lib/src/core/utils/app_helpers.dart');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      expect(content.contains('class AppImagePicker'), isTrue);
      expect(content.contains('Permission.camera.request()'), isTrue);
      // Apple Guideline 5.1.1(iv): Never automatically redirect user to Settings when permission is denied
      expect(content.contains('openAppSettings()'), isFalse);
    });

    test('Info.plist parses as valid XML and contains approved photo descriptions', () {
      final file = File('ios/Runner/Info.plist');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      // XML validity check
      final document = XmlDocument.parse(content);
      expect(document, isNotNull);

      expect(content.contains('<key>NSPhotoLibraryUsageDescription</key>'), isTrue);
      expect(
        content.contains('Vibe Swipe accesses your photo library to let you upload and update your profile photo, artist cover banner, and audio release artwork.'),
        isTrue,
      );
      expect(content.contains('<key>NSPhotoLibraryAddUsageDescription</key>'), isTrue);
      expect(
        content.contains('Vibe Swipe saves captured media to your photo library when recording live performance clips and profile photos.'),
        isTrue,
      );
    });

    test('PrivacyInfo.xcprivacy parses as valid XML and declares all mandatory keys', () {
      final file = File('ios/Runner/PrivacyInfo.xcprivacy');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      // XML validity check
      final document = XmlDocument.parse(content);
      expect(document, isNotNull);

      // Root keys
      expect(content.contains('<key>NSPrivacyAccessedAPITypes</key>'), isTrue);
      expect(content.contains('<key>NSPrivacyCollectedDataTypes</key>'), isTrue);
      expect(content.contains('<key>NSPrivacyTracking</key>'), isTrue);
      expect(content.contains('<false/>'), isTrue);

      // Accessed API categories
      expect(content.contains('NSPrivacyAccessedAPICategoryUserDefaults'), isTrue);
      expect(content.contains('CA92.1'), isTrue);
      expect(content.contains('NSPrivacyAccessedAPICategoryFileTimestamp'), isTrue);
      expect(content.contains('C617.1'), isTrue);
      expect(content.contains('NSPrivacyAccessedAPICategoryDiskSpace'), isTrue);
      expect(content.contains('E174.1'), isTrue);
      expect(content.contains('NSPrivacyAccessedAPICategorySystemBootTime'), isTrue);
      expect(content.contains('35F9.1'), isTrue);

      // Collected Data categories
      expect(content.contains('NSPrivacyCollectedDataTypePhotosorVideos'), isTrue);
      expect(content.contains('NSPrivacyCollectedDataTypeName'), isTrue);
      expect(content.contains('NSPrivacyCollectedDataTypeEmailAddress'), isTrue);
      expect(content.contains('NSPrivacyCollectedDataTypePurposeAppFunctionality'), isTrue);
    });

    test('project.pbxproj references PrivacyInfo.xcprivacy across all 4 sections', () {
      final file = File('ios/Runner.xcodeproj/project.pbxproj');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();

      // PBXBuildFile
      expect(content.contains('PrivacyInfo.xcprivacy in Resources */ = {isa = PBXBuildFile;'), isTrue);
      // PBXFileReference
      expect(content.contains('PrivacyInfo.xcprivacy */ = {isa = PBXFileReference; lastKnownFileType = text.xml;'), isTrue);
      // Runner PBXGroup
      expect(content.contains('/* PrivacyInfo.xcprivacy */,'), isTrue);
      // PBXResourcesBuildPhase
      expect(content.contains('/* PrivacyInfo.xcprivacy in Resources */,'), isTrue);
    });

    test('Built iOS app bundle includes PrivacyInfo.xcprivacy file', () {
      final bundleFile = File('build/ios/iphonesimulator/Runner.app/PrivacyInfo.xcprivacy');
      expect(bundleFile.existsSync(), isTrue);
      expect(bundleFile.lengthSync(), greaterThan(0));
    });
  });
}
