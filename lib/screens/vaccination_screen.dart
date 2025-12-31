import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/vaccination_model.dart';
import 'package:purfect_care/providers/vaccination_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';
import 'add_vaccination_screen.dart';

class VaccinationScreen extends StatefulWidget {
  final PetModel pet;

  const VaccinationScreen({super.key, required this.pet});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  bool _hasLoaded = false; // Guard to prevent multiple loads

  @override
  void initState() {
    super.initState();
    // Load vaccinations when screen opens - only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded && mounted && widget.pet.id != null) {
        _hasLoaded = true;
        final vaccinationProvider = context.read<VaccinationProvider>();
        // The provider will check if already loaded or loading
        vaccinationProvider.loadVaccinations(widget.pet.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vaccinationProvider = context.watch<VaccinationProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vaccinations = vaccinationProvider.getVaccinations(widget.pet.id!);
    
    // Separate overdue and upcoming vaccinations
    final now = DateTime.now();
    final overdue = vaccinations.where((v) => 
      v.nextDueDate != null && v.nextDueDate!.isBefore(now)
    ).toList();
    final upcoming = vaccinations.where((v) => 
      v.nextDueDate != null && v.nextDueDate!.isAfter(now)
    ).toList();
    final past = vaccinations.where((v) => 
      v.nextDueDate == null || (v.nextDueDate!.isBefore(now) && v.dateGiven.isBefore(now))
    ).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.accentOrange,
        elevation: 0,
        title: const Text(
          'Vaccinations',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: vaccinationProvider.isLoading && vaccinations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : vaccinations.isEmpty
              ? _buildEmptyState(context, theme, isDark)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Overdue Section
                    if (overdue.isNotEmpty) ...[
                      _buildSectionHeader('Overdue', Colors.red, theme),
                      const SizedBox(height: 8),
                      ...overdue.map((v) => _buildVaccinationCard(v, theme, isDark, true)),
                      const SizedBox(height: 24),
                    ],
                    // Upcoming Section
                    if (upcoming.isNotEmpty) ...[
                      _buildSectionHeader('Upcoming', Colors.orange, theme),
                      const SizedBox(height: 8),
                      ...upcoming.map((v) => _buildVaccinationCard(v, theme, isDark, false)),
                      const SizedBox(height: 24),
                    ],
                    // Past Vaccinations
                    if (past.isNotEmpty) ...[
                      _buildSectionHeader('Past Vaccinations', theme.colorScheme.onSurfaceVariant, theme),
                      const SizedBox(height: 8),
                      ...past.map((v) => _buildVaccinationCard(v, theme, isDark, false)),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddVaccinationScreen(pet: widget.pet),
            ),
          );
        },
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
              Icons.medical_services_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No vaccinations recorded yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking ${widget.pet.name}\'s vaccinations',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddVaccinationScreen(pet: widget.pet),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Vaccination',
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

  Widget _buildSectionHeader(String title, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationCard(VaccinationModel vaccination, ThemeData theme, bool isDark, bool isOverdue) {
    final now = DateTime.now();
    final isUpcoming = vaccination.nextDueDate != null && vaccination.nextDueDate!.isAfter(now);
    final daysUntil = vaccination.nextDueDate != null 
        ? vaccination.nextDueDate!.difference(now).inDays 
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue 
              ? Colors.red.withOpacity(0.5)
              : isDark ? theme.colorScheme.outline : Colors.grey[200]!,
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddVaccinationScreen(
                pet: widget.pet,
                vaccination: vaccination,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isOverdue ? Colors.red : isUpcoming ? Colors.orange : Colors.blue)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: isOverdue ? Colors.red : isUpcoming ? Colors.orange : Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination.vaccineName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Given: ${DateFormat('MMM dd, yyyy').format(vaccination.dateGiven)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Overdue',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else if (isUpcoming && daysUntil != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        daysUntil == 0 ? 'Due today' : daysUntil == 1 ? 'Due tomorrow' : 'Due in $daysUntil days',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
              if (vaccination.nextDueDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Next due: ${DateFormat('MMM dd, yyyy').format(vaccination.nextDueDate!)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (vaccination.vetName != null && vaccination.vetName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_hospital, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      vaccination.vetName!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  vaccination.notes!,
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
        ),
      ),
    );
  }
}

