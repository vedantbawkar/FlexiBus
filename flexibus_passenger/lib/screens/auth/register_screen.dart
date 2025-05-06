import 'package:flexibus_passenger/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../dashboard/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final idProofTypeController = TextEditingController(text: 'Aadhar');
  final idProofValueController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController(text: 'Male');
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final List<String> idProofTypes = ['Aadhar', 'PAN', 'Other'];
  final List<String> genderOptions = ['Male', 'Female', 'Others'];

  bool isLoading = false;

  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  void registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final registrationSuccess = await authProvider.register(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      name: nameController.text.trim(),
      idProofType: idProofTypeController.text.trim(),
      idProofValue: idProofValueController.text.trim(),
      age: int.parse(ageController.text.trim()),
      gender: genderController.text.trim(),
      phone: phoneController.text.trim(),
      isVerified: false,
      isSecurityDepositPaid: false,
      isBanned: false,
      hasBooked: false,
    );

    if (registrationSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }

    setState(() => isLoading = false);
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
                        "Create Account",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Register to continue with FlexiBus",
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
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Enter name"
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: idProofTypeController.text,
                              decoration: buildInputDecoration(
                                "ID Proof Type",
                                icon: Icons.badge,
                              ),
                              style: GoogleFonts.poppins(),
                              dropdownColor: Colors.white,
                              items:
                                  idProofTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                            type,
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (val) => setState(() {
                                    idProofTypeController.text =
                                        val ?? 'Aadhar';
                                  }),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: idProofValueController,
                              decoration: buildInputDecoration(
                                "ID Proof Value",
                                icon: Icons.numbers,
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Enter ID proof value"
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
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Enter age"
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
                              onChanged:
                                  (val) =>
                                      genderController.text = val ?? 'Male',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: buildInputDecoration(
                                "Email",
                                icon: Icons.email,
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Enter email"
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: buildInputDecoration(
                                "Phone Number",
                                icon: Icons.phone,
                              ),
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? "Enter phone number"
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: buildInputDecoration(
                                "Password",
                                icon: Icons.lock,
                              ),
                              validator:
                                  (val) =>
                                      val != null && val.length < 6
                                          ? "Minimum 6 characters"
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: buildInputDecoration(
                                "Confirm Password",
                                icon: Icons.lock_outline,
                              ),
                              validator:
                                  (val) =>
                                      val != passwordController.text
                                          ? "Passwords do not match"
                                          : null,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: registerUser,
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
                                    'Register',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: gradient.colors.first,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
