import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/models/health_record_model.dart';
import 'package:purfect_care/models/vaccination_model.dart';
import 'package:purfect_care/models/milestone_model.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/providers/search_provider.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/providers/health_record_provider.dart';
import 'package:purfect_care/providers/vaccination_provider.dart';
import 'package:purfect_care/providers/milestone_provider.dart';
import 'package:purfect_care/providers/activity_provider.dart';
import 'package:purfect_care/providers/expense_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';
import 'package:purfect_care/screens/pet_detail_screen.dart';
import 'package:purfect_care/screens/add_reminder_screen.dart';
import 'package:purfect_care/screens/add_health_record_screen.dart';
import 'package:purfect_care/screens/add_vaccination_screen.dart';
import 'package:purfect_care/screens/add_milestone_screen.dart';
import 'package:purfect_care/screens/add_activity_screen.dart';
import 'package:purfect_care/screens/add_expense_screen.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<SearchResultType> _selectedFilters = {};
  List<SearchResult> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final searchProvider = SearchProvider(
      petProvider: context.read<PetProvider>(),
      reminderProvider: context.read<ReminderProvider>(),
      healthRecordProvider: context.read<HealthRecordProvider>(),
      vaccinationProvider: context.read<VaccinationProvider>(),
      milestoneProvider: context.read<MilestoneProvider>(),
      activityProvider: context.read<ActivityProvider>(),
      expenseProvider: context.read<ExpenseProvider>(),
    );

    final filterTypes = _selectedFilters.isEmpty ? null : _selectedFilters.toList();
    final results = searchProvider.search(query, filterTypes: filterTypes);

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.accentOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            return Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? theme.colorScheme.primary : const Color(0xFF2E7D8F),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? theme.colorScheme.primary : const Color(0xFF2E7D8F),
                    size: 22,
                  ),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _results = [];
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onChanged: (text) {
                  _performSearch(text);
                },
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [SizedBox(width: 8)], // Spacing for symmetry
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.scaffoldBackgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pets', SearchResultType.pet, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Reminders', SearchResultType.reminder, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Health', SearchResultType.health, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vaccinations', SearchResultType.vaccination, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Milestones', SearchResultType.milestone, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Activities', SearchResultType.activity, theme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Expenses', SearchResultType.expense, theme, isDark),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildResultsList(theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SearchResultType? type, ThemeData theme, bool isDark) {
    final isSelected = type == null
        ? _selectedFilters.isEmpty
        : _selectedFilters.contains(type);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (type == null) {
            _selectedFilters.clear();
          } else {
            if (selected) {
              _selectedFilters.add(type);
            } else {
              _selectedFilters.remove(type);
            }
          }
        });
        _performSearch(_searchController.text);
      },
      selectedColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Start typing to search'
                : 'No results found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Search across pets, reminders, health records, and more'
                : 'Try different keywords or filters',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme, bool isDark) {
    // Group results by type
    final groupedResults = <SearchResultType, List<SearchResult>>{};
    for (var result in _results) {
      groupedResults[result.type] ??= [];
      groupedResults[result.type]!.add(result);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedResults.length,
      itemBuilder: (context, index) {
        final entry = groupedResults.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _getTypeLabel(entry.key),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            ...entry.value.map((result) => _buildResultTile(result, theme, isDark)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildResultTile(SearchResult result, ThemeData theme, bool isDark) {
    IconData icon;
    switch (result.type) {
      case SearchResultType.pet:
        icon = Icons.pets;
        break;
      case SearchResultType.reminder:
        icon = Icons.notifications;
        break;
      case SearchResultType.health:
        icon = Icons.favorite;
        break;
      case SearchResultType.vaccination:
        icon = Icons.medical_services;
        break;
      case SearchResultType.milestone:
        icon = Icons.cake;
        break;
      case SearchResultType.activity:
        icon = Icons.directions_walk;
        break;
      case SearchResultType.expense:
        icon = Icons.receipt_long;
        break;
    }

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
      child: InkWell(
        onTap: () => _navigateToDetail(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: result.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: result.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(SearchResultType type) {
    switch (type) {
      case SearchResultType.pet:
        return 'Pets';
      case SearchResultType.reminder:
        return 'Reminders';
      case SearchResultType.health:
        return 'Health Records';
      case SearchResultType.vaccination:
        return 'Vaccinations';
      case SearchResultType.milestone:
        return 'Milestones';
      case SearchResultType.activity:
        return 'Activities';
      case SearchResultType.expense:
        return 'Expenses';
    }
  }

  void _navigateToDetail(SearchResult result) {
    final petProvider = context.read<PetProvider>();
    PetModel? pet;
    
    if (result.petId != null) {
      try {
        pet = petProvider.pets.firstWhere((p) => p.id == result.petId);
      } catch (e) {
        pet = null;
      }
    }

    if (pet == null && result.type != SearchResultType.pet) {
      return; // Can't navigate without pet
    }

    switch (result.type) {
      case SearchResultType.pet:
        if (result.originalData is PetModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PetDetailScreen(pet: result.originalData as PetModel),
            ),
          );
        }
        break;
      case SearchResultType.reminder:
        if (result.originalData is ReminderModel && pet != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReminderScreen(
                pet: pet!,
                reminder: result.originalData as ReminderModel,
              ),
            ),
          );
        }
        break;
      case SearchResultType.health:
        if (result.originalData is HealthRecordModel && pet != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddHealthRecordScreen(
                pet: pet!,
                record: result.originalData as HealthRecordModel,
              ),
            ),
          );
        }
        break;
      case SearchResultType.vaccination:
        if (result.originalData is VaccinationModel && pet != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddVaccinationScreen(
                pet: pet!,
                vaccination: result.originalData as VaccinationModel,
              ),
            ),
          );
        }
        break;
      case SearchResultType.milestone:
        if (result.originalData is MilestoneModel && pet != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMilestoneScreen(
                pet: pet!,
                milestone: result.originalData as MilestoneModel,
              ),
            ),
          );
        }
        break;
      case SearchResultType.activity:
        if (result.originalData is ActivityModel && pet != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddActivityScreen(
                pet: pet!,
                activity: result.originalData as ActivityModel,
              ),
            ),
          );
        }
        break;
      case SearchResultType.expense:
        if (result.originalData is ExpenseModel && pet != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(
                pet: pet!,
                expense: result.originalData as ExpenseModel,
              ),
            ),
          );
        }
        break;
    }
  }
}

