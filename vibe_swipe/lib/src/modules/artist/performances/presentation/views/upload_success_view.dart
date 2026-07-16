import 'dart:async';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../../dashboard/presentation/controllers/artist_dashboard_controller.dart';

class UploadSuccessView extends ConsumerStatefulWidget {
  const UploadSuccessView({super.key});

  @override
  ConsumerState<UploadSuccessView> createState() => _UploadSuccessViewState();
}

class _UploadSuccessViewState extends ConsumerState<UploadSuccessView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      ref.read(artistDashboardInitialTabProvider.notifier).state = 1;
      AppRouterGo.pushRemoveUntil(artistDashboardView);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/png/success_live_session_icn.png'),
              24.ph,
              Text(
                'Publish Performance!',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.primaryWhite,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              10.ph,
              Text(
                'Your track is now live',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.primaryWhite.withValues(alpha: 0.5),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
