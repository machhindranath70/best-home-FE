import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'success_page.dart';

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

  final List<String> propertyTypes = ['house', 'apartment', 'land'];

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      final success = await ApiService.submitRegistration({
        'name': name,
        'contact': contact,
        'property_type': propertyType,
        'property_name': propertyName,
        'address': address,
      });

      setState(() => isSubmitting = false);

      if (!mounted) return;
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SuccessPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to submit. Try again.')),
        );
      }
    }
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 88, 85),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 129, 85, 85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    '🏡 Register Property',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: buildInputDecoration('Name', Icons.person),
                    onChanged: (val) => name = val,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: buildInputDecoration(
                        'Contact', Icons.phone_android),
                    onChanged: (val) => contact = val,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (!RegExp(r'^\d{10}$').hasMatch(val)) {
                        return 'Enter 10 digit phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: propertyType,
                    decoration: buildInputDecoration(
                        'Property Type', Icons.home_work),
                    items: propertyTypes.map((type) {
                      return DropdownMenuItem(
                          value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) => setState(() => propertyType = val!),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: buildInputDecoration(
                        'Property Name', Icons.location_city),
                    onChanged: (val) => propertyName = val,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLines: 3,
                    decoration:
                        buildInputDecoration('Address', Icons.location_on),
                    onChanged: (val) => address = val,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        isSubmitting ? 'Submitting...' : 'Submit',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: isSubmitting ? null : submitForm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
