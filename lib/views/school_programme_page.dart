import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/models/programmes.dart';
import 'package:grace_by/widgets/programme_card.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SchoolProgrammesPage extends StatefulWidget {
  const SchoolProgrammesPage({super.key});

  @override
  State<SchoolProgrammesPage> createState() => _SchoolProgrammesPageState();
}

class _SchoolProgrammesPageState extends State<SchoolProgrammesPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  late SharedPreferences _prefs;
  Map<DateTime, List<String>> _programmesByDate = {}; // Cached/Live markers

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay = DateTime.now();
    _initializePreferencesAndCache();
  }

  // ----------------------------------------------------------------------
  // 💾 PREFERENCES & CACHE SETUP (Same as before)
  // ----------------------------------------------------------------------
  Future<void> _initializePreferencesAndCache() async {
    _prefs = await SharedPreferences.getInstance();

    final savedDayString = _prefs.getString(_kSelectedDayKey);
    if (savedDayString != null) {
      try {
        _selectedDay = DateTime.parse(savedDayString);
        _focusedDay = _selectedDay;
      } catch (e) {
        // Fallback to today
      }
    }

    final cachedMap = _loadProgrammesMap();
    if (cachedMap.isNotEmpty) {
      setState(() {
        _programmesByDate = cachedMap;
      });
    }

    setState(() {});
  }

  Future<void> _saveSelectedDay(DateTime day) async {
    if (mounted) {
      await _prefs.setString(_kSelectedDayKey, day.toIso8601String());
    }
  }

  Future<void> _saveProgrammesMap(Map<DateTime, List<String>> map) async {
    if (mounted) {
      final encodedMap = map.map(
        (key, value) => MapEntry(key.toIso8601String(), value),
      );
      final jsonString = json.encode(encodedMap);
      await _prefs.setString(_kProgrammesMapKey, jsonString);
    }
  }

  Map<DateTime, List<String>> _loadProgrammesMap() {
    final jsonString = _prefs.getString(_kProgrammesMapKey);
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

  // ----------------------------------------------------------------------
  // 🔄 FIREBASE STREAM (Single Source of Truth)
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

  @override
  Widget build(BuildContext context) {
    if (!mounted || !(_prefs is SharedPreferences)) {
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
      // NOTE: appBar is now null because SliverAppBar is used in the body
      body: StreamBuilder<QuerySnapshot>(
        stream: _allProgrammesStream(),
        builder: (context, snapshot) {
          // Loading and Error Handling (Uses local cache during waiting)
          if (snapshot.connectionState == ConnectionState.waiting &&
              _programmesByDate.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading programmes: ${snapshot.error}'),
            );
          }

          List<Programme> allProgrammes = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            allProgrammes = snapshot.data!.docs
                .map((doc) => Programme.fromFirestore(doc))
                .toList();

            // Build and Cache the new marker map (Seamless Update)
            _buildProgrammeMap(allProgrammes);
            _saveProgrammesMap(_programmesByDate);
          }

          // 3. Build the UI using CustomScrollView and Slivers
          return CustomScrollView(
            slivers: [
              // 🟢 MEDIUM SliverAppBar
              SliverAppBar.medium(
                backgroundColor: AppColors.exblue,
                foregroundColor: Colors.white,
                title: const Text('school calender'),
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

              // 2. Calendar (Wrapped in SliverToBoxAdapter)
              SliverToBoxAdapter(child: _buildCalendar()),

              // 3. Selected Date Header (Wrapped in SliverToBoxAdapter)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSelectedDateHeader(),
                    const Divider(height: 1, color: Colors.black12),
                  ],
                ),
              ),

              // 4. Programme List (Now a SliverList)
              _buildProgrammeListSliver(allProgrammes),
            ],
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 🛠️ MAP BUILDER & EQUALITY (Same as before)
  // ----------------------------------------------------------------------

  void _buildProgrammeMap(List<Programme> allProgrammes) {
    final Map<DateTime, List<String>> grouped = {};
    for (final programme in allProgrammes) {
      final start = programme.start;
      final end = programme.end ?? start;
      DateTime current = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      while (!current.isAfter(endDate)) {
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
    if (!mapEquals(grouped, _programmesByDate)) {
      setState(() {
        _programmesByDate = grouped;
      });
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
  // 📅 CALENDAR WIDGET (Same as before)
  // ----------------------------------------------------------------------

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TableCalendar(
        // ... (Calendar properties and styles remain the same)
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
          // Today Builder (Same as before)
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

          // Marker Builder (Same as before)
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

  // ----------------------------------------------------------------------
  // 💡 SELECTED DATE HEADER (Same as before)
  // ----------------------------------------------------------------------

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

  // ----------------------------------------------------------------------
  // 📝 PROGRAMME LIST (Now returns a SliverList)
  // ----------------------------------------------------------------------

  Widget _buildProgrammeListSliver(List<Programme> allProgrammes) {
    final selected = _selectedDay;
    final startOfDay = DateTime(selected.year, selected.month, selected.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final programmesForDay = allProgrammes.where((p) {
      final programmeEnd = p.end ?? p.start;
      return !(programmeEnd.isBefore(startOfDay) || p.start.isAfter(endOfDay));
    }).toList();

    if (programmesForDay.isEmpty) {
      // Return a SliverToBoxAdapter for the empty state message
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

    // Return a SliverList for the programme cards
    return SliverList.builder(
      itemCount: programmesForDay.length,
      itemBuilder: (context, index) {
        final programme = programmesForDay[index];
        // Note: We keep the AnimatedSwitcher, as it works inside a SliverList's itemBuilder
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: ProgrammeCard(
            key: ValueKey(programme.id),
            programme: programme,
            selectedDay: selected,
          ),
        );
      },
    );
  }
}
