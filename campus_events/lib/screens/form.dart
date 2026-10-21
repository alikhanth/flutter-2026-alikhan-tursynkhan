import 'package:flutter/material.dart';
import '../models/item.dart';
import '../routes.dart';
import '../utils/format.dart';

class FormScreen extends StatefulWidget {
  final FormArgs args;
  const FormScreen({super.key, required this.args});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Item _initial;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _timeCtrl;

  late final FocusNode _titleNode;
  late final FocusNode _locationNode;
  late final FocusNode _capacityNode;
  late final FocusNode _descNode;

  bool _isOnline = false;
  EventCategory? _category;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initial = widget.args.item ?? Item.empty();
    _titleCtrl = TextEditingController(text: _initial.title);
    _locationCtrl = TextEditingController(text: _initial.location);
    _capacityCtrl = TextEditingController(text: _initial.capacity.toString());
    _descCtrl = TextEditingController(text: _initial.description ?? '');

    _titleNode = FocusNode();
    _locationNode = FocusNode();
    _capacityNode = FocusNode();
    _descNode = FocusNode();

    _isOnline = _initial.isOnline;
    _category = _initial.category;

    if (widget.args.item != null) {
      _selectedDate = _initial.starts;
      _selectedTime = TimeOfDay.fromDateTime(_initial.starts);
      _dateCtrl = TextEditingController(text: formatDateOnly(_selectedDate!));

      final hh = _selectedTime!.hour.toString().padLeft(2, '0');
      final mm = _selectedTime!.minute.toString().padLeft(2, '0');
      _timeCtrl = TextEditingController(text: '$hh:$mm');
    } else {
      _dateCtrl = TextEditingController();
      _timeCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _titleNode.dispose();
    _locationNode.dispose();
    _capacityNode.dispose();
    _descNode.dispose();
    super.dispose();
  }

  bool get _dirty {
    if (_titleCtrl.text != _initial.title) {
      return true;
    }
    if (_locationCtrl.text != _initial.location) {
      return true;
    }
    if (_capacityCtrl.text != _initial.capacity.toString()) {
      return true;
    }
    if (_descCtrl.text != (_initial.description ?? '')) {
      return true;
    }
    if (_isOnline != _initial.isOnline) {
      return true;
    }
    if (_category != _initial.category) {
      return true;
    }

    if (_selectedDate == null) {
      if (widget.args.item != null) {
        return true;
      }
    } else if (widget.args.item == null) {
      return true;
    } else if (_selectedDate!.year != _initial.starts.year ||
        _selectedDate!.month != _initial.starts.month ||
        _selectedDate!.day != _initial.starts.day) {
      return true;
    }

    if (_selectedTime == null) {
      if (widget.args.item != null) {
        return true;
      }
    } else if (widget.args.item == null) {
      return true;
    } else if (_selectedTime!.hour != _initial.starts.hour ||
        _selectedTime!.minute != _initial.starts.minute) {
      return true;
    }

    return false;
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() == true && !_isSaving) {
      setState(() => _isSaving = true);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) {
        return;
      }

      final d = _selectedDate ?? DateTime.now();
      final t = _selectedTime ?? TimeOfDay.now();
      final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);

      final newItem = _initial.copyWith(
        title: _titleCtrl.text,
        location: _locationCtrl.text,
        capacity: int.parse(_capacityCtrl.text),
        description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
        clearDescription: _descCtrl.text.isEmpty,
        isOnline: _isOnline,
        category: _category,
        starts: dt,
      );
      Navigator.pop(context, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty || _isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final discard = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Discard changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.args.item == null ? 'New Event' : 'Edit Event'),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                focusNode: _titleNode,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                (v == null || v.length < 3) ? 'Min 3 chars' : null,
              ),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: EventCategory.values
                    .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SwitchListTile(
                title: const Text('Online Mode'),
                value: _isOnline,
                onChanged: (v) => setState(() => _isOnline = v),
              ),
              TextFormField(
                controller: _locationCtrl,
                focusNode: _locationNode,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration:
                InputDecoration(labelText: _isOnline ? 'Link' : 'Place'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Required';
                  }
                  if (_isOnline && !v.contains('://')) {
                    return 'Must contain ://';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _capacityCtrl,
                focusNode: _capacityNode,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(labelText: 'Limit'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Required';
                  }
                  final n = int.tryParse(v);
                  if (n == null || n < 1 || n > 500) {
                    return 'Must be 1-500';
                  }
                  if (widget.args.item != null && n < _initial.count) {
                    return 'Cannot be less than attendees (${_initial.count})';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Date'),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) {
                          setState(() {
                            _selectedDate = d;
                            _dateCtrl.text = formatDateOnly(d);
                          });
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Required';
                        }
                        if (widget.args.item == null &&
                            _selectedDate != null &&
                            _selectedDate!.isBefore(DateTime.now()
                                .subtract(const Duration(days: 1)))) {
                          return 'Must be future';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Time'),
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (t != null) {
                          final hh = t.hour.toString().padLeft(2, '0');
                          final mm = t.minute.toString().padLeft(2, '0');
                          setState(() {
                            _selectedTime = t;
                            _timeCtrl.text = '$hh:$mm';
                          });
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                focusNode: _descNode,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                maxLines: 3,
                decoration:
                const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}