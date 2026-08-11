import 'package:vibe_swipe/src/core/services/registry_service/di.dart';
import 'package:vibe_swipe/src/core/services/remote_config_service.dart';

class ApiRoutes {
  ///
  /// Serving url
  ///
  static String get baseUrl {
    try {
      return locator<RemoteConfigService>().baseUrl;
    } catch (_) {
      return 'http://177.7.33.210:8000';
    }
  }

  ///
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String chatRoom = "/chat/room";
  static const String chatSend = "/chat/send";
  static const String chatUploadSignature = "/chat/upload-signature";
  static const String chatHistory = "/chat/history";
  static const String chatConversations = "/chat/conversations";
  static const String chatRead = "/chat/read";

  static const String featuredListing = '/featured-listing';
  static const String featuredListingName = '/featured-listing-name';
  static const String userDetails = '/auth/kyc';
  static const String kycSendOtp = '/auth/kyc-otp/send';
  static const String kycOtpVerify = '/auth/kyc-otp/verify';
  static const String uploadKycImage = '/auth/kyc-image';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String sendOtp = '/auth/send-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String featuredListingPricing = '/featured-listing/pricing';
  static const String users = '/user';
  static const String bird = '/bird';
  static const String birdOffspringDetails = '/bird/offspring-details';
  static const String birdCounts = '/bird/counts';
  static const String clutch = '/clutch';
  static const String clutchEggs = '/clutch/eggs';
  static const String clutchBox = '/clutch/box';
  static const String clutchTransferEgg = '/clutch/transfer-egg';
  static const String topVeterniary = '/veterinary/top-veterinary';

  static const String createVeterinaryService = '/veterinary/service';
  static const String getVeterinaryAppointments = '/veterinary/appointment';
  static const String createVeterinaryAppointment = '/veterinary/appointment';
  static const String updateVeterinaryAppointmentStatus =
      '/veterinary/appointment/status';
  static const String veterinaryService = '/veterinary/service';
  static const String veterinaryReview = '/veterinary/review';
  static const String listingReview = '/review';
  static const String promotions = '/promotion';
  static const String changePassword = '/user/change-password';
  static const String feed = '/feed';
  static const String events = '/event';

  static const String stripeCreatePaymentIntent = '/stripe/create-payment-intent';
  static const String stripeConfirmPayment = '/stripe/confirm-payment';
  static const String stripeCheckAccess = '/stripe/check-access';
  static const String stripeTransactionHistory = '/stripe/transaction-history';
}
