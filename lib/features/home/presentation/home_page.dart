import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldercareapp/core/providers/user_provider.dart';
import 'package:eldercareapp/features/account/presentation/account_page.dart';
import 'package:eldercareapp/features/alerts/presentation/alerts_page.dart';
import 'package:eldercareapp/features/home/data/health_metrics_repository.dart';
import 'package:eldercareapp/features/home/presentation/history_page.dart';
import 'package:eldercareapp/features/home/presentation/location_page.dart';
import 'package:eldercareapp/services/firestore_service.dart';
import 'package:eldercareapp/features/auth/presentation/qr_scanner_screen.dart';
import 'package:eldercareapp/features/calling/presentation/zegocloud_call_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _latestMetrics;
  List<Map<String, dynamic>> _weeklyMetrics = [];
  SmartwatchData? _smartwatchData;
  bool _isLoading = true;
  bool _isGuestUser = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HealthMetricsRepository _healthMetricsRepository = HealthMetricsRepository();
  final FirestoreService _firestoreService = FirestoreService();
  
  // Stream subscriptions & Timer
  StreamSubscription<String?>? _linkedPatientIdSubscription;
  StreamSubscription<SmartwatchData?>? _smartwatchDataSubscription;
  Timer? _statusTimer;

  // --- SWIPEABLE CHART VARIABLES ---
  final PageController _pageController = PageController();
  int _currentChartIndex = 0;
  List<FlSpot> _todayHrSpots = [];
  List<FlSpot> _todayBpSpots = [];
  Map<int, int> _todayBpDiastolic = {};

  @override
  void initState() {
    super.initState();
    _loadHealthData();
    _fetchTodayChartData(); // Fetch the 4-hour charts
    _setupRealtimeUpdates();

    // Ticks every 1 minute to refresh the UI and check if data is older than 5 mins
    _statusTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {}); 
        _fetchTodayChartData(); // Refresh chart averages every minute
      }
    });
  }

  Future<void> _loadHealthData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isGuestUser = true;
          _isLoading = false;
          _latestMetrics = null;
          _weeklyMetrics = [];
          _smartwatchData = null;
        });
      }
      return;
    }

    try {
      final latestMetric = await _healthMetricsRepository.getLatestMetric(userId);
      final weeklyMetrics = await _healthMetricsRepository.getWeeklyMetrics(userId);

      if (mounted) {
        setState(() {
          _isGuestUser = false;
          _latestMetrics = latestMetric;
          _weeklyMetrics = weeklyMetrics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading health data: $e')),
        );
      }
    }
  }

  // --- 4-HOUR BUCKET DATA FETCHER ---
  Future<void> _fetchTodayChartData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;
      if (userId == null) return;

      final linkedPatientId = await _firestoreService.getLinkedPatientId(userId);
      if (linkedPatientId == null) return;

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      int startOfDayTimestamp = startOfDay.millisecondsSinceEpoch;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(linkedPatientId)
          .collection('history')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDayTimestamp)
          .get();

      Map<int, List<double>> hrBuckets = {0: [], 1: [], 2: [], 3: [], 4: [], 5: []};
      Map<int, List<double>> sysBuckets = {0: [], 1: [], 2: [], 3: [], 4: [], 5: []};
      Map<int, List<double>> diaBuckets = {0: [], 1: [], 2: [], 3: [], 4: [], 5: []}; // 🚨 NEW

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['timestamp'] == null) continue;
        
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
        int bucketIndex = dt.hour ~/ 4; 

        if (data['heartRate'] != null && data['heartRate'] != '--') {
          double? hr = double.tryParse(data['heartRate'].toString());
          if (hr != null && hr > 0) hrBuckets[bucketIndex]!.add(hr);
        }

        if (data['bloodPressure'] != null && data['bloodPressure'].toString().contains('/')) {
          var bpParts = data['bloodPressure'].toString().split('/');
          double? sys = double.tryParse(bpParts[0].trim());
          double? dia = double.tryParse(bpParts[1].trim()); 
          
          if (sys != null) sysBuckets[bucketIndex]!.add(sys);
          if (dia != null) diaBuckets[bucketIndex]!.add(dia); 
        }
      }

      List<FlSpot> tempHrSpots = [];
      List<FlSpot> tempBpSpots = [];
      Map<int, int> tempDia = {};

      for (int i = 0; i < 6; i++) {
        if (hrBuckets[i]!.isNotEmpty) {
          double avg = hrBuckets[i]!.reduce((a, b) => a + b) / hrBuckets[i]!.length;
          tempHrSpots.add(FlSpot(i.toDouble(), avg.roundToDouble()));
        }
        if (sysBuckets[i]!.isNotEmpty) {
          double avgSys = sysBuckets[i]!.reduce((a, b) => a + b) / sysBuckets[i]!.length;
          tempBpSpots.add(FlSpot(i.toDouble(), avgSys.roundToDouble()));
          
          // Calculate the average Diastolic for the tooltip
          if (diaBuckets[i]!.isNotEmpty) {
            double avgDia = diaBuckets[i]!.reduce((a, b) => a + b) / diaBuckets[i]!.length;
            tempDia[i] = avgDia.round();
          }
        }
      }

      if (mounted) {
        setState(() {
          _todayHrSpots = tempHrSpots;
          _todayBpSpots = tempBpSpots;
          _todayBpDiastolic = tempDia;
        });
      }
    } catch (e) {
      print('Error fetching today charts: $e');
    }
  }

  /// Set up real-time listeners for smartwatch data
  void _setupRealtimeUpdates() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    if (userId == null) return;

    _linkedPatientIdSubscription = _firestoreService
        .streamLinkedPatientId(userId)
        .listen((linkedPatientId) {
      if (linkedPatientId != null) {
        _fetchTodayChartData(); // Fetch charts when link connects
        _smartwatchDataSubscription?.cancel();

        // Listen to the live document!
        _smartwatchDataSubscription = _firestoreService
            .streamSmartwatchData(linkedPatientId)
            .listen((smartwatchData) {
          if (mounted && smartwatchData != null) {
            setState(() {
              _smartwatchData = smartwatchData;
            });
          }
        }, onError: (error) {
          print('Error listening to smartwatch data: $error');
        });
      } else {
        _smartwatchDataSubscription?.cancel();
        if (mounted) {
          setState(() {
            _smartwatchData = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _linkedPatientIdSubscription?.cancel();
    _smartwatchDataSubscription?.cancel();
    _statusTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // --- THESIS LOGIC: 5 MINUTE TIMEOUT HELPERS ---
  bool _isDataLive() {
    if (_smartwatchData == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - _smartwatchData!.timestamp;
    return diff < const Duration(minutes: 5).inMilliseconds;
  }

  String _getStatusText() {
    if (_smartwatchData == null) return 'Waiting for data...';
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - _smartwatchData!.timestamp;
    final minutes = Duration(milliseconds: diff).inMinutes;

    if (minutes < 5) {
      return 'Live Sync Active';
    } else {
      return 'Offline ($minutes mins ago)';
    }
  }
  // ----------------------------------------------

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final pages = [
      _buildHomePage(userProvider), 
      const AlertsPage(),           
      const HistoryPage(),          
      const AccountPage(),          
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context, userProvider),
      bottomNavigationBar: _buildBottomNavBar(),
      body: pages[_selectedIndex],
      
      //  UI FIX 1: Pushes the Call Button to the side (bottom-right)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // Hidden on Alerts tab (index 1)
      floatingActionButton: _selectedIndex != 1 
          ? FloatingActionButton.extended(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final userId = userProvider.userId;
                
                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in')),
                  );
                  return;
                }
                
                try {
                  final linkedPatientId = await _firestoreService.getLinkedPatientId(userId);
                  
                  if (linkedPatientId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No linked patient found')),
                    );
                    return;
                  }

                  final watchUserId = await _firestoreService.getPatientUserId(linkedPatientId);
                  final calleeId = watchUserId ?? linkedPatientId;
                  final watchUserDoc = watchUserId != null
                      ? await _firestoreService.getUser(watchUserId)
                      : null;
                  final calleeName = (watchUserDoc?['displayName'] as String?) ?? 'Patient';

                  if (calleeId == userId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Smartwatch account is not linked correctly (callee is same as caller).'),
                      ),
                    );
                    return;
                  }
                  
                  if (mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ZegocloudCallScreen(
                          calleeId: calleeId,
                          calleeName: calleeName,
                          isVideoCall: false,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text('Call Patient', style: TextStyle(color: Colors.white)),
            )
          : null, // Makes it disappear on Alerts page
    );
  }

  Widget _buildDrawer(BuildContext context, UserProvider userProvider) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userProvider.userName ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userProvider.userEmail ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'User',
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 3);
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: 'History',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History coming soon')),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.devices,
              title: 'Devices',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Devices coming soon')),
                );
              },
            ),
            const Divider(height: 1),
            _buildDrawerItem(
              icon: Icons.help_outline,
              title: 'Get Help',
              hasSubmenu: true,
              children: [
                _buildSubMenuItem('Location', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LocationPage()),
                  );
                }),
                _buildSubMenuItem('Ambulance', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LocationPage(isAmbulance: true)),
                  );
                }),
                _buildSubMenuItem('Contact', () {
                  Navigator.pop(context);
                }),
                _buildSubMenuItem('Emergency Alert', () {
                  Navigator.pop(context);
                }),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.notifications_outlined,
              title: 'Notification',
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 1);
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.light_mode, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Light', style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  const Icon(Icons.dark_mode, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Dark', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool hasSubmenu = false,
    List<Widget>? children,
  }) {
    if (hasSubmenu && children != null) {
      return ExpansionTile(
        leading: Icon(icon, color: Colors.grey.shade700),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.expand_more),
        children: children,
      );
    }

    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSubMenuItem(String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13),
      ),
      onTap: onTap,
    );
  }

  Widget _buildHomePage(UserProvider userProvider) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HELLO, GOOD MORNING!',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userProvider.userName ?? 'John Doe',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ],
            ),
          ),

          // --- SWIPEABLE 4-HOUR CHART CONTAINER ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentChartIndex == 0 ? 'Today\'s Heart Rate' : 'Today\'s Blood Pressure',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: _currentChartIndex == 0 ? Colors.blue : Colors.blue.withValues(alpha: 0.3)),
                        const SizedBox(width: 4),
                        Icon(Icons.circle, size: 8, color: _currentChartIndex == 1 ? Colors.indigo : Colors.indigo.withValues(alpha: 0.3)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _isGuestUser
                          ? Center(
                              child: Text(
                                'Sign in to load health data',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                      : PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentChartIndex = index;
                            });
                          },
                          children: [
                            _buildSwipeableChart(isHeartRate: true),
                            _buildSwipeableChart(isHeartRate: false),
                          ],
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayLabel('12 AM'),
                    _buildDayLabel('4 AM'),
                    _buildDayLabel('8 AM'),
                    _buildDayLabel('12 PM'),
                    _buildDayLabel('4 PM'),
                    _buildDayLabel('8 PM'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Smartwatch Data Section
          if (_smartwatchData != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isDataLive() ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isDataLive() ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isDataLive() ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.watch,
                                color: _isDataLive() ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Smartwatch Data',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isDataLive() ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isDataLive() ? 'Live' : 'Offline',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        _buildSmartwatchMetric(
                          icon: Icons.favorite,
                          label: 'Heart Rate',
                          value: _smartwatchData!.heartRate,
                          unit: 'bpm',
                          color: Colors.red,
                        ),
                        _buildSmartwatchMetric(
                          icon: Icons.bloodtype,
                          label: 'Blood Pressure',
                          value: _smartwatchData!.bloodPressure,
                          unit: '',
                          color: Colors.indigo,
                        ),
                        _buildSmartwatchMetric(
                          icon: Icons.air,
                          label: 'SpO2 (Live)',
                          value: _smartwatchData!.spo2.replaceAll('%', ''),
                          unit: '%',
                          color: Colors.blue,
                        ),
                        _buildSmartwatchMetric(
                          icon: Icons.info_outline,
                          label: 'Status',
                          value: _smartwatchData!.bpStatus,
                          unit: '',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _smartwatchData!.fallDetected
                            ? Colors.red.shade100
                            : (_isDataLive() ? Colors.green.shade100 : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _smartwatchData!.fallDetected
                                ? Icons.warning
                                : Icons.check_circle,
                            color: _smartwatchData!.fallDetected
                                ? Colors.red
                                : (_isDataLive() ? Colors.green : Colors.grey),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _smartwatchData!.fallDetected
                                ? 'Fall Detected!'
                                : 'No Fall Detected',
                            style: TextStyle(
                              color: _smartwatchData!.fallDetected
                                  ? Colors.red
                                  : (_isDataLive() ? Colors.green : Colors.grey),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.watch,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'No Smartwatch Linked',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan the QR code from your smartwatch to start tracking health data.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QRCodeScannerScreen(),
                            ),
                          ).then((_) {
                            _loadHealthData();
                          });
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan Smartwatch QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Link/Rescan Smartwatch Button
          if (_smartwatchData != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QRCodeScannerScreen(),
                      ),
                    ).then((_) {
                      _loadHealthData();
                    });
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan New Smartwatch'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    
                    //  UI FIX 2: Bolder and thicker border to make it "perfect"
                    side: const BorderSide(color: Colors.green, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

 // --- SWIPEABLE CHART BUILDER ---
  Widget _buildSwipeableChart({required bool isHeartRate}) {
    List<FlSpot> spots = isHeartRate ? _todayHrSpots : _todayBpSpots;
    Color chartColor = isHeartRate ? Colors.pink : Colors.indigo;

    if (spots.isEmpty) {
      return const Center(child: Text('Waiting for data today...', style: TextStyle(color: Colors.grey)));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 5, 
        minY: 0, 
        maxY: isHeartRate ? 160 : 200, 
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchSpotThreshold: 40,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blueGrey.shade800, 
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                
                // THE FIX: Stitch the Diastolic value back on!
                String tooltipText = '${spot.y.toInt()}';
                
                if (!isHeartRate) {
                  int bucketIndex = spot.x.toInt();
                  int? dia = _todayBpDiastolic[bucketIndex]; // Look up the Diastolic from memory
                  if (dia != null) {
                    tooltipText = '${spot.y.toInt()}/$dia'; // Glue them together!
                  }
                }

                return LineTooltipItem(
                  tooltipText,
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: chartColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(radius: 4, color: chartColor, strokeWidth: 2, strokeColor: Colors.white);
              },
            ),
            belowBarData: BarAreaData(show: true, color: chartColor.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabel(String day) {
    return Text(
      day,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSmartwatchMetric({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty && value != 'NO API' && value != '--')
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
        ],
      ),
    );
  }
}