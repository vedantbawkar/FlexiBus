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
  String? profileImageUrl;
  Map<String, dynamic>? initialData;
  bool hasChanges = false;
  String? newProfileImagePath;

  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFF00C897)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Add listeners to all text controllers
    nameController.addListener(_checkForChanges);
    idProofTypeController.addListener(_checkForChanges);
    idProofValueController.addListener(_checkForChanges);
    ageController.addListener(_checkForChanges);
    genderController.addListener(_checkForChanges);
    emailController.addListener(_checkForChanges);
    phoneController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    // Remove listeners when widget is disposed
    nameController.removeListener(_checkForChanges);
    idProofTypeController.removeListener(_checkForChanges);
    idProofValueController.removeListener(_checkForChanges);
    ageController.removeListener(_checkForChanges);
    genderController.removeListener(_checkForChanges);
    emailController.removeListener(_checkForChanges);
    phoneController.removeListener(_checkForChanges);
    super.dispose();
  }

  void _checkForChanges() {
    final currentData = {
      'name': nameController.text,
      'idProofType': idProofTypeController.text,
      'idProofValue': idProofValueController.text,
      'age': ageController.text,
      'gender': genderController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'profileImageUrl': profileImageUrl,
    };

    setState(() {
      hasChanges =
          initialData != null &&
          (currentData.toString() != initialData!.toString() ||
              newProfileImagePath != null);
    });
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
          initialData = {
            'name': data['name'] ?? '',
            'idProofType': data['idProofType'] ?? 'Aadhar',
            'idProofValue': data['idProofValue'] ?? '',
            'age': data['age']?.toString() ?? '',
            'gender': data['gender'] ?? 'Male',
            'email': data['email'] ?? '',
            'phone': data['phone'] ?? '',
            'profileImageUrl': data['profileImageUrl'],
          };

          nameController.text = initialData!['name'];
          idProofTypeController.text = initialData!['idProofType'];
          idProofValueController.text = initialData!['idProofValue'];
          ageController.text = initialData!['age'];
          genderController.text = initialData!['gender'];
          emailController.text = initialData!['email'];
          phoneController.text = initialData!['phone'];
          setState(() {
            profileImageUrl = initialData!['profileImageUrl'];
          });
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
              'phone': phoneController.text.trim().replaceAll(' ', ''),
              'isVerified': false,
            });

        // TODO: Handle profile image upload if newProfileImagePath is not null

        // Update initial data after successful update
        initialData = {
          'name': nameController.text,
          'idProofType': idProofTypeController.text,
          'idProofValue': idProofValueController.text,
          'age': ageController.text,
          'gender': genderController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'profileImageUrl': profileImageUrl,
        };
        newProfileImagePath = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        setState(() {
          hasChanges = false;
        });
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
    final screenWidth = MediaQuery.of(context).size.width;
    final profileSize = screenWidth * 0.33; // 33% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                      // Profile Image Section
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: profileSize,
                              height: profileSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: gradient.colors[1],
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child:
                                    profileImageUrl != null
                                        ? Image.network(
                                          profileImageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                                    Icons.person,
                                                    size: profileSize * 0.5,
                                                    color: gradient.colors[1],
                                                  ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: profileSize * 0.5,
                                          color: gradient.colors[1],
                                        ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Implement image picker
                                  // When image is selected, set newProfileImagePath and call _checkForChanges()
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: gradient,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                      const SizedBox(height: 16),
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
                                _checkForChanges();
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
                                _checkForChanges();
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
                              onTap: hasChanges ? _updateUserProfile : null,
                              child: MouseRegion(
                                cursor:
                                    hasChanges
                                        ? SystemMouseCursors.click
                                        : SystemMouseCursors.basic,
                                onEnter:
                                    hasChanges
                                        ? (event) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Updating your profile causes the verification to be gone',
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                        : null,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient:
                                        hasChanges
                                            ? gradient
                                            : LinearGradient(
                                              colors: [
                                                Colors.grey.shade400,
                                                Colors.grey.shade500,
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (hasChanges
                                                ? gradient.colors[1]
                                                : Colors.grey)
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      hasChanges
                                          ? 'Update Profile'
                                          : 'No changes detected',
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
