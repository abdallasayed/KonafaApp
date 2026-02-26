import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  void _orderOffer(BuildContext context, Map<String, dynamic> offer) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('طلب عرض: ${offer['title']}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم')),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) return;
              
              await FirebaseFirestore.instance.collection('orders').add({
                'userId': FirebaseAuth.instance.currentUser?.uid ?? 'guest',
                'storeId': offer['storeId'], // إرسال الطلب للتاجر صاحب العرض فقط!
                'customerName': nameController.text,
                'customerPhone': phoneController.text,
                'customerAddress': addressController.text,
                'totalAmount': 0.0, // يمكن تحديثه لاحقاً برقم إذا ربطنا العرض بسعر
                'status': 'قيد المراجعة',
                'createdAt': FieldValue.serverTimestamp(),
                'items': [
                  {
                    'title': offer['title'],
                    'quantity': 1,
                    'price': 0.0,
                    'isOffer': true, // إرسال إشارة للتاجر بأن هذا (عرض خاص)
                  }
                ]
              });
              
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب العرض للتاجر بنجاح!')));
            },
            child: const Text('تأكيد الطلب', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العروض الحصرية', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.white, elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('offers').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا توجد عروض حالياً'));

          final offers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              var offer = offers[index].data() as Map<String, dynamic>;
              String storeName = offer['storeName'] ?? 'متجر مميز';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // إظهار اسم المتجر أعلى العرض
                      Row(
                        children: [
                          const Icon(Icons.storefront, color: Colors.deepOrange, size: 20),
                          const SizedBox(width: 8),
                          Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.2), child: const Icon(Icons.local_offer, color: Colors.orange)),
                        title: Text(offer['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(offer['description'] ?? '', style: const TextStyle(fontSize: 14)),
                      ),
                      // زر الطلب
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () => _orderOffer(context, offer),
                          icon: const Icon(Icons.shopping_bag, size: 18, color: Colors.white),
                          label: const Text('اطلب العرض', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
