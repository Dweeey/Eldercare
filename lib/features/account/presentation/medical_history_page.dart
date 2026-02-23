import 'package:flutter/material.dart';

/// Simple Medical History screen.
///
/// - Lets the user pick a time range (All / 7 days / 30 days / Custom)
/// - Shows a list of mock medical history entries
/// - Includes a "Generate PDF" button with a clear TODO where you can
///   integrate a real PDF library later (e.g., printing / pdf).
class MedicalHistoryPage extends StatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  String _range = 'All';
  DateTimeRange? _customRange;

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _customRange ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );
    if (picked != null) {
      setState(() {
        _range = 'Custom';
        _customRange = picked;
      });
    }
  }

  void _generatePdf() {
    // TODO: Integrate a real PDF generator (e.g., printing / pdf package).
    // This is where you would:
    // 1. Query real medical history data for the selected date range.
    // 2. Build a PDF document.
    // 3. Save/share/print it.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generate PDF (demo only). Add a PDF package to implement.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by date range',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildRangeChip('All'),
                    _buildRangeChip('7 days'),
                    _buildRangeChip('30 days'),
                    GestureDetector(
                      onTap: _pickCustomRange,
                      child: Chip(
                        label: Text(_customRange == null ? 'Custom' : 'Custom: ${_customRange!.start.month}/${_customRange!.start.day} - ${_customRange!.end.month}/${_customRange!.end.day}'),
                        backgroundColor: _range == 'Custom' ? Colors.blue.shade50 : Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generatePdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _HistoryEntry(
                  date: 'Nov 28, 2025',
                  title: 'Routine Checkup',
                  summary: 'Vitals within normal range. No issues reported.',
                ),
                _HistoryEntry(
                  date: 'Nov 24, 2025',
                  title: 'Hypertension Follow-up',
                  summary: 'Blood pressure slightly elevated. Medication adjusted.',
                ),
                _HistoryEntry(
                  date: 'Nov 15, 2025',
                  title: 'Oxygen Saturation Drop',
                  summary: 'Short episode of low SpO₂, recovered quickly.',
                ),
                _HistoryEntry(
                  date: 'Nov 1, 2025',
                  title: 'Medication Review',
                  summary: 'Confirmed adherence to daily medication plan.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(String label) {
    final selected = _range == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _range = label;
        });
      },
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  final String date;
  final String title;
  final String summary;

  const _HistoryEntry({
    required this.date,
    required this.title,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              summary,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
