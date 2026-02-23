import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// History page inspired by your design.
///
/// Uses static sample data for:
/// - Heart rate trend
/// - Blood pressure trend
/// - Oxygen saturation trend
/// - Today’s activity timeline
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              avgLabel: '75 bpm',
              minLabel: '65 bpm',
              maxLabel: '110 bpm',
              lineColor: Colors.pink,
            ),
            const SizedBox(height: 16),
            _TrendCard(
              title: 'Blood Pressure Trend',
              avgLabel: '120/80',
              minLabel: '110/70',
              maxLabel: '135/90',
              lineColor: Colors.indigo,
            ),
            const SizedBox(height: 16),
            _TrendCard(
              title: 'Oxygen Saturation',
              avgLabel: '97%',
              minLabel: '92%',
              maxLabel: '99%',
              lineColor: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              "Today's Activity",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _ActivityItem(
              time: '8:00 PM',
              title: 'Daily Check Complete',
              description: 'All vitals normal',
              color: Colors.green,
            ),
            _ActivityItem(
              time: '6:00 PM',
              title: 'SpO₂ Dropped',
              description: '92% – Recovered quickly',
              color: Colors.orange,
            ),
            _ActivityItem(
              time: '2:30 PM',
              title: 'Heart Rate Spike',
              description: '130 bpm – Light activity',
              color: Colors.red,
            ),
            _ActivityItem(
              time: '12:00 PM',
              title: 'Medication Taken',
              description: 'Manual entry confirmed',
              color: Colors.blue,
            ),
            _ActivityItem(
              time: '10:00 AM',
              title: 'Morning Walk',
              description: '15 min, avg HR 85 bpm',
              color: Colors.blueGrey,
            ),
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

  const _TrendCard({
    required this.title,
    required this.avgLabel,
    required this.minLabel,
    required this.maxLabel,
    required this.lineColor,
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
                  'Day',
                  style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                        final i = value.toInt();
                        if (i >= 0 && i < labels.length) {
                          return Text(labels[i], style: const TextStyle(fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 70),
                      FlSpot(1, 75),
                      FlSpot(2, 90),
                      FlSpot(3, 80),
                      FlSpot(4, 85),
                      FlSpot(5, 78),
                      FlSpot(6, 82),
                    ],
                    color: lineColor,
                    barWidth: 3,
                    isCurved: true,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
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

class _ActivityItem extends StatelessWidget {
  final String time;
  final String title;
  final String description;
  final Color color;

  const _ActivityItem({
    required this.time,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4, right: 8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
