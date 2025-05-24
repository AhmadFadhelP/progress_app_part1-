// lib/screen/login.dart
import 'package:aplikasiku/screen/signup.dart';
import 'package:flutter/material.dart';
import 'package:aplikasiku/service/auth_service.dart'; // Impor AuthService Anda
import 'dashboard.dart'; // Impor DashboardScreen Anda

// Sebaiknya main() dan MyApp berada di lib/main.dart
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Login Figma',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light().copyWith(
//         scaffoldBackgroundColor: const Color(0xFFEEEEEE),
//       ),
//       home: const LoginScreen(),
//     );
//   }
// }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login berhasil! Selamat datang ${user.email}')),
        );
        // Navigasi ke DashboardScreen dan hapus semua rute sebelumnya
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (Route<dynamic> route) => false, // Menghapus semua rute sebelumnya
          );
        }
      } else {
        // AuthService akan mengembalikan null jika terjadi FirebaseAuthException
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal. Periksa kembali email dan password Anda.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) { // Pastikan widget masih di tree
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE), // Menggunakan warna dari theme MyApp
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: _isLoading ? null : () {
                    // Cek apakah bisa pop, jika tidak (misalnya ini halaman pertama)
                    // mungkin tidak melakukan apa-apa atau navigasi ke halaman tertentu
                    if (Navigator.canPop(context)) {
                       Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26, // Warna bisa disesuaikan
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700, // Disesuaikan dengan signup
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Silakan masukkan email dan password Anda', // Teks disesuaikan
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54), // Disesuaikan
              ),
              const SizedBox(height: 40),

              // Email Field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan Email Anda',
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.blue.shade400),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // Menghilangkan border default
                  ),
                  enabledBorder: OutlineInputBorder( // Border saat tidak fokus
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFE1E1E1), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder( // Border saat fokus
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Password Field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Masukkan Password Anda',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade400),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFE1E1E1), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Mengurangi jarak sedikit
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _isLoading ? null : () {
                    // TODO: Implementasi Lupa Password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Lupa Password belum diimplementasikan.')),
                    );
                  },
                  child: const Text(
                    'Lupa Password ?',
                    style: TextStyle(fontSize: 13, color: Color(0xFF648DDB), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Masuk
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50, // Disesuaikan dengan signup
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500, // Disesuaikan
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Disesuaikan
                          ),
                          elevation: 3,
                        ),
                        onPressed: _performLogin,
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 17, // Disesuaikan
                            fontWeight: FontWeight.w500, // Disesuaikan
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24), // Disesuaikan

              // Pilihan Mendaftar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum Punya Akun ? ',
                    style: TextStyle(fontSize: 14, color: Colors.black54), // Disesuaikan
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      'Mendaftar disini',
                      style: TextStyle(
                        fontSize: 14, // Disesuaikan
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700, // Disesuaikan
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Opsi Login Lain (Placeholder)
              const Text(
                'atau masuk dengan',
                style: TextStyle(fontSize: 13, color: Colors.black54), // Disesuaikan
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Image.asset('assets/icons/google_icon.png', height: 20, width: 20), // Ganti dengan path icon google Anda
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white, // Warna khas Google
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300)
                  ),
                  minimumSize: const Size(220, 45), // Ukuran disesuaikan
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : () {
                  // TODO: Implementasi Google sign in
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login dengan Google belum diimplementasikan.')),
                  );
                },
                label: const Text('Masuk dengan Google', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              // const SizedBox(height: 12),
              // ElevatedButton( // Tombol Facebook bisa dihilangkan jika tidak prioritas
              //   style: ElevatedButton.styleFrom(
              //     foregroundColor: Colors.black,
              //     backgroundColor: const Color(0xFFD9D9D9),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     minimumSize: const Size(180, 31),
              //   ),
              //   onPressed: () {
              //     // Facebook sign in logic
              //   },
              //   child: const Text('Masuk dengan Facebook'),
              // ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}