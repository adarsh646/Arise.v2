import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'services/cloudinary_service.dart';

class TrainerRegisterScreen extends StatefulWidget {
  const TrainerRegisterScreen({super.key});

  @override
  State<TrainerRegisterScreen> createState() => _TrainerRegisterScreenState();
}

class _TrainerRegisterScreenState extends State<TrainerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profileImage;
  File? _certificateFile;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles the entire multi-step registration flow with phone verification.
  Future<void> _submitTrainerApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profileImage == null || _certificateFile == null) {
      Fluttertoast.showToast(
        msg: "Please upload a profile image and certificate",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create the user with email/password
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      final createdUser = userCredential.user;
      if (createdUser == null) {
        throw Exception("Failed to create user account.");
      }

      // Send email verification (optional)
      await createdUser.sendEmailVerification();

      // Upload files and save trainer data
      await _uploadFilesAndSaveData(createdUser.uid);
    } catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else {
          errorMessage = e.message ?? errorMessage;
        }
      } else if (e is Exception) {
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      }

      Fluttertoast.showToast(msg: errorMessage, backgroundColor: Colors.red);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Contains the logic for file uploads and saving data to Firestore.
  Future<void> _uploadFilesAndSaveData(String uid) async {
    try {
      final profileUrl = await _uploadFile(
        _profileImage!,
        folder: "trainers/$uid",
        resourceType: 'image',
      );
      final certUrl = await _uploadFile(
        _certificateFile!,
        folder: "trainers/$uid",
        resourceType: 'raw',
      );

      if (profileUrl == null || certUrl == null) {
        throw Exception("File upload failed.");
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": _nameController.text.trim(),
        "username": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "qualification": _qualificationController.text.trim(),
        "experience": _experienceController.text.trim(),
        "role": "trainer",
        "status": "pending",
        "profileImage": profileUrl,
        "certificateUrl": certUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(
        msg: "Application Submitted! Awaiting admin approval.",
        backgroundColor: Colors.green,
        toastLength: Toast.LENGTH_LONG,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() => _certificateFile = File(result.files.single.path!));
    }
  }

  Future<String?> _uploadFile(
    File file, {
    required String folder,
    String resourceType = 'image',
  }) async {
    try {
      final cloudinary = CloudinaryService.fromEnvironment();
      final result = await cloudinary.uploadFile(
        file,
        resourceType: resourceType,
        folderOverride: folder,
      );
      return result.secureUrl;
    } catch (e) {
      Fluttertoast.showToast(msg: "Upload failed: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trainer Registration"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: _profileImage == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.grey[800],
                        )
                      : ClipOval(
                          child: Image.file(
                            _profileImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v == null || v.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains("@") ? "Enter valid email" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number (e.g., +16505551234)",
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty || !v.startsWith('+')
                    ? "Enter a valid phone number with country code"
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
                validator: (v) => v == null || v.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                ),
                validator: (v) => v != _passwordController.text
                    ? "Passwords do not match"
                    : null,
              ),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(labelText: "Qualification"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter qualification" : null,
              ),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: "Experience (years)",
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter experience" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickCertificate,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _certificateFile == null
                      ? "Upload Certificate"
                      : "Certificate Selected",
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitTrainerApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text("Submit Application"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
