import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLogin = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _submitAuthForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && (_nameController.text.isEmpty || _phoneController.text.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال جميع البيانات بشكل صحيح')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      if (_isLogin) {
        // تسجيل الدخول
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        // إنشاء حساب جديد
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        
        // حفظ بيانات المستخدم الإضافية في Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (error) {
      String message = 'حدث خطأ في تسجيل الدخول';
      if (error.code == 'weak-password') message = 'كلمة المرور ضعيفة جداً';
      else if (error.code == 'email-already-in-use') message = 'هذا الحساب موجود بالفعل';
      else if (error.code == 'user-not-found' || error.code == 'wrong-password') message = 'البريد أو كلمة المرور غير صحيحة';
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_pin, size: 80, color: Colors.orange.shade300),
                const SizedBox(height: 10),
                Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب جديد', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const SizedBox(height: 20),
                if (!_isLogin) ...[
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم بالكامل', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                ],
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder())),
                const SizedBox(height: 20),
                if (_isLoading) const CircularProgressIndicator(color: Colors.deepOrange)
                else ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _submitAuthForm,
                  child: Text(_isLogin ? 'دخول' : 'تسجيل', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? 'ليس لديك حساب؟ سجل الآن' : 'لديك حساب بالفعل؟ سجل دخول', style: const TextStyle(color: Colors.deepOrange)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
