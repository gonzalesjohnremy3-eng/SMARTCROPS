import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/features/calendar/domain/task_draft.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/models/app_models.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, this.event});

  final CropCalendarEvent? event;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late String _category;
  late String _priority;
  String? _selectedCropId;
  late DateTime _scheduledDate;
  bool _isSaving = false;

  final List<String> _categories = [
    'Nutrition',
    'Water Management',
    'Pest Control',
    'Harvesting',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.eventTitle ?? '');
    _category = widget.event?.eventCategory ?? 'General';
    _priority = widget.event?.priority ?? 'Normal';
    _selectedCropId = widget.event?.cropId;
    _scheduledDate = widget.event?.scheduledDate ?? DateTime.now().add(const Duration(hours: 8));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save(SmartCropsService service) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context);

    setState(() => _isSaving = true);
    try {
      final draft = TaskDraft(
        title: _titleController.text.trim(),
        category: _category,
        scheduledDate: _scheduledDate,
        cropId: _selectedCropId,
        priority: _priority,
      );

      if (widget.event != null) {
        await service.updateCalendarEvent(widget.event!.id, draft);
      } else {
        await service.addCalendarEvent(draft);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.taskSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.taskSaveError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();
    final crops = service.userSelectedCrops;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.event == null ? l10n.calendarAddTask : l10n.taskEditTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.taskTitleLabel,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? l10n.taskTitleRequired : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: l10n.taskCategoryLabel,
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'General'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _selectedCropId,
                decoration: InputDecoration(
                  labelText: l10n.taskCropLabel,
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text(l10n.taskNoCrop)),
                  ...crops.map((crop) => DropdownMenuItem<String?>(
                        value: crop.id,
                        child: Text(crop.cropName),
                      )),
                ],
                onChanged: (v) => setState(() => _selectedCropId = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: InputDecoration(
                  labelText: l10n.taskPriorityLabel,
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Normal', child: Text(l10n.taskPriorityNormal)),
                  DropdownMenuItem(value: 'High', child: Text(l10n.taskPriorityHigh)),
                ],
                onChanged: (v) => setState(() => _priority = v ?? 'Normal'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _scheduledDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (picked != null) {
                          setState(() {
                            _scheduledDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              _scheduledDate.hour,
                              _scheduledDate.minute,
                            );
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text('${_scheduledDate.month}/${_scheduledDate.day}/${_scheduledDate.year}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : () => _save(service),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.taskSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
