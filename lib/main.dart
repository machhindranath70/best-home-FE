import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screens/registration_page.dart';
import 'dart:convert';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ add const here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Best Home App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(), // ✅ Correct: Show HomePage here
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String contact = '';
  String propertyType = 'house';
  String propertyName = '';
  String address = '';
  bool isSubmitting = false;

  Future<void> submitForm() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/register/'); // Replace if needed

    setState(() => isSubmitting = true);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'contact': contact,
        'property_type': propertyType,
        'property_name': propertyName,
        'address': address,
      }),
    );

    setState(() => isSubmitting = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Registered Successfully')),
      );
      _formKey.currentState?.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Property')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (val) => name = val,
              validator: (val) => val!.isEmpty ? 'Enter name' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Contact'),
              onChanged: (val) => contact = val,
              validator: (val) => val!.isEmpty ? 'Enter contact' : null,
            ),
            DropdownButtonFormField<String>(
              value: propertyType,
              decoration: InputDecoration(labelText: 'Property Type'),
              items: ['house', 'apartment', 'land'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => propertyType = val!),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Property Name'),
              onChanged: (val) => propertyName = val,
              validator: (val) => val!.isEmpty ? 'Enter property name' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Address'),
              onChanged: (val) => address = val,
              validator: (val) => val!.isEmpty ? 'Enter address' : null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        submitForm();
                      }
                    },
              child: isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Submit'),
            ),
          ]),
        ),
      ),
    );
  }
}
