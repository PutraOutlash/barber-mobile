import 'package:flutter/material.dart';
import '../services/product_service.dart'; // Sesuaikan path-nya

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        // 1. Memaksa warna ikon (termasuk tombol back) menjadi Amber
        iconTheme: const IconThemeData(color: Colors.amber),

        title: const Text(
          "TOKO PRODUK",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),

        // 2. Menambahkan logo/ikon di pojok kanan
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined), // Logo Keranjang
            onPressed: () {
              // Nanti diisi aksi untuk membuka halaman keranjang
            },
          ),
          const SizedBox(width: 10), // Spasi sedikit di kanan
        ],
      ),
      // 🔥 DISINILAH KEAJAIBANNYA
      body: FutureBuilder<List<dynamic>>(
        future: ProductService.getProducts(), // Memanggil fungsi Fetch
        builder: (context, snapshot) {
          // 1. Jika masih loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          // 2. Jika terjadi error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          // 3. Jika data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada produk.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // 4. Jika sukses, tampilkan Grid
          var products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Menampilkan 2 kolom
              childAspectRatio: 0.7,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var item = products[index];
              return _buildProductCard(item);
            },
          );
        },
      ),
    );
  }

  // Widget untuk desain kotak produk
  Widget _buildProductCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: item['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(item['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item['image'] == null
                  ? const Center(child: Icon(Icons.image, color: Colors.grey))
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? "Produk",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Rp ${item['price']}",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Tombol Beli / Tambah ke Keranjang
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text(
                      "BELI",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
