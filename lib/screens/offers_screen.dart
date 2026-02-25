import 'package:flutter/material.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العروض الحصرية', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.white, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOfferCard('عرض التوفير', 'خصم 20% على الكنافة بالقشطة لفترة محدودة!', Icons.local_offer, Colors.orange),
          _buildOfferCard('توصيل مجاني', 'اطلب بأكثر من 200 جنيه واحصل على توصيل مجاني', Icons.delivery_dining, Colors.green),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String desc, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 30)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
