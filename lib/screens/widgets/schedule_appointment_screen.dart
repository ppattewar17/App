import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() => _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
      _formKey.currentState!.save();

      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      ).toIso8601String();

      final response = await http.post(
        Uri.parse('http://192.168.55.75:5000/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userName': _name,
          'userId': 'f7d648e0-ec3b-4f62-9111-3bd3f7f83d4d', // Replace with actual ID
          'doctorId': '1e598be7-980a-4314-859e-94c2a97edc1b', // Replace with selected doctor
          'appointmentDateTime': appointmentDateTime,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appointment scheduled for $_name on $appointmentDateTime'),
          backgroundColor: Colors.green,
        ));

        setState(() {
          _name = '';
          _selectedDate = null;
          _selectedTime = null;
        });

        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to schedule: ${response.body}'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }


  Widget _buildCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                  onSaved: (value) => _name = value!,
                ),
              ),
              _buildCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _selectedDate == null
                        ? 'Pick a Date'
                        : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(context),
                ),
              ),
              _buildCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _selectedTime == null
                        ? 'Pick a Time'
                        : 'Time: ${_selectedTime!.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _pickTime(context),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: const Text('Schedule Appointment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
