import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grace_by/models/notices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grace_by/models/devtions.dart';
import 'package:grace_by/models/announcements.dart';
import 'package:grace_by/models/staff_on_duty.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // -------------------------------
  // Caches
  // -------------------------------
  Devotion? _latestDevotionCache;
  StreamSubscription<Devotion?>? _devotionSubscription;

  StaffOnDuty? _cachedStaff;
  StreamSubscription<StaffOnDuty?>? _staffSubscription;

  static const String _staffCacheKey = 'latestStaffOnDuty';
  static const String _devotionCacheKey = 'latestDevotion';

  // -------------------------------
  // Constructor
  // -------------------------------
  FirestoreService() {
    _initializeCaches(); // Load local caches on startup
    _startDevotionListener();
    _startStaffListener();
  }

  Future<void> _initializeCaches() async {
    _latestDevotionCache = await _loadDevotionLocally();
    _cachedStaff = await _loadStaffLocally();
  }

  // -------------------------------
  // DEVOTION METHODS
  // -------------------------------

  void disposeDevotionListener() {
    _devotionSubscription?.cancel();
  }

  Stream<Devotion?> getLatestDevotionWithFallback() async* {
    // 1️⃣ Yield memory cache immediately
    if (_latestDevotionCache != null) yield _latestDevotionCache;

    // 2️⃣ Yield local SharedPreferences data
    final localDevotion = await _loadDevotionLocally();
    if (localDevotion != null && localDevotion != _latestDevotionCache) {
      _latestDevotionCache = localDevotion;
      yield localDevotion;
    }

    // 3️⃣ Yield live updates from Firestore
    yield* _db
        .collection('devotions')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final devotion = Devotion.fromJson(snapshot.docs.first.data());
            _latestDevotionCache = devotion;
            _saveDevotionLocally(devotion);
            return devotion;
          }
          return _latestDevotionCache;
        })
        .handleError((e) {
          print('Devotion Stream Error: $e');
          return _latestDevotionCache;
        });
  }

  void _startDevotionListener() {
    final stream = _db
        .collection('devotions')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.isNotEmpty
              ? Devotion.fromJson(snapshot.docs.first.data())
              : null,
        );

    _devotionSubscription = stream.listen((devotion) async {
      if (devotion != null) {
        _latestDevotionCache = devotion;
        await _saveDevotionLocally(devotion);
      }
    }, onError: (e) => print('Firestore Devotion Stream Error: $e'));
  }

  Future<void> _saveDevotionLocally(Devotion devotion) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_devotionCacheKey, jsonEncode(devotion.toJson()));
  }

  Future<Devotion?> _loadDevotionLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_devotionCacheKey);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return Devotion.fromLocalJson(jsonMap);
    } catch (e) {
      print('Error loading cached devotion: $e');
      return null;
    }
  }

  // -------------------------------
  // ANNOUNCEMENTS
  // -------------------------------

  Stream<List<Announcement>> getRecentAnnouncements(int limit) {
    return _db
        .collection('announcements')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Announcement.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addAnnouncement(Announcement newAnnouncement) async {
    if (newAnnouncement.id.isEmpty) {
      await _db.collection('announcements').add(newAnnouncement.toFirestore());
    } else {
      await _db
          .collection('announcements')
          .doc(newAnnouncement.id)
          .update(newAnnouncement.toFirestore());
    }
  }

  // -------------------------------
  // STAFF ON DUTY
  // -------------------------------

  Stream<StaffOnDuty?> getStaffOnDutyWithCache() async* {
    // 1️⃣ Yield memory cache first
    if (_cachedStaff != null) yield _cachedStaff;

    // 2️⃣ Load local data instantly if available
    final localStaff = await _loadStaffLocally();
    if (localStaff != null && localStaff != _cachedStaff) {
      _cachedStaff = localStaff;
      yield localStaff;
    }

    // 3️⃣ Yield Firestore live updates
    yield* _db
        .collection('staff')
        .doc('staff_info')
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (data == null) return _cachedStaff;
          final staff = StaffOnDuty.fromFirestore(data);
          _cachedStaff = staff;
          _saveStaffLocally(staff);
          return staff;
        })
        .handleError((e) {
          print('Staff Stream Error: $e');
          return _cachedStaff;
        });
  }

  void _startStaffListener() {
    if (_staffSubscription != null) return;

    final stream = _db
        .collection('staff')
        .doc('staff_info')
        .snapshots()
        .map(
          (doc) => doc.data() != null
              ? StaffOnDuty.fromFirestore(doc.data()!)
              : null,
        );

    _staffSubscription = stream.listen((staff) {
      if (staff != null) {
        _cachedStaff = staff;
        _saveStaffLocally(staff);
      }
    }, onError: (e) => print('Staff Stream Error: $e'));
  }

  Future<void> _saveStaffLocally(StaffOnDuty staff) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_staffCacheKey, jsonEncode(staff.toJson()));
  }

  Future<StaffOnDuty?> _loadStaffLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_staffCacheKey);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return StaffOnDuty.fromLocalJson(jsonMap);
    } catch (e) {
      print('Error loading cached staff: $e');
      return null;
    }
  }

  // ------------------------
  // CLEANUP
  // ------------------------
  void dispose() {
    _staffSubscription?.cancel();
    _devotionSubscription?.cancel();
  }

  // =====================
  // Notices with Caching
  // =====================

  // FirestoreService.dart

  Stream<List<Notice>> getNoticesWithCache() async* {
    const cacheKey = 'cachedNotices';
    final prefs = await SharedPreferences.getInstance();

    // Define the maximum number of recent notices to fetch and cache.
    // This value determines the length of the list the user will see.
    const int maxNoticesToKeep =
        100; // You can adjust this number (e.g., 50, 200)

    // Step 1: Load cached notices first (for offline view)
    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      try {
        final List decoded = jsonDecode(cachedJson);
        final cached = decoded.map((e) => Notice.fromJson(e)).toList();
        if (cached.isNotEmpty) yield cached;
      } catch (e) {
        // Handle potential decoding errors gracefully
        print('Error decoding cached notices: $e');
      }
    }

    // Step 2: Firestore live updates (LIMITED QUERY)
    yield* _db
        .collection('notices')
        .orderBy('date', descending: true)
        .limit(maxNoticesToKeep) // <--- LIMIT APPLIED HERE
        .snapshots()
        .map((snap) {
          final notices = snap.docs
              .map((d) => Notice.fromFirestore(d))
              .toList();

          // Save ONLY the limited list to SharedPreferences,
          // effectively purging older notices from the local cache.
          prefs.setString(
            cacheKey,
            jsonEncode(notices.map((n) => n.toJson()).toList()),
          );
          return notices;
        });
  }
}
