// File: FirestoreService.dart

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
  // Caches & Subscriptions (State)
  // -------------------------------
  Devotion? _latestDevotionCache;
  StaffOnDuty? _cachedStaff;

  StreamSubscription<Devotion?>? _devotionSubscription;
  StreamSubscription<StaffOnDuty?>? _staffSubscription;

  // ⚡️ FIX 1: Use synchronous broadcast stream for minimal delay and immediate data delivery
  final StreamController<List<Notice>> _noticesController =
      StreamController<List<Notice>>.broadcast(sync: true);
  StreamSubscription<List<Notice>>? _noticesSubscription;
  List<Notice>? _cachedNotices;
  static const String _noticesCacheKey = 'cachedNotices';
  static const int _maxNoticesToKeep = 100;

  static const String _staffCacheKey = 'latestStaffOnDuty';
  static const String _devotionCacheKey = 'latestDevotion';

  // ⚡️ FIX 2 for Red Screen: Guaranteed initialization upon class instantiation
  late final Future<void> _initializationComplete = _setupListenersAndCaches();

  // -------------------------------
  // Constructor & Initialization
  // -------------------------------

  FirestoreService(); // Simple, empty constructor.

  // Public accessor for the initialization Future
  Future<void> get initializationComplete => _initializationComplete;

  // Dedicated setup method that runs once and awaits caching
  Future<void> _setupListenersAndCaches() async {
    await _initializeCaches();

    _startDevotionListener();
    _startStaffListener();
    _startNoticesListener();
  }

  // Load all local data concurrently on startup
  Future<void> _initializeCaches() async {
    final results = await Future.wait([
      _loadDevotionLocally(),
      _loadStaffLocally(),
      _loadNoticesLocally(),
    ]);

    _latestDevotionCache = results[0] as Devotion?;
    _cachedStaff = results[1] as StaffOnDuty?;
    _cachedNotices = results[2] as List<Notice>?;
  }

  // -------------------------------
  // DEVOTION METHODS
  // -------------------------------

  void disposeDevotionListener() {
    _devotionSubscription?.cancel();
  }

  Stream<Devotion?> getLatestDevotionWithFallback() async* {
    if (_latestDevotionCache != null) yield _latestDevotionCache;

    final localDevotion = await _loadDevotionLocally();
    if (localDevotion != null && localDevotion != _latestDevotionCache) {
      _latestDevotionCache = localDevotion;
      yield localDevotion;
    }

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
    if (_cachedStaff != null) yield _cachedStaff;

    final localStaff = await _loadStaffLocally();
    if (localStaff != null && localStaff != _cachedStaff) {
      _cachedStaff = localStaff;
      yield localStaff;
    }

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

  // -------------------------------
  // NOTICES IMPLEMENTATION (Final)
  // -------------------------------

  Future<List<Notice>?> _loadNoticesLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_noticesCacheKey);
    if (cachedJson == null) return null;
    try {
      final List decoded = jsonDecode(cachedJson);
      return decoded.map((e) => Notice.fromJson(e)).toList();
    } catch (e) {
      print('Error decoding cached notices: $e');
      return null;
    }
  }

  void _startNoticesListener() {
    if (_noticesSubscription != null) return;

    // The logic to push the initial cache is now handled by getNoticesWithCache().

    final stream = _db
        .collection('notices')
        .orderBy('date', descending: true)
        .limit(_maxNoticesToKeep)
        .snapshots()
        .map((snap) {
          final notices = snap.docs
              .map((d) => Notice.fromFirestore(d))
              .toList();
          return notices;
        });

    _noticesSubscription = stream.listen(
      (notices) async {
        // 1. Update memory cache
        _cachedNotices = notices;
        // 2. Push live updates to controller
        _noticesController.add(notices);

        // 3. Save new data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(
          _noticesCacheKey,
          jsonEncode(notices.map((n) => n.toJson()).toList()),
        );
      },
      onError: (e) {
        print('Firestore Notices Stream Error: $e');
        if (_cachedNotices != null) {
          _noticesController.add(_cachedNotices!);
        }
      },
    );
  }

  // ⚡️ FIX 3: Yield current cache immediately, then yield the long-lived stream.
  Stream<List<Notice>> getNoticesWithCache() async* {
    // 1. Yield the current memory cache immediately (instant UI population)
    if (_cachedNotices != null) {
      yield _cachedNotices!;
    }

    // 2. Yield the long-lived stream for all future updates
    yield* _noticesController.stream;
  }

  // ------------------------
  // CLEANUP (CRITICAL FOR BATTERY LIFE)
  // ------------------------
  @override
  void dispose() {
    _staffSubscription?.cancel();
    _devotionSubscription?.cancel();
    _noticesSubscription?.cancel();
    _noticesController.close();
  }
}
