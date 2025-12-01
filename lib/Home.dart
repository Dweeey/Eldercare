import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'user_provider.dart';
import 'notification_page.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _latestMetrics;
  List<Map<String, dynamic>> _weeklyMetrics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userId == null) return;

    final db = DatabaseHelper.instance;
    final latest = await db.getLatestHealthMetric(userProvider.userId!);
    final weekly = await db.getHealthMetrics(userProvider.userId!, limit: 7);

    setState(() {
      _latestMetrics = latest;
      _weeklyMetrics = weekly;
      _isLoading = false;
    });
  }

  Future<void> _simulateHealthData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userId == null) return;

    final db = DatabaseHelper.instance;
    final now = DateTime.now();

    // Insert simulated health data for the past 7 days
    for (int i = 6; i >= 0; i--) {
      await db.insertHealthMetric({
        'user_id': userProvider.userId!,
        'heart_rate': 65 + (i * 5) + (i == 2 ? 15 : 0), // spike on Wednesday
        'blood_pressure_systolic': 120 + i,
        'blood_pressure_diastolic': 80 + i,
        'spo2_level': 95 + (i % 5),
        'recorded_at': now.subtract(Duration(days: i)).toIso8601String(),
      });
    }

    _loadHealthData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample health data generated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final pages = [
      _buildHomePage(userProvider),
      const NotificationsPage(),
      const AccountPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavBar(),
      body: pages[_selectedIndex],
    );
  }

  Widget _buildHomePage(UserProvider userProvider) {
    return SafeArea(
      child: Column(
        children: [
          // Greeting Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "HELLO, ${userProvider.userName?.toUpperCase() ?? 'USER'}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
              ],
            ),
          ),

          // Chart Section
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "HEART RATE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDateRange(),
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                    if (_weeklyMetrics.isEmpty)
                      TextButton.icon(
                        onPressed: _simulateHealthData,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Data', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildHeartRateChart(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Health Monitoring Section
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _buildHealthCard(
                          icon: Icons.favorite,
                          title: "HEART RATE",
                          value: _latestMetrics?['heart_rate']?.toString() ?? "--",
                          subtitle: "BPM",
                          color: Colors.red,
                        ),
                        _buildHealthCard(
                          icon: Icons.water_drop,
                          title: "SpO₂ LEVEL",
                          value: _latestMetrics?['spo2_level']?.toString() ?? "--",
                          subtitle: "%",
                          color: Colors.blue,
                        ),
                        _buildHealthCard(
                          icon: Icons.monitor_heart,
                          title: "BLOOD PRESSURE",
                          value: _latestMetrics != null
                              ? "${_latestMetrics!['blood_pressure_systolic']}/${_latestMetrics!['blood_pressure_diastolic']}"
                              : "--/--",
                          subtitle: "mmHg",
                          color: Colors.indigo,
                        ),
                        _buildHealthCard(
                          icon: Icons.warning,
                          title: "yeyp FALL DETECTED",
                          value: "NONE",
                          subtitle: "",
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateChart() {
    if (_weeklyMetrics.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Reverse to show oldest to newest (left to right)
    final reversedMetrics = _weeklyMetrics.reversed.toList();

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (value.toInt() >= 0 && value.toInt() < reversedMetrics.length) {
                  final date = DateTime.parse(reversedMetrics[value.toInt()]['recorded_at']);
                  final dayIndex = (date.weekday - 1) % 7;
                  return Text(days[dayIndex]);
                }
                return const Text('');
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < reversedMetrics.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (reversedMetrics[i]['heart_rate'] as int).toDouble() / 10,
                  color: Colors.blue,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getDateRange() {
    if (_weeklyMetrics.isEmpty) {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 6));
      return "${_formatDate(start)} - ${_formatDate(now)}";
    }

    final newest = DateTime.parse(_weeklyMetrics.first['recorded_at']);
    final oldest = DateTime.parse(_weeklyMetrics.last['recorded_at']);
    return "${_formatDate(oldest)} - ${_formatDate(newest)}";
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]}";
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}