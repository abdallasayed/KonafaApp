import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'store_menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('الرئيسية', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('اختر متجرك المفضل', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // جلب المتاجر النشطة فقط
              stream: FirebaseFirestore.instance.collection('stores').where('isActive', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا توجد متاجر متاحة حالياً'));

                final stores = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    var store = stores[index].data() as Map<String, dynamic>;
                    String storeId = stores[index].id;

                    return GestureDetector(
                      onTap: () {
                        // الانتقال لشاشة منيو المتجر
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => StoreMenuScreen(storeId: storeId, storeName: store['storeName']),
                        ));
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.store, size: 40, color: Colors.deepOrange),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  store['storeName'] ?? 'متجر غير معروف',
                                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
