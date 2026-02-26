import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _submitOrder(BuildContext context, CartProvider cart) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الطلب', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
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
              
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري إرسال الطلبات...')));

              // تجميع الطلبات بناءً على معرف المتجر (storeId)
              final cartItems = cart.items.values.toList();
              Map<String, List<CartItem>> ordersByStore = {};
              for (var item in cartItems) {
                if (ordersByStore.containsKey(item.storeId)) {
                  ordersByStore[item.storeId]!.add(item);
                } else {
                  ordersByStore[item.storeId] = [item];
                }
              }

              // إرسال طلب منفصل لكل متجر
              for (var storeId in ordersByStore.keys) {
                double storeTotal = 0;
                List<Map<String, dynamic>> itemsList = [];
                for(var item in ordersByStore[storeId]!){
                   storeTotal += (item.price * item.quantity);
                   itemsList.add({
                     'productId': item.id,
                     'title': item.title,
                     'quantity': item.quantity,
                     'price': item.price,
                     'isOffer': false,
                   });
                }
                
                await FirebaseFirestore.instance.collection('orders').add({
                  'userId': FirebaseAuth.instance.currentUser?.uid ?? 'guest',
                  'storeId': storeId, // إرسال الطلب لهذا المتجر فقط
                  'customerName': nameController.text,
                  'customerPhone': phoneController.text,
                  'customerAddress': addressController.text,
                  'totalAmount': storeTotal,
                  'status': 'قيد المراجعة',
                  'createdAt': FieldValue.serverTimestamp(),
                  'items': itemsList,
                });
              }

              cart.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلبات للتجار بنجاح!')));
            },
            child: const Text('تأكيد وإرسال', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, centerTitle: true),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Chip(label: Text('${cart.totalAmount} ج', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.deepOrange),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: cart.totalAmount <= 0 ? null : () => _submitOrder(context, cart),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('أطلب الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                var item = cart.items.values.toList()[i];
                var productId = cart.items.keys.toList()[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.deepOrange, child: Text('${item.price.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 14))),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('الإجمالي: ${(item.price * item.quantity)} ج'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${item.quantity} x', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => cart.removeItem(productId)),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
