import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController partName = TextEditingController();
  TextEditingController partReplacedDistance = TextEditingController();
  TextEditingController partReplacedTime = TextEditingController();
  TextEditingController partLifetimeDistance = TextEditingController();
  TextEditingController partLifetimeTime = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void handleSave() {
      if (_formKey.currentState!.validate()) {
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Part'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: partName,
                decoration: const InputDecoration(labelText: 'Part name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a part name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: partReplacedDistance,
                decoration: const InputDecoration(labelText: 'Changed at (KM)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the replacement distance';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: partReplacedTime,
                decoration:
                    const InputDecoration(labelText: 'Changed at (Time)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the replacement time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: partLifetimeDistance,
                decoration:
                    const InputDecoration(labelText: 'Service distance (KM)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the service distance';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: partLifetimeTime,
                decoration:
                    const InputDecoration(labelText: 'Service Time (months)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the service time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: handleSave,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
