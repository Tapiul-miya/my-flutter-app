import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool loading = false;
  bool showPassword = false;

  String? errorMessage;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        final userCred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCred.user!.uid)
            .set({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "mobile": mobileController.text.trim(),
          "address": addressController.text.trim(),
          "createdAt": DateTime.now(),
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-credential') {
          errorMessage = "Email ba Password bhul hoyeche!";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Apnar dewa password-ti vul.";
        } else if (e.code == 'user-not-found') {
          errorMessage = "Ei email-e kono account khunje paoa jayni.";
        } else if (e.code == 'email-already-in-use') {
          errorMessage = "Ei email diye agei account khola hoyeche.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Email-er format thik nei.";
        } else if (e.code == 'network-request-failed') {
          errorMessage = "Internet connection thik nei.";
        } else {
          errorMessage = "Somossa hoyeche: ${e.message}";
        }
      });
    } catch (e) {
      setState(() => errorMessage = "Ochena kono somossa hoyeche.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: label == "Password"
              ? IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "My Dokan",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => errorMessage = null),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                ),

              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          isLogin ? "Welcome Back 👋" : "Create Account 🚀",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (!isLogin)
                          buildInput(
                            controller: nameController,
                            label: "Full Name",
                            icon: Icons.person,
                            validator: (v) =>
                                v!.isEmpty ? "Name din" : null,
                          ),

                        buildInput(
                          controller: emailController,
                          label: "Email",
                          icon: Icons.email,
                          validator: (v) =>
                              !v!.contains("@") ? "Email thik nei" : null,
                        ),

                        if (!isLogin)
                          buildInput(
                            controller: mobileController,
                            label: "Mobile",
                            icon: Icons.phone,
                            validator: (v) =>
                                v!.length < 10 ? "Mobile thik nei" : null,
                          ),

                        if (!isLogin)
                          buildInput(
                            controller: addressController,
                            label: "Address",
                            icon: Icons.location_on,
                            validator: (v) =>
                                v!.isEmpty ? "Address din" : null,
                          ),

                        buildInput(
                          controller: passwordController,
                          label: "Password",
                          icon: Icons.lock,
                          obscure: !showPassword,
                          validator: (v) =>
                              v!.length < 6 ? "Minimum 6 digit" : null,
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    isLogin ? "Login" : "Sign Up",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                              errorMessage = null;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.grey[700]),
                              children: [
                                TextSpan(
                                  text: isLogin
                                      ? "Don't have an account? "
                                      : "Already have an account? ",
                                ),
                                TextSpan(
                                  text: isLogin ? "Sign Up" : "Login",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}