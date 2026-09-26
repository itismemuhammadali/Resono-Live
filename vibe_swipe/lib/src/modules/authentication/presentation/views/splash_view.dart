import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    final startTime = DateTime.now();

    String targetRoute = modeSelectionView;
    UserRole? roleToSet;

    try {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(fbUser.uid)
            .get()
            .timeout(const Duration(seconds: 4));

        final data = doc.data();
        final roleStr = (data?['role'] as String?)?.toLowerCase();
        final profileCompleted = data?['profileCompleted'] == true;
        if (roleStr == 'artist') {
          roleToSet = UserRole.artist;
          targetRoute = profileCompleted ? artistDashboardView : artistSetupView;
        } else if (roleStr == 'listener') {
          roleToSet = UserRole.listener;
          targetRoute = profileCompleted ? listenerDashboardView : profileSetupView;
        }
      }
    } catch (e) {
      debugPrint('[SplashView] Error checking auth: $e');
    }

    // Ensure splash is visible for at least 1.8 seconds for smooth brand presentation
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    const minSplashDuration = 1800;
    if (elapsed < minSplashDuration) {
      await Future.delayed(Duration(milliseconds: minSplashDuration - elapsed));
    }

    if (!mounted) return;

    if (roleToSet != null) {
      AppConfig.userRole = roleToSet;
      try {
        await AuthHandler.ref.init();
      } catch (_) {}
    }

    if (mounted) {
      AppRouterGo.pushRemoveUntil(targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150.w,
                  height: 150.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: AppColors.listenerActiveTab.withValues(alpha: 0.15),
                        blurRadius: 36,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32.r),
                    child: Image.asset(
                      'assets/logo/vibe_swip_logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                28.ph,
                Text(
                  'VIBE SWIPE',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.0,
                    color: AppColors.primaryWhite,
                  ),
                ),
                8.ph,
                Text(
                  'Discover • Vibe • Connect',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                    color: AppColors.huegrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
