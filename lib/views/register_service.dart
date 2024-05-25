import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat1/views/Widgets/my_button.dart';
import 'package:chat1/views/Widgets/my_textfield.dart';
import 'package:chat1/Controller/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final String role;
  final VoidCallback? onTap;

  const RegisterPage({Key? key, required this.role, this.onTap})
      : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _pwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  final _fiscalCodeController = TextEditingController();
  File? _selectedImage;
  String _emailValidationMessage = '';
  String _passwordValidationMessage = '';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateValidationMessages);
    _pwController.addListener(_updateValidationMessages);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _pwController.dispose();
    _confirmPwController.dispose();
    _fiscalCodeController.dispose();
    super.dispose();
  }

  void _updateValidationMessages() {
    _updateEmailValidationMessage();
    _updatePasswordValidationMessage();
  }

  void _updateEmailValidationMessage() {
    final emailRegex = RegExp(r'^[A-Za-z0-9._]+@gmail\.com$');
    final pharmEmailRegex = RegExp(r'^[A-Za-z]+pharmacie@gmail.com$');
    if (widget.role == 'pharmacien' &&
        !pharmEmailRegex.hasMatch(_emailController.text)) {
      setState(() {
        _emailValidationMessage =
            "*L'email doit être sous la forme nompharmacie@gmail.com";
      });
    } else if (!emailRegex.hasMatch(_emailController.text)) {
      setState(() {
        _emailValidationMessage = "*L'email doit se terminer par @gmail.com";
      });
    } else {
      setState(() {
        _emailValidationMessage = '';
      });
    }
  }

  void _updatePasswordValidationMessage() {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
    if (!passwordRegex.hasMatch(_pwController.text)) {
      setState(() {
        _passwordValidationMessage =
            "*Le mot de passe doit contenir au moins 8 caractères, incluant des majuscules, des minuscules, des chiffres et des caractères spéciaux.";
      });
    } else {
      setState(() {
        _passwordValidationMessage = '';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _convertImageToBase64(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  void register(BuildContext context) async {
    if (_emailValidationMessage.isNotEmpty ||
        _passwordValidationMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Veuillez corriger les erreurs avant de continuer.")));
      return;
    }

    final authService = AuthService();
    final password = _pwController.text;
    final confirmPassword = _confirmPwController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Les mots de passe ne correspondent pas.")));
      return;
    }

    try {
      String? imageBase64;
      if (_selectedImage != null) {
        imageBase64 = await _convertImageToBase64(_selectedImage!);
      }

      UserCredential userCredential = await authService.signUpWithEmailPassword(
        _emailController.text.trim(),
        password,
        _nameController.text.trim(),
        widget.role,
        context,
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .update({'image': imageBase64});
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erreur lors de l'inscription: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/back.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text("Créer un compte",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 24)),
                    SizedBox(height: 20),
                    _buildCircleAvatar(),
                    SizedBox(height: 20),
                    _buildTextFieldContainer("Nom", _nameController, null),
                    _buildTextFieldContainer(
                        "Adresse e-mail", _emailController, null),
                    if (_emailValidationMessage.isNotEmpty)
                      Text(_emailValidationMessage,
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                    _buildTextFieldContainer(
                        "Mot de passe", _pwController, null),
                    if (_passwordValidationMessage.isNotEmpty)
                      Text(_passwordValidationMessage,
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                    _buildTextFieldContainer("Confirmer le mot de passe",
                        _confirmPwController, null),
                    if (widget.role == "pharmacien") ...[
                      _buildTextFieldContainer(
                          "Code fiscal", _fiscalCodeController, null),
                    ],
                    SizedBox(height: 20),
                    MyButton(
                        text: "S'inscrire", onTap: () => register(context)),
                    _buildLoginPrompt(context),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _selectedImage != null
              ? FileImage(_selectedImage!)
              : AssetImage('assets/images/Groupe 78.png') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.add_a_photo, color: Colors.grey[700]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldContainer(String label,
      TextEditingController controller, String? validationMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: MyTextField(
            hintText: label,
            obscureText: label.contains("Mot de passe"),
            controller: controller,
            keyboardType: label.contains("Adresse e-mail")
                ? TextInputType.emailAddress
                : TextInputType.text,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Vous avez déjà un compte ? ",
            style:
                TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        GestureDetector(
          onTap: widget.onTap,
          child: Text("Se connecter",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ],
    );
  }
}
