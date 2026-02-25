import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العروض الحصرية', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0
      ),
      body: StreamBuilder<QuerySnapshot>(
        // قراءة العروض من قاعدة البيانات وترتيبها من الأحدث للأقدم
        stream: FirebaseFirestore.instance.collection('offers').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('لا توجد عروض حالياً، ترقبوا مفاجآتنا!', style: TextStyle(fontSize: 18, color: Colors.grey))
            );
          }

          final offers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              var offer = offers[index].data() as Map<String, dynamic>;
              
              // تغيير لون الأيقونة بشكل تبادلي ليعطي شكلاً جميلاً
              Color iconColor = index % 2 == 0 ? Colors.orange : Colors.green;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.2), 
                    child: Icon(Icons.local_offer, color: iconColor, size: 30)
                  ),
                  title: Text(offer['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(offer['description'] ?? '', style: const TextStyle(fontSize: 14, height: 1.5)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
