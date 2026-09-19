import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AppImagePicker {
  static final _picker = ImagePicker();

  static Future<XFile?> fromGallery() async {
    try {
      // On iOS, image_picker uses PHPickerViewController which runs out-of-process
      // and does not require explicit Photo Library permissions.
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
    } catch (e) {
      debugPrint('[AppImagePicker] Error picking image from gallery: $e');
      return null;
    }
  }

  static Future<XFile?> fromCamera() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          // User tapped "Don't Allow" or camera is not granted.
          // Respect user decision per Apple Guideline 5.1.1(iv) — never redirect to settings automatically.
          return null;
        }
      }
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
    } catch (e) {
      debugPrint('[AppImagePicker] Error picking image from camera: $e');
      return null;
    }
  }

  static Future<XFile?> videoFromGallery() async {
    try {
      return await _picker.pickVideo(source: ImageSource.gallery);
    } catch (e) {
      debugPrint('[AppImagePicker] Error picking video from gallery: $e');
      return null;
    }
  }
}

// import 'dart:io';
// //import 'package:file_picker/file_picker.dart');
// //import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';


// class AppHelpers {
//   static Future<void> openUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch url $url';
//     }
//   }

//   static Future<void> openDialPad(String phoneNumber) async {
//     final uri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch $phoneNumber';
//     }
//   }

//   static Future<void> openEmailClient(String emailAddress) async {
//     final uri = Uri(
//       scheme: 'mailto',
//       path: emailAddress,
//     );
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch email client for $emailAddress';
//     }
//   }

//   static Future<File> pickSingleFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'docx', 'doc'],
//     );
//     if (result != null) {
//       File file = File(result.files.single.path!);
//       return file;
//     } else {
//       throw ('Failed to pick file');
//     }
//   }

//   static final ImagePicker _picker = ImagePicker();
//   static Future<XFile?> pick() async {
//     return await _picker.pickImage(source: ImageSource.gallery);
//   }

//   static Future<XFile?> capture() async {
//     return await _picker.pickImage(source: ImageSource.camera);
//   }

//   // give time like 3 minutes/seconds ago etc
//   static String getFormattedDate(DateTime date) {
//     DateTime now = DateTime.now().toLocal();
//     DateTime newDate = date.toLocal();

//     Duration difference = now.difference(newDate);

//     int inSeconds = difference.inSeconds;
//     int inMinutes = difference.inMinutes;
//     int inHours = difference.inHours;
//     int inDays = difference.inDays;

//     if (inSeconds < 60) {
//       return "$inSeconds sec ago";
//     } else if (inMinutes < 60) {
//       return "$inMinutes min ago";
//     } else if (inHours < 24) {
//       return "$inHours hr${inHours > 1 ? 's' : ''} ago";
//     } else if (inDays == 1) {
//       return "Yesterday";
//     } else if (inDays < 7) {
//       return "$inDays days ago";
//     } else if (inDays < 30) {
//       int weeks = (inDays / 7).floor();
//       return "$weeks week${weeks > 1 ? 's' : ''} ago";
//     } else if (inDays < 365) {
//       int months = (inDays / 30).floor();
//       return "$months month${months > 1 ? 's' : ''} ago";
//     } else {
//       int years = (inDays / 365).floor();
//       return "$years year${years > 1 ? 's' : ''} ago";
//     }
//   }

//   static DateFormat formatter = DateFormat('yyyy-MM-dd');

//   static String formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) {
//       return 'N/A';
//     }
//     try {
//       return DateFormat('MMM dd, yyyy').format(DateTime.parse(dateString));
//     } catch (e) {
//       return 'Invalid date';
//     }
//   }

//   static String formatTime(String? dateString) {
//     if (dateString == null || dateString.isEmpty) {
//       return 'N/A';
//     }
//     try {
//       return DateFormat('h:mm a').format(DateTime.parse(dateString));
//     } catch (e) {
//       return 'Invalid time';
//     }
//   }

//   static Future<List<XFile?>?> pickMultiple() async {
//     final ImagePicker picker = ImagePicker();
//     final List<XFile?> images = await picker.pickMultiImage();
//     return images;
//   }

//   static String formatDateTime(DateTime dateTime) {
//     return DateFormat('hh:mm a').format(dateTime);
//   }

// // add method to share multiple files via share_plus package
//   static Future<void> shareMultipleFiles(List<XFile> filePaths) async {
//     try {
//       await Share.shareXFiles(filePaths);
//     } catch (e) {
//       throw Exception('Could not share files: $e');
//     }
//   }
// }
