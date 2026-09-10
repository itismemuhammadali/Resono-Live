import '../../../../core/utils/app_exports.dart';

class ModeSelectionView extends HookConsumerWidget {
  const ModeSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: const Color(0xFF11151E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                children: [
                  Image.asset('assets/logo/vibe_swip_logo.jpeg', height: 80.h),
                  SizedBox(height: 20.h),
                  Text('Welcome to Vibe Swipe', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  Text('Choose your role', style: TextStyle(fontSize: 16.sp, color: Colors.grey[400]), textAlign: TextAlign.center),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      AppConfig.userRole = UserRole.listener;
                      AppRouterGo.pushReplacement('/onboarding');
                    },
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.listenerYellow, width: 2), borderRadius: BorderRadius.circular(16.r), color: Colors.grey[900]),
                      child: Row(
                        children: [
                          Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: AppColors.listenerYellow.withOpacity(0.2), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.favorite, color: AppColors.listenerYellow, size: 28.sp)),
                          SizedBox(width: 16.w),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Listener', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height: 4.h), Text('Discover and enjoy music', style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]))])),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  GestureDetector(
                    onTap: () {
                      AppConfig.userRole = UserRole.artist;
                      AppRouterGo.pushReplacement('/onboarding');
                    },
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.listenerYellow, width: 2), borderRadius: BorderRadius.circular(16.r), color: Colors.grey[900]),
                      child: Row(
                        children: [
                          Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: AppColors.listenerYellow.withOpacity(0.2), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.mic, color: AppColors.listenerYellow, size: 28.sp)),
                          SizedBox(width: 16.w),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Artist', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height: 4.h), Text('Share your music', style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]))])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
