import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationSheet extends StatefulWidget {
  final String noteId;
  final String noteTitle;
  final String noteType; // 'note' or 'linked'

  const NotificationSheet({
    super.key,
    required this.noteId,
    required this.noteTitle,
    required this.noteType,
  });

  static void show(BuildContext context,
      {required String noteId,
      required String noteTitle,
      required String noteType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationSheet(
        noteId: noteId,
        noteTitle: noteTitle,
        noteType: noteType,
      ),
    );
  }

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  String _selected = 'default';
  DateTime? _customDate;
  TimeOfDay? _customTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF9575CD),
            onPrimary: Colors.white,
            surface: Color(0xFFF3E8FF),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _customDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF9575CD),
            onPrimary: Colors.white,
            surface: Color(0xFFF3E8FF),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _customTime = picked);
  }

  Future<void> _save() async {
    if (_selected == 'default') {
      await NotificationService.scheduleReminders(
          widget.noteId, widget.noteTitle, widget.noteType);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Default reminders set!'),
            backgroundColor: Color(0xFF9575CD),
          ),
        );
      }
    } else {
      if (_customDate == null || _customTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both date and time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final scheduled = DateTime(
        _customDate!.year,
        _customDate!.month,
        _customDate!.day,
        _customTime!.hour,
        _customTime!.minute,
      );
      if (scheduled.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a future date and time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await NotificationService.scheduleCustom(
          widget.noteId, widget.noteTitle, widget.noteType, scheduled);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Reminder set for ${_customDate!.day}/${_customDate!.month}/${_customDate!.year} at ${_customTime!.format(context)}'),
            backgroundColor: const Color(0xFF9575CD),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3E8FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFB39DDB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB39DDB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Set Reminder',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E35B1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.noteTitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Default option
          _OptionCard(
            selected: _selected == 'default',
            onTap: () => setState(() => _selected = 'default'),
            icon: Icons.notifications_active,
            title: 'Default',
            subtitle: 'Reminders at 1 min, 10 min, 1 hr & 24 hrs',
          ),
          const SizedBox(height: 12),

          // Custom option
          _OptionCard(
            selected: _selected == 'custom',
            onTap: () => setState(() => _selected = 'custom'),
            icon: Icons.schedule,
            title: 'Custom',
            subtitle: 'Pick your own date and time',
          ),

          // Date & Time pickers (shown only when custom selected)
          if (_selected == 'custom') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PickerButton(
                    icon: Icons.calendar_today,
                    label: _customDate == null
                        ? 'Select Date'
                        : '${_customDate!.day}/${_customDate!.month}/${_customDate!.year}',
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerButton(
                    icon: Icons.access_time,
                    label: _customTime == null
                        ? 'Select Time'
                        : _customTime!.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9575CD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Set Reminder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  const _OptionCard({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF9575CD).withOpacity(0.12)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF9575CD) : const Color(0xFFE1BEE7),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF9575CD)
                    : const Color(0xFFE1BEE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : const Color(0xFF9575CD),
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: selected
                            ? const Color(0xFF5E35B1)
                            : const Color(0xFF7E57C2),
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF9575CD) : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB39DDB)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF9575CD)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF5E35B1)),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
