import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final idProofTypeController = TextEditingController();
  final idProofValueController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final List<String> idProofTypes = ['Aadhar', 'PAN', 'Other'];
  final List<String> genderOptions = ['Male', 'Female', 'Others'];

  bool isLoading = false;

  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('passengers')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          final data = doc.data()!;
          nameController.text = data['name'] ?? '';
          idProofTypeController.text = data['idProofType'] ?? 'Aadhar';
          idProofValueController.text = data['idProofValue'] ?? '';
          ageController.text = data['age']?.toString() ?? '';
          genderController.text = data['gender'] ?? 'Male';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('passengers')
            .doc(user.uid)
            .update({
              'name': nameController.text.trim(),
              'idProofType': idProofTypeController.text.trim(),
              'idProofValue': idProofValueController.text.trim(),
              'age': int.parse(ageController.text.trim()),
              'gender': genderController.text.trim(),
              'email': emailController.text.trim(),
              'phone': phoneController.text.trim(),
              'isVerified': false,
            });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration buildInputDecoration(
    String label, {
    IconData? icon,
    Color? iconColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: gradient.colors.first),
        borderRadius: BorderRadius.circular(10),
      ),
      prefixIcon:
          icon != null
              ? Icon(icon, color: iconColor ?? gradient.colors[1])
              : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'FlexiBus Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Your Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Update your details below",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: buildInputDecoration(
                                "Name",
                                icon: Icons.person,
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter name'
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: idProofTypeController.text,
                              decoration: buildInputDecoration(
                                "ID Proof Type",
                                icon: Icons.badge,
                              ),
                              items:
                                  idProofTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                idProofTypeController.text = value ?? 'Aadhar';
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: idProofValueController,
                              decoration: buildInputDecoration(
                                "ID Proof Value",
                                icon: Icons.numbers,
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter ID proof value'
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: ageController,
                              keyboardType: TextInputType.number,
                              decoration: buildInputDecoration(
                                "Age",
                                icon: Icons.cake,
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter age'
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: genderController.text,
                              decoration: buildInputDecoration(
                                "Gender",
                                icon: Icons.wc,
                              ),
                              items:
                                  genderOptions
                                      .map(
                                        (gender) => DropdownMenuItem(
                                          value: gender,
                                          child: Text(gender),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                genderController.text = value ?? 'Male';
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: buildInputDecoration(
                                "Email",
                                icon: Icons.email,
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter email'
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: phoneController,
                              decoration: buildInputDecoration(
                                "Phone Number",
                                icon: Icons.phone,
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter phone number'
                                          : null,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _updateUserProfile,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: (event) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Updating your profile causes the verification to be gone',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: gradient,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gradient.colors[1].withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Update Profile',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
