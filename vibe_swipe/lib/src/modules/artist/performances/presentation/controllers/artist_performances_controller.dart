import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/performance_entity.dart';

final artistPerformancesControllerProvider =
    ChangeNotifierProvider.autoDispose<ArtistPerformancesController>(
      (ref) => ArtistPerformancesController(),
    );

class ArtistPerformancesController extends ChangeNotifier with Buffers {
  String _artistName = '';
  String get artistName => _artistName;
  int selectedTabIndex = 0;

  final List<PerformanceEntity> allItems = [];
  final List<PerformanceEntity> upcomingItems = [];
  final List<PerformanceEntity> pastItems = [];
  final List<PerformanceEntity> recordedItems = [];
  final List<PerformanceEntity> draftItems = [];

  ArtistPerformancesController() {
    fetchArtistName();
    fetchPerformances();
    _fetchAvailableSongs();
  }

  Future<void> _fetchAvailableSongs() async {
    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('tracks')
          .where('artistId', isEqualTo: uid)
          .get();

      _availableSongs = snapshot.docs
          .map((doc) => (doc.data()['title'] ?? '').toString())
          .where((t) => t.isNotEmpty)
          .toList();
      notifyListeners();
    } catch (e) {
      appPrint('[Performances] Error fetching songs: $e');
      _availableSongs = [];
    }
  }

  Future<void> fetchArtistName() async {
    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) return;
      final data = await locator<FirestoreService>().getUserData(uid);
      if (data != null) {
        _artistName = (data['artistName'] ?? data['name'] ?? '').toString();
        notifyListeners();
      }
    } catch (e) {
      appPrint('[Performances] Error fetching artist name: $e');
    }
  }

  Future<void> fetchPerformances() async {
    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('performances')
          .where('artist_id', isEqualTo: uid)
          .get();

      upcomingItems.clear();
      pastItems.clear();
      recordedItems.clear();
      draftItems.clear();
      allItems.clear();
      for (final doc in snapshot.docs) {
        final p = doc.data();
        final status = p['status'] ?? 'upcoming';
        final videoUrl = p['videoUrl'] ?? '';
        final type = (p['type'] ?? 'live').toString();

        DateTime parsedDate = DateTime.now();
        final rawCreated = p['createdAt'];
        if (rawCreated is Timestamp) {
          parsedDate = rawCreated.toDate();
        } else if (rawCreated is String) {
          parsedDate = DateTime.tryParse(rawCreated) ?? DateTime.now();
        }

        final entity = PerformanceEntity(
          id: doc.id,
          title: p['title'] ?? '',
          thumbnailUrl: p['thumbnailUrl'] ?? '',
          status: _parseStatus(status),
          date: parsedDate,
          viewCount: (p['viewers_count'] as num?)?.toInt() ?? 0,
          liveCount: 0,
          description: p['description'],
          category: p['genres'] is List && (p['genres'] as List).isNotEmpty ? p['genres'][0] : null,
          videoUrl: videoUrl,
          type: type,
          isPaid: p['isPaid'] == true,
          ticketPrice: (p['ticketPrice'] as num?)?.toDouble() ?? (p['price'] as num?)?.toDouble() ?? 0.0,
          ticketTier: (p['ticketTier'] ?? p['tierNumber']) as int?,
          ticketProductId: p['ticketProductId'] as String?,
        );
        allItems.add(entity);
        switch (entity.status) {
          case PerformanceStatus.upcoming:
            upcomingItems.add(entity);
            if (type == 'recorded') {
              recordedItems.add(entity);
            }
            break;
          case PerformanceStatus.live:
            // Active live stream stays in allItems and can be viewed
            break;
          case PerformanceStatus.past:
            pastItems.add(entity);
            if (videoUrl.isNotEmpty || type == 'recorded') {
              recordedItems.add(entity);
            }
            break;
          case PerformanceStatus.pending:
            draftItems.add(entity);
            break;
        }
      }
      allItems.sort((a, b) => b.date.compareTo(a.date));
      upcomingItems.sort((a, b) => b.date.compareTo(a.date));
      pastItems.sort((a, b) => b.date.compareTo(a.date));
      recordedItems.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      appPrint('[Performances] Error fetching performances: $e');
    }
  }

  PerformanceStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return PerformanceStatus.live;
      case 'upcoming':
      case 'scheduled':
        return PerformanceStatus.upcoming;
      case 'ended':
      case 'completed':
      case 'past':
        return PerformanceStatus.past;
      case 'draft':
      case 'pending':
        return PerformanceStatus.pending;
      default:
        return PerformanceStatus.upcoming;
    }
  }

  Future<bool> deletePerformance(String performanceId) async {
    try {
      await locator<FirestoreService>().deletePerformance(performanceId);
      allItems.removeWhere((item) => item.id == performanceId);
      upcomingItems.removeWhere((item) => item.id == performanceId);
      pastItems.removeWhere((item) => item.id == performanceId);
      recordedItems.removeWhere((item) => item.id == performanceId);
      draftItems.removeWhere((item) => item.id == performanceId);
      notifyListeners();
      appPrint('[Performances] Successfully deleted performance: $performanceId');
      return true;
    } catch (e) {
      appPrint('[Performances] Error deleting performance: $e');
      return false;
    }
  }

  int get allCount => allItems.length;
  int get upcomingCount => upcomingItems.length;
  int get pastCount => pastItems.length;
  int get recordedCount => recordedItems.length;
  int get draftsCount => draftItems.length;

  List<PerformanceEntity> get currentItems {
    switch (selectedTabIndex) {
      case 0:
        return allItems;
      case 1:
        return upcomingItems;
      case 2:
        return pastItems;
      case 3:
        return recordedItems;
      case 4:
        return draftItems;
      default:
        return [];
    }
  }

  // Schedule Live Session – Step 1
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final int totalSteps = 5;
  final int currentStep = 1;

  // Paid performance state
  bool isPaidPerformance = false;
  TicketTier selectedTier = TicketTier.allTiers[1]; // Default to Tier 2 ($5)
  final TextEditingController priceController = TextEditingController();

  void setPerformanceType(bool isPaid) {
    isPaidPerformance = isPaid;
    if (!isPaid) {
      priceController.clear();
    } else {
      priceController.text = selectedTier.price.toStringAsFixed(0);
    }
    notifyListeners();
  }

  void selectTicketTier(TicketTier tier) {
    selectedTier = tier;
    priceController.text = tier.price.toStringAsFixed(0);
    notifyListeners();
  }

  double get ticketPrice => isPaidPerformance ? selectedTier.price : 0.0;

  bool get canContinueSession {
    return titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  void onSessionFieldChanged() => notifyListeners();

  // Edit Performance
  String? editCoverImageUrl;

  void initEditData({
    required String title,
    required String description,
    required String date,
    required String time,
    required String? category,
    required List<String> tags,
    String? coverImageUrl,
    bool isPaid = false,
    TicketTier? tier,
  }) {
    titleController.text = title;
    descriptionController.text = description;
    dateController.text = date;
    timeController.text = time;
    selectedCategory = category;
    isPaidPerformance = isPaid;
    if (tier != null) {
      selectedTier = tier;
    }
    this.tags
      ..clear()
      ..addAll(tags);
    editCoverImageUrl = coverImageUrl;
    coverImage = null;
    coverImageBytes = null;
    notifyListeners();
  }

  Future<bool> updatePerformanceDetails(String performanceId) async {
    try {
      final data = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'genres': selectedCategory != null ? [selectedCategory!] : [],
        'isPaid': isPaidPerformance,
        'ticketPrice': isPaidPerformance ? selectedTier.price : 0.0,
        'ticketTier': isPaidPerformance ? selectedTier.tierNumber : null,
        'ticketProductId': isPaidPerformance ? selectedTier.productId : null,
      };

      if (dateController.text.isNotEmpty && timeController.text.isNotEmpty) {
        final parsedDate = _parseScheduledDateTime();
        if (parsedDate != null) {
          data['scheduledAt'] = Timestamp.fromDate(parsedDate);
        }
      }

      if (coverImageBytes != null) {
        final thumbnailUrl = await locator<FirestoreService>()
            .uploadPerformanceThumbnail(performanceId, coverImageBytes!);
        data['thumbnailUrl'] = thumbnailUrl;
      }

      await locator<FirestoreService>().updatePerformance(performanceId, data);
      await fetchPerformances();
      appPrint('[Performances] Successfully updated performance $performanceId');
      return true;
    } catch (e) {
      appPrint('[Performances] Error updating performance: $e');
      return false;
    }
  }

  // Schedule Live Session – Step 2
  XFile? coverImage;
  Uint8List? coverImageBytes;

  Future<void> pickCoverImage(BuildContext context) async {
    ImageSourceSheet.show(context, (file) async {
      if (file != null) {
        coverImage = file;
        coverImageBytes = await file.readAsBytes();
        notifyListeners();
      }
    });
  }

  // Schedule Live Session – Step 3
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  bool get canContinueDateTime =>
      dateController.text.trim().isNotEmpty &&
      timeController.text.trim().isNotEmpty;

  // Upload Performance – Step 1
  XFile? uploadVideoFile;

  Future<void> pickVideoFile(BuildContext context) async {
    final file = await AppImagePicker.videoFromGallery();
    if (file != null) {
      uploadVideoFile = file;
      notifyListeners();
    }
  }

  // Upload Performance – Step 2
  XFile? uploadThumbnailImage;
  Uint8List? uploadThumbnailImageBytes;

  Future<void> pickThumbnailImage(BuildContext context) async {
    ImageSourceSheet.show(context, (file) async {
      if (file != null) {
        uploadThumbnailImage = file;
        uploadThumbnailImageBytes = await file.readAsBytes();
        notifyListeners();
      }
    });
  }

  // Upload Performance – Step 3
  final TextEditingController uploadPerformanceTitleController =
      TextEditingController();
  final TextEditingController uploadPerformanceDescriptionController =
      TextEditingController();

  bool get canContinuePerformanceDetails =>
      uploadPerformanceTitleController.text.trim().isNotEmpty &&
      uploadPerformanceDescriptionController.text.trim().isNotEmpty;

  void onPerformanceDetailsFieldChanged() => notifyListeners();

  // Upload Performance – Step 4 (Category & Tags)
  String? uploadLinkedSong;

  List<String> _availableSongs = [];
  List<String> get availableSongs => _availableSongs;

  void selectUploadLinkedSong(String? song) {
    uploadLinkedSong = song;
    notifyListeners();
  }

  // Publish Performance
  bool _isPublishing = false;
  bool get isPublishing => _isPublishing;

  Future<bool> publishPerformance() async {
    if (_isPublishing) return false;
    _isPublishing = true;
    notifyListeners();

    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) throw Exception('Not authenticated');

      final title = uploadPerformanceTitleController.text.trim();
      final description = uploadPerformanceDescriptionController.text.trim();
      if (title.isEmpty) throw Exception('Title is required');

      // 1. Create performance record first to get the ID
      final performanceId = await locator<FirestoreService>().createPerformance(
        artistId: uid,
        title: title,
        description: description,
        genres: selectedCategory != null ? [selectedCategory!] : [],
        type: 'recorded',
      );

      // 2. Upload video to Firebase Storage
      final updateData = <String, dynamic>{};
      if (uploadVideoFile != null) {
        final videoBytes = await uploadVideoFile!.readAsBytes();
        final videoUrl = await locator<FirestoreService>().uploadPerformanceVideo(performanceId, videoBytes);
        updateData['videoUrl'] = videoUrl;
      }

      // 3. Upload thumbnail to Firebase Storage
      if (uploadThumbnailImageBytes != null) {
        final thumbnailUrl = await locator<FirestoreService>().uploadPerformanceThumbnail(performanceId, uploadThumbnailImageBytes!);
        updateData['thumbnailUrl'] = thumbnailUrl;
      }

      // 4. Update performance with file URLs if any
      if (updateData.isNotEmpty) {
        await locator<FirestoreService>().updatePerformance(performanceId, updateData);
      }

      // 5. Refresh performances list
      await fetchPerformances();
      _clearUploadState();

      appPrint('[Performances] Performance published: $performanceId');
      return true;
    } catch (e) {
      appPrint('[Performances] Error publishing performance: $e');
      return false;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  // Schedule Live Session
  bool _isScheduling = false;
  bool get isScheduling => _isScheduling;

  Future<bool> scheduleLiveSession() async {
    if (_isScheduling) return false;
    _isScheduling = true;
    notifyListeners();

    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) throw Exception('Not authenticated');

      final title = titleController.text.trim();
      final description = descriptionController.text.trim();
      if (title.isEmpty) throw Exception('Title is required');

      // 1. Create performance record first to get the ID
      final performanceId = await locator<FirestoreService>().createPerformance(
        artistId: uid,
        title: title,
        description: description,
        genres: selectedCategory != null ? [selectedCategory!] : [],
        status: 'upcoming',
        type: 'live',
        scheduledAt: _parseScheduledDateTime(),
        isPaid: isPaidPerformance,
        ticketPrice: isPaidPerformance ? selectedTier.price : null,
        ticketTier: isPaidPerformance ? selectedTier.tierNumber : null,
        ticketProductId: isPaidPerformance ? selectedTier.productId : null,
      );

      // 2. Upload cover image to Firebase Storage
      if (coverImageBytes != null) {
        final thumbnailUrl = await locator<FirestoreService>().uploadPerformanceThumbnail(performanceId, coverImageBytes!);
        await locator<FirestoreService>().updatePerformance(performanceId, {
          'thumbnailUrl': thumbnailUrl,
        });
      }

      // 3. Refresh performances list
      await fetchPerformances();
      _clearScheduleState();

      appPrint('[Performances] Live session scheduled: $performanceId');
      return true;
    } catch (e) {
      appPrint('[Performances] Error scheduling live session: $e');
      return false;
    } finally {
      _isScheduling = false;
      notifyListeners();
    }
  }

  bool _isGoingLive = false;
  bool get isGoingLive => _isGoingLive;

  Future<PerformanceEntity?> startInstantLiveSession({
    required String title,
    String? description,
    String? category,
    bool isPaid = false,
    double? ticketPrice,
    int? ticketTier,
    String? ticketProductId,
    Uint8List? coverBytes,
  }) async {
    if (_isGoingLive) return null;
    _isGoingLive = true;
    notifyListeners();

    try {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid == null) throw Exception('Not authenticated');

      final channelName = locator<RemoteConfigService>().agoraChannelName;

      // 1. Create performance document with status live
      final performanceId = await locator<FirestoreService>().createPerformance(
        artistId: uid,
        title: title,
        description: description,
        genres: category != null ? [category] : [],
        status: 'live',
        type: 'live',
        isPaid: isPaid,
        ticketPrice: isPaid ? ticketPrice : null,
        ticketTier: isPaid ? ticketTier : null,
        ticketProductId: isPaid ? ticketProductId : null,
      );

      // 2. Upload cover thumbnail if provided
      String thumbnailUrl = '';
      if (coverBytes != null) {
        thumbnailUrl = await locator<FirestoreService>()
            .uploadPerformanceThumbnail(performanceId, coverBytes);
        await locator<FirestoreService>().updatePerformance(performanceId, {
          'thumbnailUrl': thumbnailUrl,
        });
      }

      // 3. Mark live with Agora channel in Firestore
      await locator<FirestoreService>().startLivePerformance(
        performanceId: performanceId,
        channelName: channelName,
      );

      // 4. Refresh performances list
      await fetchPerformances();

      final entity = PerformanceEntity(
        id: performanceId,
        title: title,
        thumbnailUrl: thumbnailUrl,
        status: PerformanceStatus.live,
        date: DateTime.now(),
        viewCount: 0,
        liveCount: 0,
        description: description,
        category: category,
        type: 'live',
      );

      return entity;
    } catch (e) {
      appPrint('[Performances] Error starting instant live session: $e');
      return null;
    } finally {
      _isGoingLive = false;
      notifyListeners();
    }
  }

  void _clearUploadState() {
    uploadVideoFile = null;
    uploadThumbnailImage = null;
    uploadThumbnailImageBytes = null;
    uploadPerformanceTitleController.clear();
    uploadPerformanceDescriptionController.clear();
    selectedCategory = null;
    tags.clear();
    uploadLinkedSong = null;
  }

  void _clearScheduleState() {
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
    timeController.clear();
    coverImage = null;
    coverImageBytes = null;
    selectedCategory = null;
    tags.clear();
    isPaidPerformance = false;
    selectedTier = TicketTier.allTiers[1];
    priceController.clear();
  }

  DateTime? _parseScheduledDateTime() {
    try {
      final dateText = dateController.text.trim();
      final timeText = timeController.text.trim();
      if (dateText.isEmpty || timeText.isEmpty) return null;

      // dateController format: "MM/DD/YYYY"
      final dateParts = dateText.split('/');
      if (dateParts.length != 3) return null;
      final month = int.parse(dateParts[0]);
      final day = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // timeController format: "H:MM AM/PM"
      final timeParts = timeText.split(' ');
      if (timeParts.length != 2) return null;
      final hourMinute = timeParts[0].split(':');
      var hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      final period = timeParts[1].toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      appPrint('[Performances] Error parsing scheduled date/time: $e');
      return null;
    }
  }

  // Schedule Live Session – Step 4
  static const List<String> availableCategories = [
    'Live Concert',
    'Studio Session',
    'Q&A',
    'Behind the Scenes',
    'Acoustic',
    'DJ Set',
  ];

  String? selectedCategory;
  final List<String> tags = [];
  final TextEditingController tagController = TextEditingController();

  bool get canContinueCategory => selectedCategory != null;

  // Schedule Live Session – Step 5
  bool isDiscoverable = true;

  void toggleDiscoverable() {
    isDiscoverable = !isDiscoverable;
    notifyListeners();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagController.clear();
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
    notifyListeners();
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: _pickerTheme,
        child: child!,
      ),
    );
    if (picked != null) {
      dateController.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      notifyListeners();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: _pickerTheme,
        child: child!,
      ),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      timeController.text = '$hour:$minute $period';
      notifyListeners();
    }
  }

  static final _pickerTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: AppColors.listenerActiveTab,
      onPrimary: AppColors.listenerDashboardBg,
      surface: AppColors.listenerChipBg,
      onSurface: AppColors.primaryWhite,
      secondaryContainer: AppColors.listenerActiveTab.withValues(alpha: 0.2),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.listenerDashboardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.listenerActiveTab,
      ),
    ),
  );

  List<String> get tabs => [
        'All ($allCount)',
        'Upcoming ($upcomingCount)',
        'Past ($pastCount)',
        'Recorded ($recordedCount)',
        'Drafts ($draftsCount)',
      ];

  void onTabChanged(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  bool get isCurrentTabEmpty => currentItems.isEmpty;

  String get emptyStateLabel {
    switch (selectedTabIndex) {
      case 0:
        return 'No performances yet';
      case 1:
        return 'No upcoming performances';
      case 2:
        return 'No past performances';
      case 3:
        return 'No recorded performances';
      case 4:
        return 'No drafts';
      default:
        return 'No performances';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    tagController.dispose();
    uploadPerformanceTitleController.dispose();
    uploadPerformanceDescriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
