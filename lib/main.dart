import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> getUser() async {
  await Future.delayed(const Duration(seconds: 3));
  final text = await rootBundle.loadString('assets/user.json');
  return jsonDecode(text) as Map<String, dynamic>;
}

Future<List<dynamic>> getProducts() async {
  await Future.delayed(const Duration(seconds: 3));
  final text = await rootBundle.loadString('assets/products.json');
  return jsonDecode(text) as List<dynamic>;
}

Future<List<dynamic>> getOrders() async {
  await Future.delayed(const Duration(seconds: 3));
  final text = await rootBundle.loadString('assets/orders.json');
  return jsonDecode(text) as List<dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShopPage(),
    );
  }
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Map<String, dynamic>? user;
  List<dynamic> products = [];
  List<dynamic> orders = [];
  bool loading = false;
  String? error;

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = null;
      user = null;
      products = [];
      orders = [];
    });

    try {
      final results = await Future.wait<Object>([
        getUser(),
        getProducts(),
        getOrders(),
      ]);

      if (!mounted) return;
      setState(() {
        user = results[0] as Map<String, dynamic>;
        products = results[1] as List<dynamic>;
        orders = results[2] as List<dynamic>;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Не вдалося завантажити дані: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій магазин'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: loading ? null : loadData,
              child: const Text('Завантажити дані'),
            ),
            const SizedBox(height: 16),
            if (loading) const CircularProgressIndicator(),
            if (error != null) Text(
              error!,
              style: const TextStyle(color: Colors.red),
            ),
            if (user != null) ...[
              const Text('КОРИСТУВАЧ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Ім’я: ${user!['name']}'),
              Text('Email: ${user!['email']}'),
              Text('Місто: ${user!['city']}'),
              const SizedBox(height: 20),
              const Text('ТОВАРИ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              for (final p in products)
                Text('${p['name']} — ${p['price']} грн'),
              const SizedBox(height: 20),
              const Text('ЗАМОВЛЕННЯ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              for (final o in orders)
                Text('№${o['id']}: ${o['product']} × ${o['quantity']} — ${o['total']} грн'),
            ],
          ],
        ),
      ),
    );
  }
}
