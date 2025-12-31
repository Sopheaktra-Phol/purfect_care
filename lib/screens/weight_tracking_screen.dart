import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/weight_entry_model.dart';
import 'package:purfect_care/providers/weight_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';

class WeightTrackingScreen extends StatefulWidget {
  final PetModel pet;

  const WeightTrackingScreen({super.key, required this.pet});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Load weight entries when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeightProvider>().loadWeightEntries(widget.pet.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final weightProvider = context.watch<WeightProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weightEntries = weightProvider.getWeightEntries(widget.pet.id!);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'Weight Tracking',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: weightProvider.isLoading && weightEntries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : weightEntries.isEmpty
              ? _buildEmptyState(context, theme, isDark)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildChart(weightEntries, theme, isDark),
                    const SizedBox(height: 24),
                    _buildWeightList(weightEntries, theme, isDark),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(context),
        backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
        foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No weight entries yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking ${widget.pet.name}\'s weight',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddWeightDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Weight Entry',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<WeightEntryModel> entries, ThemeData theme, bool isDark) {
    if (entries.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Add at least 2 entries to see the chart',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Sort entries by date ascending for chart
    final sortedEntries = List<WeightEntryModel>.from(entries)..sort((a, b) => a.date.compareTo(b.date));
    
    // Calculate min and max weight for chart
    final weights = sortedEntries.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;
    final chartMin = (minWeight - range * 0.1).clamp(0, double.infinity);
    final chartMax = maxWeight + range * 0.1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Trend',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (chartMax - chartMin) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? theme.colorScheme.outline.withOpacity(0.2) : Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: sortedEntries.length > 5 ? (sortedEntries.length / 5).ceil().toDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= sortedEntries.length) return const Text('');
                        final entry = sortedEntries[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MM/dd').format(entry.date),
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: (chartMax - chartMin) / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (sortedEntries.length - 1).toDouble(),
                minY: chartMin.toDouble(),
                maxY: chartMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: sortedEntries.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.weight);
                    }).toList(),
                    isCurved: true,
                    color: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (isDark ? theme.colorScheme.primary : AppTheme.accentOrange).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightList(List<WeightEntryModel> entries, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight History',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...entries.map((entry) => _buildWeightEntryCard(entry, theme, isDark)),
      ],
    );
  }

  Widget _buildWeightEntryCard(WeightEntryModel entry, ThemeData theme, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isDark ? theme.colorScheme.primary : AppTheme.accentOrange).withOpacity(0.2),
          child: Icon(
            Icons.monitor_weight,
            color: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
          ),
        ),
        title: Text(
          '${entry.weight.toStringAsFixed(1)} ${_getWeightUnit()}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(entry.date),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.notes!,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(
            Icons.more_vert,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () {
                Future.delayed(const Duration(milliseconds: 100), () {
                  _showAddWeightDialog(context, entry: entry);
                });
              },
            ),
            PopupMenuItem(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Weight Entry'),
                    content: const Text('Are you sure you want to delete this weight entry?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await context.read<WeightProvider>().deleteWeightEntry(widget.pet.id!, entry.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getWeightUnit() {
    // You can make this configurable later
    return 'lbs';
  }

  void _showAddWeightDialog(BuildContext context, {WeightEntryModel? entry}) {
    final formKey = GlobalKey<FormState>();
    final weightController = TextEditingController(
      text: entry?.weight.toStringAsFixed(1) ?? '',
    );
    final notesController = TextEditingController(
      text: entry?.notes ?? '',
    );
    DateTime selectedDate = entry?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(
              entry == null ? 'Add Weight Entry' : 'Edit Weight Entry',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        hintText: 'Enter weight',
                        suffixText: 'lbs',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Please enter a valid weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Add any notes',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  
                  final weight = double.parse(weightController.text);
                  final notes = notesController.text.trim().isEmpty ? null : notesController.text.trim();
                  
                  final weightEntry = WeightEntryModel(
                    id: entry?.id,
                    petId: widget.pet.id!,
                    weight: weight,
                    date: selectedDate,
                    notes: notes,
                  );
                  
                  final provider = context.read<WeightProvider>();
                  if (entry == null) {
                    await provider.addWeightEntry(weightEntry);
                  } else {
                    await provider.updateWeightEntry(widget.pet.id!, entry.id!, weightEntry);
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                  foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                ),
                child: Text(entry == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        );
      },
    );
  }
}

