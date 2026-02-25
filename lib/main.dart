import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/main_screen.dart';

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
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'كنافه بالقشطه',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100)),
          scaffoldBackgroundColor: Colors.grey[50],
          useMaterial3: true,
          fontFamily: 'Cairo',
        ),
        home: const MainScreen(),
      ),
    );
  }
}
