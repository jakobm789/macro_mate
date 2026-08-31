import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({Key? key}) : super(key: key);

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final TextEditingController _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isAdding = false;
  int _selectedRangeInDays = 7;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  Future<void> _addWeight() async {
    final text = _weightController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte ein Gewicht eingeben.')),
      );
      return;
    }
    final weight = double.tryParse(text.replaceAll(',', '.'));
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte ein gültiges Gewicht eingeben.')),
      );
      return;
    }
    setState(() => _isAdding = true);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.addWeightEntry(_selectedDate, weight);
      _weightController.clear();
      setState(() => _selectedDate = DateTime.now());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _editWeight(WeightEntry entry) async {
    if (entry.id == null) return;
    final controller = TextEditingController(
      text: entry.weight.toStringAsFixed(1),
    );
    var selectedDate = entry.date;
    final result = await showDialog<({DateTime date, double weight})>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Gewicht bearbeiten'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Gewicht (kg)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 1),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Datum ändern'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () {
                    final weight = double.tryParse(
                      controller.text.trim().replaceAll(',', '.'),
                    );
                    if (weight == null || weight <= 0) return;
                    Navigator.of(
                      dialogContext,
                    ).pop((date: selectedDate, weight: weight));
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    if (result == null || !mounted) return;
    try {
      await Provider.of<AppState>(
        context,
        listen: false,
      ).updateWeightEntry(entry.id!, result.date, result.weight);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gewicht aktualisiert.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler beim Aktualisieren: $e')));
    }
  }

  Future<void> _deleteWeight(WeightEntry entry) async {
    if (entry.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gewicht löschen'),
        content: const Text('Möchtest du diesen Gewichtseintrag löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.deleteWeightEntry(entry.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Eintrag geloescht.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => appState.addWeightEntry(entry.date, entry.weight),
        ),
      ),
    );
  }

  List<WeightEntry> _getEntriesForRange() {
    final appState = Provider.of<AppState>(context, listen: false);
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: _selectedRangeInDays));
    final filtered = appState.weightEntries
        .where((entry) => entry.date.isAfter(cutoff))
        .toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  List<FlSpot> _generateSpotsForRange() {
    final filtered = _getEntriesForRange();
    if (filtered.isEmpty) {
      return [];
    }
    final baseDate = filtered.first.date;
    return filtered.map((entry) {
      final diff = entry.date.difference(baseDate).inDays.toDouble();
      return FlSpot(diff, entry.weight);
    }).toList();
  }

  Widget _rangeButton(String label, int days) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedRangeInDays = days;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedRangeInDays == days
            ? Colors.lightBlueAccent
            : Colors.white,
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spots = _generateSpotsForRange();
    final entries = _getEntriesForRange();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gewichtsentwicklung'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _rangeButton('1 Woche', 7),
                  _rangeButton('1 Monat', 30),
                  _rangeButton('3 Monate', 90),
                  _rangeButton('1 Jahr', 365),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (spots.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Keine Einträge für den ausgewählten Zeitraum.'),
                ),
              )
            else
              Expanded(
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toStringAsFixed(1)} kg',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          interval: spots.length > 1 ? null : 1,
                          getTitlesWidget: (value, meta) {
                            final entries = _getEntriesForRange();
                            if (entries.isEmpty) {
                              return const SizedBox();
                            }
                            final baseDate = entries.first.date;
                            final date = baseDate.add(
                              Duration(days: value.toInt()),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                DateFormat('dd.MM').format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Gewicht (kg)',
                        hintText: 'z.B. 80.5',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Datum: ${DateFormat('dd.MM.yyyy').format(_selectedDate)}',
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _pickDate,
                          child: const Text('Datum ändern'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isAdding ? null : _addWeight,
                      icon: _isAdding
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Speichern'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Dismissible(
                    key: ValueKey(
                      entry.id ??
                          '${entry.date.toIso8601String()}-${entry.weight}',
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      await _deleteWeight(entry);
                      return false;
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      title: Text('${entry.weight.toStringAsFixed(1)} kg'),
                      subtitle: Text(
                        DateFormat('dd.MM.yyyy').format(entry.date),
                      ),
                      onTap: () => _editWeight(entry),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editWeight(entry),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteWeight(entry),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
