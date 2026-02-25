import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول أولاً')));

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي السابقة', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.white, elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: user.uid).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا توجد طلبات سابقة'));
          
          final docs = snapshot.data!.docs;
          // ترتيب الطلبات من الأحدث للأقدم
          docs.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;
            var aTime = aData['createdAt'] as Timestamp?;
            var bTime = bData['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              var order = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text('الطلب رقم: ${docs[index].id.substring(0, 5).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الإجمالي: ${order['totalAmount']} ج\nالحالة: ${order['status'] ?? 'قيد المراجعة'}', style: const TextStyle(height: 1.5)),
                  trailing: const Icon(Icons.receipt_long, color: Colors.deepOrange, size: 30),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
