import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:eldercareapp/core/providers/user_provider.dart';
import 'package:eldercareapp/services/firestore_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  String _errorMessage = '';

  // Chart Data
  List<FlSpot> _hrSpots = [];
  List<FlSpot> _bpSpots = []; 
  List<FlSpot> _spo2Spots = [];
  List<String> _timeLabels = []; 
  
  // 🚨 NEW: Stores the exact "120/80" string for the pop-up tooltips!
  Map<double, String> _bpTooltips = {};

  // Metrics
  int _hrMin = 0, _hrMax = 0, _hrAvg = 0;
  int _sysMin = 0, _sysMax = 0, _sysAvg = 0;
  int _diaMin = 0, _diaMax = 0, _diaAvg = 0;
  int _spo2Min = 0, _spo2Max = 0, _spo2Avg = 0;

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      if (userId == null) throw Exception("User not logged in");

      final linkedPatientId = await _firestoreService.getLinkedPatientId(userId);
      if (linkedPatientId == null) throw Exception("No linked patient found");

      DateTime now = DateTime.now();
      int daysToSubtract = now.weekday - 1; 
      DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
      int startOfWeekTimestamp = startOfWeek.millisecondsSinceEpoch;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(linkedPatientId)
          .collection('history')
          .where('timestamp', isGreaterThanOrEqualTo: startOfWeekTimestamp)
          .orderBy('timestamp', descending: true)
          .limit(2000) 
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      List<double> allHr = [];
      List<double> allSys = [];
      List<double> allDia = [];
      List<double> allSpo2 = [];

      Map<int, List<double>> hrByDay = {};
      Map<int, List<double>> sysByDay = {};
      Map<int, List<double>> diaByDay = {}; // 🚨 NEW: Tracking Diastolic per day
      Map<int, List<double>> spo2ByDay = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        int dayIndex = 0; 
        if (data['timestamp'] != null) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
          dayIndex = date.weekday - 1; 
        }

        if (data['heartRate'] != null && data['heartRate'] != '--') {
          double? hr = double.tryParse(data['heartRate'].toString());
          if (hr != null && hr > 0) {
            allHr.add(hr);
            hrByDay.putIfAbsent(dayIndex, () => []).add(hr);
          }
        }

        if (data['bloodPressure'] != null && data['bloodPressure'] != '--' && data['bloodPressure'].toString().contains('/')) {
          List<String> parts = data['bloodPressure'].toString().split('/');
          double? sys = double.tryParse(parts[0].trim());
          double? dia = double.tryParse(parts[1].trim());
          if (sys != null && dia != null) {
            allSys.add(sys);
            allDia.add(dia);
            sysByDay.putIfAbsent(dayIndex, () => []).add(sys);
            diaByDay.putIfAbsent(dayIndex, () => []).add(dia); // Track it!
          }
        }

        if (data['spo2'] != null && data['spo2'] != '--') {
          String cleanSpo2 = data['spo2'].toString().replaceAll('%', '').trim();
          double? spo2 = double.tryParse(cleanSpo2);
          if (spo2 != null && spo2 > 0) {
            allSpo2.add(spo2);
            spo2ByDay.putIfAbsent(dayIndex, () => []).add(spo2);
          }
        }
      }

      if (mounted) {
        setState(() {
          _hrSpots = hrByDay.entries.map((e) {
            double dayAvg = e.value.reduce((a, b) => a + b) / e.value.length;
            return FlSpot(e.key.toDouble(), dayAvg.roundToDouble()); 
          }).toList();

          // 🚨 FIX: Calculate BOTH Sys and Dia, and save the custom string to memory!
          _bpTooltips.clear();
          _bpSpots = sysByDay.entries.map((e) {
            double sysAvg = e.value.reduce((a, b) => a + b) / e.value.length;
            double diaAvg = diaByDay[e.key]!.reduce((a, b) => a + b) / diaByDay[e.key]!.length;
            
            // Save the exact fraction (e.g., "119/77") for the popup!
            _bpTooltips[e.key.toDouble()] = '${sysAvg.round()}/${diaAvg.round()}';
            
            return FlSpot(e.key.toDouble(), sysAvg.roundToDouble());
          }).toList();

          _spo2Spots = spo2ByDay.entries.map((e) {
            double dayAvg = e.value.reduce((a, b) => a + b) / e.value.length;
            return FlSpot(e.key.toDouble(), dayAvg.roundToDouble());
          }).toList();

          if (allHr.isNotEmpty) {
            _hrMin = allHr.reduce((a, b) => a < b ? a : b).round();
            _hrMax = allHr.reduce((a, b) => a > b ? a : b).round();
            _hrAvg = (allHr.reduce((a, b) => a + b) / allHr.length).round();
          }

          if (allSys.isNotEmpty && allDia.isNotEmpty) {
            _sysMin = allSys.reduce((a, b) => a < b ? a : b).round();
            _sysMax = allSys.reduce((a, b) => a > b ? a : b).round();
            _sysAvg = (allSys.reduce((a, b) => a + b) / allSys.length).round();
            
            _diaMin = allDia.reduce((a, b) => a < b ? a : b).round();
            _diaMax = allDia.reduce((a, b) => a > b ? a : b).round();
            _diaAvg = (allDia.reduce((a, b) => a + b) / allDia.length).round();
          }

          if (allSpo2.isNotEmpty) {
            _spo2Min = allSpo2.reduce((a, b) => a < b ? a : b).round();
            _spo2Max = allSpo2.reduce((a, b) => a > b ? a : b).round();
            _spo2Avg = (allSpo2.reduce((a, b) => a + b) / allSpo2.length).round();
          }

          _timeLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('History Page'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _fetchHistoryData();
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track health metrics over time',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _TrendCard(
                        title: 'Heart Rate Trend',
                        avgLabel: _hrSpots.isEmpty ? '--' : '$_hrAvg bpm',
                        minLabel: _hrSpots.isEmpty ? '--' : '$_hrMin bpm',
                        maxLabel: _hrSpots.isEmpty ? '--' : '$_hrMax bpm',
                        lineColor: Colors.pink,
                        spots: _hrSpots,
                        timeLabels: _timeLabels, 
                      ),
                      const SizedBox(height: 16),
                      
                      _TrendCard(
                        title: 'Blood Pressure Trend',
                        avgLabel: _bpSpots.isEmpty ? '--/--' : '$_sysAvg/$_diaAvg',
                        minLabel: _bpSpots.isEmpty ? '--/--' : '$_sysMin/$_diaMin',
                        maxLabel: _bpSpots.isEmpty ? '--/--' : '$_sysMax/$_diaMax',
                        lineColor: Colors.indigo,
                        spots: _bpSpots,
                        timeLabels: _timeLabels,
                        customTooltips: _bpTooltips, // 🚨 NEW: Pass the combined tooltips down!
                      ),
                      const SizedBox(height: 16),
                      
                      _TrendCard(
                        title: 'Oxygen Saturation',
                        avgLabel: _spo2Spots.isEmpty ? '--' : '$_spo2Avg%',
                        minLabel: _spo2Spots.isEmpty ? '--' : '$_spo2Min%',
                        maxLabel: _spo2Spots.isEmpty ? '--' : '$_spo2Max%',
                        lineColor: Colors.blue,
                        spots: _spo2Spots,
                        timeLabels: _timeLabels,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final String avgLabel;
  final String minLabel;
  final String maxLabel;
  final Color lineColor;
  final List<FlSpot> spots;
  final List<String> timeLabels;
  final Map<double, String>? customTooltips; // 🚨 NEW: Takes custom text for the pop-up

  const _TrendCard({
    required this.title,
    required this.avgLabel,
    required this.minLabel,
    required this.maxLabel,
    required this.lineColor,
    required this.spots,
    required this.timeLabels,
    this.customTooltips, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'This Week', 
                  style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 140,
            child: spots.isEmpty 
              ? const Center(child: Text("Waiting for first reading of the week...", style: TextStyle(color: Colors.grey)))
              : LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: 6,
                    
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            
                            // 🚨 FIX: Check if we have a custom tooltip for this spot!
                            String tooltipText = (customTooltips != null && customTooltips!.containsKey(spot.x))
                                ? customTooltips![spot.x]! // Shows "119/77"
                                : '${spot.y.toInt()}';     // Shows normal integer like "79"

                            return LineTooltipItem(
                              tooltipText, 
                              const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: 1, 
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i >= 0 && i < timeLabels.length) {
                              return SideTitleWidget(
                                meta: meta, 
                                space: 8.0,
                                child: Text(
                                  timeLabels[i],
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        color: lineColor,
                        barWidth: 3,
                        isCurved: true,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
          ),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AVERAGE', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(avgLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MIN', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(minLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MAX', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(maxLabel, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}