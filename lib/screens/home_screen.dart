import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: const Text('كنافه بالقشطه', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 24))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Text('ماذا تشتهي اليوم؟', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          SizedBox(
            height: 60,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').orderBy('sortOrder').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final categories = snapshot.data!.docs;
                if (categories.isNotEmpty && selectedCategoryId.isEmpty) {
                  Future.microtask(() => setState(() => selectedCategoryId = categories.first.id));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    var category = categories[index].data() as Map<String, dynamic>;
                    String docId = categories[index].id;
                    bool isSelected = selectedCategoryId == docId;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategoryId = docId),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(color: isSelected ? Colors.deepOrange : Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)]),
                        child: Center(child: Text(category['name'] ?? '', style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: selectedCategoryId.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('products').where('categoryId', isEqualTo: selectedCategoryId).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا توجد منتجات'));
                      final products = snapshot.data!.docs;
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 16, mainAxisSpacing: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var product = products[index].data() as Map<String, dynamic>;
                          String productId = products[index].id;
                          double price = (product['price'] ?? 0).toDouble();
                          String imageUrl = product['imageUrl'] ?? '';
                          return Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.orange.shade200))
                                          : Container(color: Colors.orange.shade50, child: Icon(Icons.fastfood, size: 40, color: Colors.orange.shade200)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('$price ج', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                                          GestureDetector(
                                            onTap: () {
                                              Provider.of<CartProvider>(context, listen: false).addItem(productId, product['name'], price);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت الإضافة للسلة: ${product['name']}'), duration: const Duration(seconds: 1)));
                                            },
                                            child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: Colors.white, size: 20)),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
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
