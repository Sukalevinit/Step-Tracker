import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/weekday_tracker.dart';
import '../widgets/water_tracker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About Step Tracker'),
        content: const Text(
          'Step Tracker is an offline fitness app that helps you track your daily steps, '
          'distance walked, calories burned, and active time. The app works completely '
          'offline and saves your progress locally.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                'Step Goal',
                '${stepProvider.stepGoal} steps',
                onTap: () => _showStepGoalDialog(context),
              ),
              _buildSettingItem(
                'Water Goal',
                '${stepProvider.waterGoal}${stepProvider.volumeUnit}',
                onTap: () => _showWaterGoalDialog(context),
              ),
              _buildSettingItem(
                'Reminder Interval',
                '${stepProvider.reminderInterval} minutes',
                onTap: () => _showReminderIntervalDialog(context),
              ),
              Consumer<StepProvider>(
                builder: (ctx, provider, _) => _buildSwitchItem(
                  'Animations',
                  provider.hasAnimations,
                  (value) => provider.setAnimations(value),
                ),
              ),
              Consumer<StepProvider>(
                builder: (ctx, provider, _) => _buildSwitchItem(
                  'Sound Effects',
                  provider.hasSoundEffects,
                  (value) => provider.setSoundEffects(value),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showReminderIntervalDialog(BuildContext context) {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);
    TextEditingController controller = TextEditingController(
      text: stepProvider.reminderInterval.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.blue[700],
        title: const Text(
          'Set Reminder Interval',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Minutes',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              final interval = int.tryParse(controller.text);
              if (interval != null && interval > 0) {
                stepProvider.setReminderInterval(interval);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showStepGoalDialog(BuildContext context) {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);
    TextEditingController controller = TextEditingController(text: stepProvider.stepGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Step Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            suffixText: 'steps',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                stepProvider.setStepGoal(newGoal);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWaterGoalDialog(BuildContext context) {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);
    TextEditingController controller = TextEditingController(text: stepProvider.waterGoal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Water Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Water',
            suffixText: stepProvider.volumeUnit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                stepProvider.setWaterGoal(newGoal);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will reset all your progress, including steps, water intake, and settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<StepProvider>(context, listen: false).resetStats();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Close settings dialog
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    onPressed: () => _showInfoDialog(context),
                  ),
                  Column(
                    children: [
                      Consumer<StepProvider>(
                        builder: (ctx, stepProvider, _) => Text(
                          stepProvider.steps.toString(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'Total Steps / 5000',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => _showSettingsDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  StatsCard(),
                  SizedBox(height: 20),
                  WeekdayTracker(),
                  SizedBox(height: 20),
                  WaterTracker(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
