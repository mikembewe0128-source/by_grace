// File: school_programmes_page.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/models/programmes.dart';
import 'package:grace_by/widgets/programme_card.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Helper function to check if two DateTime objects represent the same day
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// ----------------------------------------------------------------------
// 🔑 SHARD PREFERENCE KEYS
// ----------------------------------------------------------------------
const String _kSelectedDayKey = 'lastSelectedDay';
const String _kProgrammesMapKey = 'programmesMapCache';
const String _kGoogleProgrammesCacheKey =
    'googleProgrammesListCache'; // NEW KEY

// ----------------------------------------------------------------------
// 🔗 GOOGLE CALENDAR URL
// ----------------------------------------------------------------------
const String _kGoogleCalendarIcsUrl =
    'https://calendar.google.com/calendar/ical/admin%40chengeloschool.org/private-665b5078be27b752d6949a828d4496af/basic.ics';

class SchoolProgrammesPage extends StatefulWidget {
  const SchoolProgrammesPage({super.key});

  @override
  State<SchoolProgrammesPage> createState() => _SchoolProgrammesPageState();
}

class _SchoolProgrammesPageState extends State<SchoolProgrammesPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  SharedPreferences? _prefs;
  Map<DateTime, List<String>> _programmesByDate = {};
  List<Programme> _combinedProgrammes = [];

  // 👇 NEW: Variables for throttling network requests
  DateTime? _lastGoogleFetchTime;
  static const Duration _fetchThrottleDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay = DateTime.now();
    _initializePreferencesAndCache();
  }

  // ----------------------------------------------------------------------
  // 💾 PREFERENCES & CACHE SETUP
  // ----------------------------------------------------------------------
  Future<void> _initializePreferencesAndCache() async {
    _prefs = await SharedPreferences.getInstance();

    final savedDayString = _prefs!.getString(_kSelectedDayKey);
    if (savedDayString != null) {
      try {
        _selectedDay = DateTime.parse(savedDayString);
        _focusedDay = _selectedDay;
      } catch (e) {
        // Fallback to today
      }
    }

    // Load Programme Map (for markers)
    final cachedMap = _loadProgrammesMap();
    if (cachedMap.isNotEmpty) {
      _programmesByDate = cachedMap;
    }

    // Load Google Programme List (for daily event display)
    final cachedGoogleProgrammes = _loadGoogleProgrammesCache();
    if (cachedGoogleProgrammes.isNotEmpty) {
      // Use cached data for initial display (fast launch)
      _combinedProgrammes = cachedGoogleProgrammes;
      _buildProgrammeMap(_combinedProgrammes, shouldSetState: false);
    }

    setState(() {});
  }

  Future<void> _saveSelectedDay(DateTime day) async {
    if (mounted) {
      await _prefs?.setString(_kSelectedDayKey, day.toIso8601String());
    }
  }

  Future<void> _saveProgrammesMap(Map<DateTime, List<String>> map) async {
    if (mounted) {
      final encodedMap = map.map(
        (key, value) => MapEntry(key.toIso8601String(), value),
      );
      final jsonString = json.encode(encodedMap);
      await _prefs?.setString(_kProgrammesMapKey, jsonString);
    }
  }

  Map<DateTime, List<String>> _loadProgrammesMap() {
    final jsonString = _prefs?.getString(_kProgrammesMapKey);
    if (jsonString == null) return {};

    try {
      final decodedMap = json.decode(jsonString) as Map<String, dynamic>;
      return decodedMap.map(
        (key, value) =>
            MapEntry(DateTime.parse(key), (value as List).cast<String>()),
      );
    } catch (e) {
      print("Error loading cached programmes map: $e");
      return {};
    }
  }

  // Save the full list of Google Programmes
  Future<void> _saveGoogleProgrammesCache(List<Programme> programmes) async {
    if (mounted) {
      try {
        final List<Map<String, dynamic>> jsonList = programmes
            .map((p) => p.toJson())
            .toList();
        final jsonString = json.encode(jsonList);
        await _prefs?.setString(_kGoogleProgrammesCacheKey, jsonString);
      } catch (e) {
        print('>>> CACHE: Error saving Google programmes to cache: $e');
      }
    }
  }

  // Load the full list of Google Programmes
  List<Programme> _loadGoogleProgrammesCache() {
    final jsonString = _prefs?.getString(_kGoogleProgrammesCacheKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList
          .map((json) => Programme.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(">>> CACHE: Error loading cached Google programmes: $e");
      return [];
    }
  }

  // ----------------------------------------------------------------------
  // 🌐 CORRECTED: GOOGLE CALENDAR LOGIC (WITH THROTTLE AND CACHE)
  // ----------------------------------------------------------------------

  Future<List<Programme>> _fetchAndParseGoogleCalendarEvents() async {
    // --- 1. THROTTLE CHECK (Performance Optimization) ---
    if (_lastGoogleFetchTime != null &&
        DateTime.now().difference(_lastGoogleFetchTime!) <
            _fetchThrottleDuration) {
      print(
        '>>> ICS DEBUG: ⏱️ Throttle active. Returning cached data immediately.',
      );
      return _loadGoogleProgrammesCache();
    }

    // --- 2. NETWORK FETCH ---
    try {
      print('>>> ICS DEBUG: Attempting to fetch Google Calendar ICS...');
      final response = await http.get(Uri.parse(_kGoogleCalendarIcsUrl));

      if (response.statusCode == 200) {
        print('>>> ICS DEBUG: ✅ ICS fetch successful. Parsing...');

        final liveEvents = _parseIcsContent(response.body);

        // 💾 SUCCESS: SAVE TO CACHE AND UPDATE TIMESTAMP
        await _saveGoogleProgrammesCache(liveEvents);
        _lastGoogleFetchTime =
            DateTime.now(); // Record the successful fetch time

        return liveEvents;
      } else {
        print(
          '>>> ICS DEBUG: ❌ Failed to load Google Calendar ICS. Status Code: ${response.statusCode}',
        );

        // 🔍 CACHE FALLBACK: Load from cache on network failure
        final cachedEvents = _loadGoogleProgrammesCache();
        print(
          '>>> ICS DEBUG: 🔄 Falling back to cache. Found ${cachedEvents.length} events.',
        );
        return cachedEvents;
      }
    } catch (e) {
      print(
        '>>> ICS DEBUG: 🚨 Error fetching Google Calendar (Network/Parser Error): $e',
      );

      // 🔍 CACHE FALLBACK: Load from cache on exception
      final cachedEvents = _loadGoogleProgrammesCache();
      print(
        '>>> ICS DEBUG: 🔄 Falling back to cache. Found ${cachedEvents.length} events.',
      );
      return cachedEvents;
    }
  }

  // ----------------------------------------------------------------------
  // 🛠️ CORRECTED: ICS DATE PARSER (Fixes FormatException)
  // ----------------------------------------------------------------------
  DateTime? _parseIcsDateTime(String line) {
    try {
      String rawValue = line.substring(line.lastIndexOf(':') + 1).trim();
      String cleanValue = rawValue.replaceAll(RegExp(r'[^\dTZ]'), '');

      // Case 1: All-day event (Format: YYYYMMDD)
      if (line.contains('VALUE=DATE') && cleanValue.length == 8) {
        // Manual formatting to YYYY-MM-DD for native parsing
        return DateTime.parse(
          '${cleanValue.substring(0, 4)}-${cleanValue.substring(4, 6)}-${cleanValue.substring(6, 8)}',
        );
      }

      // Case 2 & 3: Date-Time event (Format: YYYYMMDDTHHMMSS[Z])
      if (cleanValue.contains('T') && cleanValue.length >= 15) {
        // 2. Convert ICS YYYYMMDDTHHMMSS into ISO 8601 YYYY-MM-DDTHH:MM:SS
        String isoValue =
            '${cleanValue.substring(0, 4)}-${cleanValue.substring(4, 6)}-${cleanValue.substring(6, 8)}'
            'T${cleanValue.substring(9, 11)}:${cleanValue.substring(11, 13)}:${cleanValue.substring(13, 15)}';

        // 3. Handle UTC ('Z') vs Local Time
        if (cleanValue.endsWith('Z')) {
          // UTC time: Append 'Z' and parse, then convert to local time zone
          return DateTime.parse(isoValue + 'Z').toLocal();
        } else {
          // Local time (Non-UTC): Parse directly, treating it as the device's local time zone
          return DateTime.parse(isoValue);
        }
      }

      return null;
    } catch (e) {
      print('>>> ICS DEBUG: 🚨 Date parse error for line: $line. Error: $e');
      return null;
    }
  }

  // Simplified ICS Parser - Unchanged
  List<Programme> _parseIcsContent(String icsContent) {
    final List<Programme> events = [];
    final lines = icsContent.split('\n');

    String? currentSummary;
    DateTime? currentStart;
    DateTime? currentEnd;
    String? currentUid;
    bool isDateOnly = false;

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('BEGIN:VEVENT')) {
        currentSummary = null;
        currentStart = null;
        currentEnd = null;
        currentUid = null;
        isDateOnly = false;
      } else if (trimmedLine.startsWith('SUMMARY:')) {
        currentSummary = trimmedLine.substring('SUMMARY:'.length).trim();
      } else if (trimmedLine.startsWith('DTSTART')) {
        currentStart = _parseIcsDateTime(trimmedLine);
        if (trimmedLine.contains('VALUE=DATE')) {
          isDateOnly = true;
        }
      } else if (trimmedLine.startsWith('DTEND')) {
        currentEnd = _parseIcsDateTime(trimmedLine);
      } else if (trimmedLine.startsWith('UID:')) {
        currentUid = trimmedLine.substring('UID:'.length).trim();
      } else if (trimmedLine.startsWith('END:VEVENT')) {
        if (currentSummary != null && currentStart != null) {
          DateTime? finalEnd = currentEnd;

          if (isDateOnly) {
            if (finalEnd != null && finalEnd.isAfter(currentStart)) {
              finalEnd = finalEnd.subtract(const Duration(days: 1));
            } else if (finalEnd == null) {
              finalEnd = currentStart;
            }
          }

          if (finalEnd != null && finalEnd.isBefore(currentStart)) {
            finalEnd = currentStart;
          }

          events.add(
            Programme(
              id: currentUid ?? 'gc-${UniqueKey().toString()}',
              title: currentSummary!,
              start: currentStart!,
              end: finalEnd,
              isFromGoogleCalendar: true,
              visible: true,
            ),
          );
        }
      }
    }
    print(
      '>>> ICS DEBUG: Successfully parsed ${events.length} Google Calendar events.',
    );
    return events;
  }

  // ----------------------------------------------------------------------
  // 🔄 FIREBASE STREAM - Unchanged
  // ----------------------------------------------------------------------
  Stream<QuerySnapshot> _allProgrammesStream() {
    return FirebaseFirestore.instance
        .collection('programmes')
        .where('visible', isEqualTo: true)
        .where(
          'end',
          isGreaterThanOrEqualTo: DateTime.now().subtract(
            const Duration(days: 30),
          ),
        )
        .orderBy('end')
        .snapshots();
  }

  // ----------------------------------------------------------------------
  // 🛠️ HANDLER FOR STREAM DATA - Unchanged logic, relies on throttled fetch
  // ----------------------------------------------------------------------

  void _handleProgrammeData(List<Programme> firestoreProgrammes) async {
    if (!mounted) return;

    // 1. Fetch Google Calendar Events (Network, Throttle, or Cache)
    final googleProgrammes = await _fetchAndParseGoogleCalendarEvents();

    // 2. Merge and sort all programmes
    final allProgrammes = [...firestoreProgrammes, ...googleProgrammes];
    allProgrammes.sort((a, b) => a.start.compareTo(b.start));

    // 3. Build the map for the calendar markers
    _buildProgrammeMap(allProgrammes, shouldSetState: true);

    // 4. Update the combined list state
    if (!listEquals(_combinedProgrammes, allProgrammes)) {
      setState(() {
        _combinedProgrammes = allProgrammes;
      });
    }

    // 5. Save the updated map (cache for markers).
    _saveProgrammesMap(_programmesByDate);
  }

  // Helper functions... (mapEquals, listEquals, etc. are retained as-is)
  bool listEquals(List<Programme> a, List<Programme> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].isFromGoogleCalendar != b[i].isFromGoogleCalendar) {
        return false;
      }
    }
    return true;
  }

  void _buildProgrammeMap(
    List<Programme> allProgrammes, {
    bool shouldSetState = true,
  }) {
    final Map<DateTime, List<String>> grouped = {};
    for (final programme in allProgrammes) {
      final start = programme.start;
      final end = programme.end ?? start;

      final startDay = DateTime(start.year, start.month, start.day);
      final lastActiveDay = DateTime(end.year, end.month, end.day);
      final exclusiveEndDay = lastActiveDay.add(const Duration(days: 1));

      DateTime current = startDay;

      while (current.isBefore(exclusiveEndDay)) {
        final normalizedDate = DateTime(
          current.year,
          current.month,
          current.day,
        );
        grouped.putIfAbsent(normalizedDate, () => []);
        grouped[normalizedDate]!.add(programme.title);
        current = current.add(const Duration(days: 1));
      }
    }

    if (shouldSetState && !mapEquals(grouped, _programmesByDate)) {
      setState(() {
        _programmesByDate = grouped;
      });
    } else if (!shouldSetState) {
      _programmesByDate = grouped;
    }
  }

  bool mapEquals(Map<DateTime, List<String>> a, Map<DateTime, List<String>> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) ||
          a[key]!.length != b[key]!.length ||
          a[key].toString() != b[key].toString()) {
        return false;
      }
    }
    return true;
  }

  // ----------------------------------------------------------------------
  // 🖼️ WIDGET BUILDER AND OTHER UI METHODS - Unchanged
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!mounted || _prefs == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('School Programmes'),
          centerTitle: true,
          elevation: 2,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.exbackground,
      body: StreamBuilder<QuerySnapshot>(
        stream: _allProgrammesStream(),
        builder: (context, snapshot) {
          // Robust Loading Check: Wait only if NO cached data is available
          if (snapshot.connectionState == ConnectionState.waiting &&
              _programmesByDate.isEmpty &&
              _combinedProgrammes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading programmes: ${snapshot.error}'),
            );
          }

          List<Programme> firestoreProgrammes = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            firestoreProgrammes = snapshot.data!.docs
                .map((doc) => Programme.fromFirestore(doc))
                .toList();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleProgrammeData(firestoreProgrammes);
            });
          } else {
            if (snapshot.connectionState != ConnectionState.waiting) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleProgrammeData([]);
              });
            }
          }

          return CustomScrollView(
            slivers: [
              // SliverAppBar.medium... (UI code)
              SliverAppBar.medium(
                backgroundColor: AppColors.exblue,
                foregroundColor: Colors.white,
                title: const Text('School Calendar'),
                centerTitle: true,
                floating: true,
                snap: true,
                pinned: false,
                surfaceTintColor: Colors.transparent,
                elevation: 6.0,
                scrolledUnderElevation: 6.0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
              ),

              SliverToBoxAdapter(child: _buildCalendar()),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSelectedDateHeader(),
                    const Divider(height: 1, color: Colors.black12),
                  ],
                ),
              ),

              _buildProgrammeListSliver(_combinedProgrammes),
            ],
          );
        },
      ),
    );
  }

  // _buildCalendar() { ... }
  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TableCalendar(
        firstDay: DateTime.utc(DateTime.now().year - 1),
        lastDay: DateTime.utc(DateTime.now().year + 1),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        calendarFormat: _calendarFormat,
        onDaySelected: (selected, focused) {
          if (!isSameDay(_selectedDay, selected)) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
            _saveSelectedDay(selected);
          }
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.indigoAccent.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          weekendTextStyle: const TextStyle(color: Colors.redAccent),
        ),
        calendarBuilders: CalendarBuilders(
          todayBuilder: (context, date, focusedDay) {
            final normalizedDate = DateTime(date.year, date.month, date.day);
            final hasProgrammes =
                (_programmesByDate[normalizedDate] ?? []).isNotEmpty;

            if (hasProgrammes) {
              return Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade200,
                    border: Border.all(
                      color: Colors.orange.shade300,
                      width: 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
            return null;
          },

          markerBuilder: (context, date, events) {
            final normalizedDate = DateTime(date.year, date.month, date.day);
            final programmes = _programmesByDate[normalizedDate] ?? [];

            if (programmes.isEmpty) return const SizedBox.shrink();

            final List<Widget> labels = [];
            for (
              var i = 0;
              i < (programmes.length > 2 ? 2 : programmes.length);
              i++
            ) {
              final shortTitle = programmes[i].length > 8
                  ? '${programmes[i].substring(0, 8)}…'
                  : programmes[i];

              labels.add(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.indigoAccent.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    shortTitle,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (programmes.length > 2) {
              labels.add(
                Text(
                  '+${programmes.length - 2} more',
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
              );
            }

            return Positioned(
              bottom: 2,
              child: Column(mainAxisSize: MainAxisSize.min, children: labels),
            );
          },
        ),
      ),
    );
  }

  // _buildSelectedDateHeader() { ... }
  Widget _buildSelectedDateHeader() {
    final selected = _selectedDay;
    final dateText = DateFormat('EEEE, d MMMM yyyy').format(selected);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        dateText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.indigo,
        ),
      ),
    );
  }

  // _buildProgrammeListSliver() { ... }
  Widget _buildProgrammeListSliver(List<Programme> allProgrammes) {
    final selected = _selectedDay;
    final startOfDay = DateTime(selected.year, selected.month, selected.day);
    final endOfDayExclusive = startOfDay.add(const Duration(days: 1));

    final programmesForDay = allProgrammes.where((p) {
      final programmeEndInclusive = p.end ?? p.start;

      final startsBeforeEndOfSelectedDay = p.start.isBefore(endOfDayExclusive);
      final endsAfterStartOfSelectedDay =
          programmeEndInclusive.isAfter(startOfDay) ||
          isSameDay(programmeEndInclusive, startOfDay);

      return startsBeforeEndOfSelectedDay && endsAfterStartOfSelectedDay;
    }).toList();

    if (programmesForDay.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No programmes on this day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    programmesForDay.sort((a, b) => a.start.compareTo(b.start));

    return SliverList.builder(
      itemCount: programmesForDay.length,
      itemBuilder: (context, index) {
        final programme = programmesForDay[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: ProgrammeCard(
            key: ValueKey('${programme.id}-${programme.isFromGoogleCalendar}'),
            programme: programme,
            selectedDay: selected,
          ),
        );
      },
    );
  }
}
