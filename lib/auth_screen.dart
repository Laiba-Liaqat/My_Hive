import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/customization_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'root_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; 
  bool _isLoading = false; 

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Please fill in all required fields.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // FIREBASE LOGIN
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // FIREBASE SIGN UP
        if (_nameController.text.trim().isEmpty) {
          _showErrorSnackBar("Please enter your name.");
          setState(() => _isLoading = false);
          return;
        }
        
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user?.updateDisplayName(_nameController.text.trim());
      }

      // Re-sync cloud-backed data now that we know who's signed in — these
      // providers are created at app startup before auth resolves, so their
      // first load runs against no user and silently no-ops. Each provider
      // swallows its own sync errors internally, but we also guard here so
      // that even an unexpected failure can never block navigation the way
      // it used to (auth would succeed, then the whole screen would just
      // sit there because one of these throw).
      if (mounted) {
        try {
          await Future.wait([
            context.read<CustomizationProvider>().reload(),
            context.read<FocusProvider>().reload(),
            context.read<SettingsProvider>().reload(),
            context.read<ThemeProvider>().reload(),
          ]);
        } catch (e) {
          print('Post-login data reload error: $e');
        }
      }

      // If successful, navigate to the main app shell
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RootShell()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? "Authentication failed. Please try again.");
    } catch (e) {
      _showErrorSnackBar("An unexpected error occurred.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3C7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branding
                const Icon(
                  Icons.hexagon_outlined,
                  size: 64,
                  color: Color(0xFFD4A340),
                ),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'Welcome Back' : 'Join the Hive',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A3A3A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Log in to continue your focus journey.'
                      : 'Create an account to track your progress.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 48),

                // Input Fields
                if (!_isLogin)
                  _buildTextField(
                    hintText: 'Full Name', 
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                if (!_isLogin) const SizedBox(height: 16),
                
                _buildTextField(
                  hintText: 'Email Address', 
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                ),
                
                const SizedBox(height: 32),

                // Main Auth Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAuthForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A3A3A),
                      disabledBackgroundColor: const Color(0xFF3A3A3A).withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Toggle Login/Signup State
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? "Don't have an account? "
                          : "Already have an account? ",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _emailController.clear();
                          _passwordController.clear();
                          _nameController.clear();
                        });
                      },
                      child: Text(
                        _isLogin ? "Sign Up" : "Login",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD4A340),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
//buildTextField 
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.outfit(color: const Color(0xFFAFAFAF)),
        prefixIcon: Icon(icon, color: const Color(0xFFB5A27A)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}   
