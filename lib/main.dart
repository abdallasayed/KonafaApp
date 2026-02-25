import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAegRWgOmfPF4IXwkGQlEmeCQC5ch6AxC8",
      authDomain: "konafa-app.firebaseapp.com",
      projectId: "konafa-app",
      storageBucket: "konafa-app.firebasestorage.app",
      messagingSenderId: "487013929710",
      appId: "1:487013929710:web:b2ef64c2dda93a3ba8d9ff",
    ),
  );
  
  runApp(const KonafaApp());
}

class KonafaApp extends StatelessWidget {
  const KonafaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'كنافه بالقشطه',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const CategoriesScreen(),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة كنافه بالقشطه', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد أقسام حالياً'));
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              var category = categories[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(category['name'] ?? 'بدون اسم', style: const TextStyle(fontSize: 20)),
                  subtitle: Text(category['isActive'] == true ? 'متاح' : 'غير متاح'),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
