import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  void _placeOrder(CartProvider cart) async {
    // التحقق من أن العميل أدخل كل البيانات
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال جميع البيانات')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // تحويل المنتجات في السلة إلى قائمة لتخزينها في فايربيز
      final itemsList = cart.items.values.map((item) => {
        'productId': item.id,
        'title': item.title,
        'quantity': item.quantity,
        'price': item.price,
      }).toList();

      // إرسال الطلب إلى فايربيز في مجموعة orders
      await FirebaseFirestore.instance.collection('orders').add({
        'customerName': _nameController.text,
        'customerPhone': _phoneController.text,
        'customerAddress': _addressController.text,
        'totalAmount': cart.totalAmount, 'userId': FirebaseAuth.instance.currentUser?.uid ?? 'guest',
        'items': itemsList,
        'status': 'قيد المراجعة',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // تفريغ السلة وإغلاق النافذة
      cart.clearCart();
      if (!mounted) return;
      Navigator.pop(context); 
      
      // إظهار رسالة النجاح
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تم الطلب بنجاح! 🥳', style: TextStyle(color: Colors.deepOrange)),
          content: const Text('وصلنا طلبك وسنقوم بتحضير كنافتك اللذيذة فوراً.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text('حسناً', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold))
            )
          ],
        )
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $error')));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // دالة لفتح نافذة إدخال بيانات العميل
  void _showCheckoutSheet(CartProvider cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // لتجنب تغطية الكيبورد للحقول
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom, 
          top: 20, left: 20, right: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('بيانات التوصيل', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const SizedBox(height: 15),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.deepOrange)
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: () => _placeOrder(cart),
                  child: const Text('إرسال الطلب', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('السلة فارغة، أضف بعض الكنافة اللذيذة!', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      var item = cart.items.values.toList()[index];
                      var productId = cart.items.keys.toList()[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.white,
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.fastfood, color: Colors.white)),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('الكمية: ${item.quantity} x ${item.price} ج'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              cart.removeItem(productId);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, offset: const Offset(0, -2), blurRadius: 10)],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الإجمالي', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          Text('${cart.totalAmount} ج', style: const TextStyle(color: Colors.deepOrange, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => _showCheckoutSheet(cart), // تم ربط الزر هنا
                        child: const Text('تأكيد الطلب', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
