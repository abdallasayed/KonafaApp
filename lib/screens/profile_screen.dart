import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      // StreamBuilder يراقب حالة المستخدم (مسجل دخول أم لا)
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }
          
          if (snapshot.hasData) {
            // المستخدم مسجل دخول
            final user = snapshot.data!;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                }
                
                var userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 50, backgroundColor: Colors.orangeAccent, child: Icon(Icons.person, size: 50, color: Colors.white)),
                      const SizedBox(height: 20),
                      Text(userData['name'] ?? 'عميل مميز', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(userData['phone'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 30),
                      ListTile(
                        leading: const Icon(Icons.history, color: Colors.deepOrange),
                        title: const Text('طلباتي السابقة', style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم برمجتها قريباً')));
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.exit_to_app, color: Colors.red),
                        title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        onTap: () => FirebaseAuth.instance.signOut(),
                      ),
                    ],
                  ),
                );
              }
            );
          }
          
          // المستخدم غير مسجل دخول (يعرض شاشة الدخول)
          return const AuthScreen();
        },
      ),
    );
  }
}
