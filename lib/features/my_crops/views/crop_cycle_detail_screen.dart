import '../../../../app/theme/app_colors.dart';
import 'package:agrolink/features/my_crops/controllers/my_crops_provider.dart';
import 'package:agrolink/features/my_crops/models/crop_cycle_model.dart';
import 'package:agrolink/features/my_crops/models/journal_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // ⬅️ IMPORTED for ImageFilter

class CropCycleDetailScreen extends StatefulWidget {
  final CropCycleModel cycle;
  const CropCycleDetailScreen({super.key, required this.cycle});

  @override
  State<CropCycleDetailScreen> createState() => _CropCycleDetailScreenState();
}

class _CropCycleDetailScreenState extends State<CropCycleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _journalNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // When the screen loads, fetch the journal entries for this cycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MyCropsProvider>(context, listen: false)
            .fetchJournalEntries(widget.cycle.cycleId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _journalNoteController.dispose();
    super.dispose();
  }

  // --- Dialog to show step details ---
  void _showStepDetails(BuildContext context, Map<String, dynamic> step) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightScaffoldBackground, // Use app theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> highlights = step['highlights'] != null
            ? List<String>.from(step['highlights'])
            : [];

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    step['title'] ?? 'Step Details',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, // Use app theme
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: ${step['duration'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary, // Use app theme
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, // Use app theme
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step['description'] ?? 'No description provided.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.textSecondary, // Use app theme
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (highlights.isNotEmpty)
                    const Text(
                      'Highlights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary, // Use app theme
                      ),
                    ),
                  if (highlights.isNotEmpty) const SizedBox(height: 8),
                  if (highlights.isNotEmpty)
                    ...highlights.map((highlight) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.star_border,
                                  size: 20, color: AppColors.primaryGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  highlight,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary, // Use app theme
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Dialog to add a new journal entry ---
  void _showAddJournalEntryDialog(BuildContext context) {
    _journalNoteController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.lightScaffoldBackground, // Use app theme
          title: const Text(
            'Add Journal Entry',
            style: TextStyle(color: AppColors.textPrimary), // Use app theme
          ),
          content: TextField(
            controller: _journalNoteController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'e.g., Watered plants, spotted pests...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryGreen),
              ),
            ),
            maxLines: 5,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary), // Use app theme
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_journalNoteController.text.trim().isEmpty) {
                  return;
                }
                final provider =
                    context.read<MyCropsProvider>();
                final success = await provider.addJournalEntry(
                  cycleId: widget.cycle.cycleId,
                  notes: _journalNoteController.text.trim(),
                  // TODO: Add image upload logic here
                );

                if (success && mounted) {
                  Navigator.pop(context);
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(provider.errorMessage ?? 'Failed to add entry.'),
                      backgroundColor: AppColors.errorRed, // Use app theme
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⬅️ ADDED: Container for background image
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/doodles.png'), // ⬅️ CHANGED: Use doodles.png
          fit: BoxFit.cover,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // ⬅️ Make Scaffold transparent
        appBar: AppBar(
          title: Text(widget.cycle.displayName),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryGreen, // Use app theme
            unselectedLabelColor: AppColors.textSecondary, // Use app theme
            indicatorColor: AppColors.primaryGreen, // Use app theme
            tabs: const [
              Tab(icon: Icon(Icons.checklist_rtl), text: 'Plan'),
              Tab(icon: Icon(Icons.book_outlined), text: 'Journal'),
            ],
          ),
        ),
        body: BackdropFilter( // ⬅️ ADDED: BackdropFilter for blur effect
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // Adjust blur level
          child: TabBarView(
            controller: _tabController,
            children: [
              // --- TAB 1: PLAN CHECKLIST ---
              _buildPlanTab(context),
              // --- TAB 2: JOURNAL ---
              _buildJournalTab(context),
            ],
          ),
        ),
        // ⭐️ FIX: Conditionally display the FloatingActionButton only for the Journal tab
        floatingActionButton: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            if (_tabController.index == 1) {
              return FloatingActionButton(
                backgroundColor: AppColors.primaryGreen, // Use app theme
                foregroundColor: Colors.white,
                onPressed: () {
                  _showAddJournalEntryDialog(context);
                },
                child: const Icon(Icons.add_comment),
              );
            }
            // ⭐️ Return null when on the 'Plan' tab (index 0) or any other index
            return const SizedBox.shrink(); 
          },
        ),
      ),
    );
  }

  // --- WIDGET FOR "PLAN" TAB ---
  Widget _buildPlanTab(BuildContext context) {
    // Consumer listens for changes (like toggling a step)
    return Consumer<MyCropsProvider>(
      builder: (context, provider, child) {
        // Find the most up-to-date version of our cycle from the provider
        final cycle = provider.myCycles
            .firstWhere((c) => c.cycleId == widget.cycle.cycleId,
                // Add orElse to prevent errors if the cycle is deleted
                orElse: () => widget.cycle); 

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: cycle.planProgress.length,
          itemBuilder: (context, index) {
            final step = cycle.planProgress[index];
            final bool isCompleted = step['isCompleted'] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: CheckboxListTile(
                value: isCompleted,
                activeColor: AppColors.primaryGreen, // Use app theme
                onChanged: (bool? value) {
                  final bool newValue = value ?? false;

                  // 1. COMPLEX LOGIC HANDLING
                  if (newValue) {
                    // --- Auto-check preceding steps (for index 4 only) ---
                    if (index == 4) { // 5th step
                      for (int i = 0; i < 4; i++) {
                        if (!(cycle.planProgress[i]['isCompleted'] ?? false)) {
                            // This assumes `togglePlanStep` works to mark an incomplete step as complete.
                            provider.togglePlanStep(cycle.cycleId, i);
                        }
                      }
                    } else if (index > 4) {
                      // Ensure all preceding steps are completed if a later step is checked.
                      for (int i = 0; i < index; i++) {
                          if (!(cycle.planProgress[i]['isCompleted'] ?? false)) {
                            provider.togglePlanStep(cycle.cycleId, i);
                          }
                      }
                    }
                  } else {
                    // --- Auto-uncheck subsequent steps ---
                    // If the current step is being deselected, deselect all subsequent steps.
                    for (int i = index + 1; i < cycle.planProgress.length; i++) {
                      if (cycle.planProgress[i]['isCompleted'] ?? false) {
                        // Toggle subsequent steps that are currently completed.
                        provider.togglePlanStep(cycle.cycleId, i);
                      }
                    }
                  }

                  // 2. TOGGLE THE CURRENT STEP (must be last to prevent double toggling on predecessors)
                  provider.togglePlanStep(cycle.cycleId, index);
                },
                title: Text(
                  step['title'] ?? 'Untitled Step',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted
                        ? AppColors.textSecondary
                        : AppColors.textPrimary, // Use app theme
                  ),
                ),
                subtitle: Text(
                  'Duration: ${step['duration'] ?? 'N/A'}',
                  style: TextStyle(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: AppColors.textSecondary, // Use app theme
                  ),
                ),
                secondary: IconButton(
                  icon: const Icon(Icons.info_outline,
                      color: AppColors.accentBlue), // Use app theme
                  onPressed: () {
                    _showStepDetails(context, step);
                  },
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          },
        );
      },
    );
  }

  // --- WIDGET FOR "JOURNAL" TAB ---
  Widget _buildJournalTab(BuildContext context) {
    return Consumer<MyCropsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.currentJournalEntries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.currentJournalEntries.isEmpty) {
          return const Center(
            child: Text(
              'No journal entries yet.\nPress the "+" button to add one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: AppColors.textSecondary), // Use app theme
            ),
          );
        }

        // Display the list of journal entries
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: provider.currentJournalEntries.length,
          itemBuilder: (context, index) {
            final entry = provider.currentJournalEntries[index];
            return _buildJournalEntryCard(entry);
          },
        );
      },
    );
  }

  Widget _buildJournalEntryCard(JournalEntryModel entry) {
    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');
    final String entryDate = formatter.format(entry.date.toDate());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entryDate,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary), // Use app theme
            ),
            const SizedBox(height: 8),
            // TODO: Add Image display logic here
            // if (entry.imageUrl != null)
            //   Image.network(entry.imageUrl!),
            // const SizedBox(height: 8),
            Text(
              entry.notes,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppColors.textPrimary, // Use app theme
              ),
            ),
          ],
        ),
      ),
    );
  }
}