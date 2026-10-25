import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const KasirBisaApp());
}

// ============================================================
// KASIR BISA — HIGH-FIDELITY PROTOTYPE
// Alur:
// Gambar 1: Login -> Kasir -> Sidebar -> fitur pendukung
// Gambar 2: Scanner -> Database -> Ditemukan/Tidak ditemukan
//           -> Tambah Produk -> Keranjang -> Pembayaran -> Transaksi
// Gambar 3: Transaksi -> Data Penjualan -> Laporan -> Smart Insight
//           Data Produk -> Katalog Digital -> BISA JUALAN
// ============================================================

// ============================================================
// APP
// ============================================================

class KasirBisaApp extends StatelessWidget {
  const KasirBisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KASIR BISA',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: const LoginPage(),
    );
  }
}

// ============================================================
// HELPER
// ============================================================

String rupiah(int value) {
  final text = value.abs().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(text[i]);
  }

  return value < 0 ? '-Rp ${buffer.toString()}' : 'Rp ${buffer.toString()}';
}

int parseMoney(String value) {
  return int.tryParse(
        value
            .replaceAll('.', '')
            .replaceAll(',', '')
            .replaceAll('Rp', '')
            .trim(),
      ) ??
      0;
}

// ============================================================
// MODEL
// ============================================================

class Product {
  String name;
  int price;
  int stock;
  String barcode;
  String category;

  Product({
    required this.name,
    required this.price,
    required this.stock,
    required this.barcode,
    required this.category,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get subtotal => product.price * quantity;
}

class SaleTransaction {
  final DateTime date;
  final List<CartItem> items;
  final int total;
  final int payment;
  final int change;

  SaleTransaction({
    required this.date,
    required this.items,
    required this.total,
    required this.payment,
    required this.change,
  });
}

// ============================================================
// DATA PROTOTYPE
// ============================================================

final List<Product> products = [
  Product(
    name: 'Indomie Goreng',
    price: 3500,
    stock: 35,
    barcode: '899999999001',
    category: 'Makanan',
  ),
  Product(
    name: 'Teh Botol',
    price: 5000,
    stock: 24,
    barcode: '899999999002',
    category: 'Minuman',
  ),
  Product(
    name: 'Kopi Sachet',
    price: 2500,
    stock: 42,
    barcode: '899999999003',
    category: 'Minuman',
  ),
  Product(
    name: 'Air Mineral',
    price: 3000,
    stock: 50,
    barcode: '899999999004',
    category: 'Minuman',
  ),
  Product(
    name: 'Roti Coklat',
    price: 7000,
    stock: 12,
    barcode: '899999999005',
    category: 'Makanan',
  ),
  Product(
    name: 'Keripik Pedas',
    price: 8000,
    stock: 18,
    barcode: '899999999006',
    category: 'Snack',
  ),
];

final List<SaleTransaction> sales = [];

// ============================================================
// LOGIN
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscure = true;

  void masuk() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const KasirPage()),
    );
  }

  void daftar() {
    final usahaController = TextEditingController();
    final namaController = TextEditingController();
    final waController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Buat Akun KASIR BISA'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usahaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Usaha / UMKM',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pengguna',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: waController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor WhatsApp',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (usahaController.text.trim().isEmpty ||
                    namaController.text.trim().isEmpty ||
                    waController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Akun berhasil dibuat. Silakan masuk ke KASIR BISA.',
                    ),
                  ),
                );
              },
              child: const Text('Daftar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'KASIR BISA',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Kasir sederhana untuk usaha kamu',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nama / Nomor WhatsApp',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'PIN / Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => obscure = !obscure);
                          },
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: masuk,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'MASUK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: daftar,
                      child: const Text('Belum punya akun? Daftar'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Offline • Cepat • Mudah • UMKM',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// KASIR UTAMA
// ============================================================

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final List<CartItem> cart = [];

  // Controller scanner: semua format barcode diaktifkan (paling toleran).
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool barcodeLock = false;

  // Info untuk pengujian: barcode terakhir yang terbaca kamera
  String lastRead = '-';

  // Zoom kamera (0.0 - 1.0). Sedikit zoom membantu fokus pada barcode kecil.
  double _zoom = 0.0;

  int get total => cart.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItems => cart.fold(0, (sum, item) => sum + item.quantity);

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // ----------------------------------------------------------
  // SCANNER -> DATABASE
  // ----------------------------------------------------------

  void onBarcodeDetected(BarcodeCapture capture) {
    if (!mounted) return;

    final code = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .firstWhere((c) => c.isNotEmpty, orElse: () => '');

    if (code.isEmpty) return;

    // Tampilkan hasil bacaan agar mudah dicek saat pengujian
    setState(() => lastRead = code);

    if (barcodeLock) return;
    prosesBarcode(code);
  }

  // Dipakai oleh scanner kamera DAN input manual
  void prosesBarcode(String code) {
    barcodeLock = true;

    final index = products.indexWhere((p) => p.barcode == code);

    if (index >= 0) {
      final product = products[index];

      if (product.stock <= 0) {
        _snack('${product.name} sedang tidak memiliki stok.');
      } else {
        tambahProduk(product);
        _snack('${product.name} ditemukan dan masuk keranjang.');
      }

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) barcodeLock = false;
      });
    } else {
      showAddScannedProductDialog(code).then((_) {
        if (mounted) barcodeLock = false;
      });
    }
  }

  // Cadangan jika kamera sulit membaca: ketik angka barcode
  void inputBarcodeManual() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Input Barcode'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Angka barcode',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = controller.text.trim();
                if (code.isEmpty) return;
                Navigator.pop(dialogContext);
                if (!barcodeLock) prosesBarcode(code);
              },
              child: const Text('Cari'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------
  // PRODUK DITEMUKAN -> KERANJANG
  // ----------------------------------------------------------

  void tambahProduk(Product product) {
    setState(() {
      final index = cart.indexWhere(
        (item) => item.product.barcode == product.barcode,
      );

      if (index >= 0) {
        if (cart[index].quantity < product.stock) {
          cart[index].quantity++;
        }
      } else {
        cart.add(CartItem(product: product));
      }
    });
  }

  // ----------------------------------------------------------
  // BARCODE TIDAK DITEMUKAN -> TAMBAH PRODUK
  // Barcode otomatis berasal dari hasil scanner.
  // Pengguna TIDAK menginput barcode.
  // ----------------------------------------------------------

  Future<void> showAddScannedProductDialog(String scannedBarcode) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '1');
    final quantityController = TextEditingController(text: '1');

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Expanded(child: Text('Produk Belum Ditemukan')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Barcode terdeteksi: $scannedBarcode',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    hintText: 'Contoh: Bakwan',
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga Jual',
                    hintText: 'Contoh: 2000',
                    prefixText: 'Rp ',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stok Awal',
                    hintText: 'Contoh: 20',
                    prefixIcon: const Icon(Icons.inventory_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Dibeli',
                    hintText: 'Jumlah untuk transaksi saat ini',
                    prefixIcon: const Icon(Icons.shopping_cart_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final name = nameController.text.trim();
                final price = parseMoney(priceController.text);
                final stock = int.tryParse(stockController.text) ?? 0;
                final quantity = int.tryParse(quantityController.text) ?? 0;

                if (name.isEmpty || price <= 0 || stock <= 0 || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Nama, harga, stok, dan jumlah harus diisi dengan benar.',
                      ),
                    ),
                  );
                  return;
                }

                if (quantity > stock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Jumlah dibeli tidak boleh melebihi stok awal.',
                      ),
                    ),
                  );
                  return;
                }

                final product = Product(
                  name: name,
                  price: price,
                  stock: stock,
                  barcode: scannedBarcode,
                  category: 'Umum',
                );

                setState(() {
                  products.add(product);
                  cart.add(CartItem(product: product, quantity: quantity));
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$name disimpan ke data produk dan masuk keranjang.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan & Masukkan'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------
  // TAMBAH PRODUK MANUAL DARI HALAMAN KASIR
  // ----------------------------------------------------------

  void showManualDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '1');
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Expanded(child: Text('Tambah Produk Manual')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Jual',
                    prefixText: 'Rp ',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok Awal',
                    prefixIcon: Icon(Icons.inventory_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Dibeli',
                    prefixIcon: Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = parseMoney(priceController.text);
                final stock = int.tryParse(stockController.text) ?? 0;
                final quantity = int.tryParse(quantityController.text) ?? 0;

                if (name.isEmpty ||
                    price <= 0 ||
                    stock <= 0 ||
                    quantity <= 0 ||
                    quantity > stock) {
                  return;
                }

                final barcode =
                    'MANUAL-${DateTime.now().millisecondsSinceEpoch}';

                final product = Product(
                  name: name,
                  price: price,
                  stock: stock,
                  barcode: barcode,
                  category: 'Umum',
                );

                setState(() {
                  products.add(product);
                  cart.add(CartItem(product: product, quantity: quantity));
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------
  // JUMLAH KERANJANG
  // ----------------------------------------------------------

  void tambahJumlah(int index) {
    setState(() {
      final item = cart[index];

      if (item.quantity < item.product.stock) {
        item.quantity++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jumlah melebihi stok tersedia.')),
        );
      }
    });
  }

  void kurangiJumlah(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    });
  }

  // ----------------------------------------------------------
  // PEMBAYARAN
  // ----------------------------------------------------------

  void bukaPembayaran() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keranjang masih kosong.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          total: total,
          cart: cart,
          onSuccess: (payment) {
            final transactionItems = cart
                .map(
                  (item) =>
                      CartItem(product: item.product, quantity: item.quantity),
                )
                .toList();

            final change = payment - total;

            for (final item in cart) {
              item.product.stock -= item.quantity;
            }

            sales.add(
              SaleTransaction(
                date: DateTime.now(),
                items: transactionItems,
                total: total,
                payment: payment,
                change: change,
              ),
            );

            setState(() {
              cart.clear();
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SuccessPage(total: total, change: change),
              ),
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KASIR BISA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kasir sederhana untuk usaha kamu',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          const Icon(Icons.notifications_none, color: Colors.grey),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.person, color: Color(0xFF1565C0)),
          ),
          const SizedBox(width: 12),
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu),
              );
            },
          ),
        ],
      ),
      drawer: const KasirDrawer(),
      body: Column(
        children: [
          // ------------------------------------------------
          // AREA KAMERA SCANNER
          // Seluruh frame kamera dipindai (tanpa scanWindow)
          // agar barcode terbaca di posisi mana pun.
          // ------------------------------------------------
          Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            height: 260,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: onBarcodeDetected,
                ),
                const Positioned(
                  top: 11,
                  child: Text(
                    'Arahkan kamera ke barcode (jarak 10-20 cm)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                  ),
                ),
                Container(
                  width: 260,
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  right: 60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Terbaca: $lastRead',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () => _scannerController.toggleTorch(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.zoom_in, size: 20, color: Colors.grey),
                Expanded(
                  child: Slider(
                    value: _zoom,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() => _zoom = value);
                      _scannerController.setZoomScale(value);
                    },
                  ),
                ),
                TextButton.icon(
                  onPressed: inputBarcodeManual,
                  icon: const Icon(Icons.keyboard, size: 18),
                  label: const Text('Ketik'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Keranjang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '$totalItems item',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: cart.isEmpty
                ? _keranjangKosong()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 7),
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      rupiah(item.product.price),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => kurangiJumlah(index),
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 20,
                                ),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => tambahJumlah(index),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                ),
                              ),
                              SizedBox(
                                width: 75,
                                child: Text(
                                  rupiah(item.subtotal),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: SizedBox(
              width: double.infinity,
              height: 39,
              child: OutlinedButton.icon(
                onPressed: showManualDialog,
                icon: const Icon(Icons.add_circle_outline, size: 19),
                label: const Text('Tambah Produk Manual'),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Belanja',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        rupiah(total),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: cart.isEmpty ? null : bukaPembayaran,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('LANJUT BAYAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
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

  Widget _keranjangKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          const Text(
            'Keranjang masih kosong',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 3),
          const Text(
            'Scan barang atau tambahkan manual',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SIDEBAR — STRUKTUR NAVIGASI KESELURUHAN
// ============================================================

class KasirDrawer extends StatelessWidget {
  const KasirDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF1565C0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.storefront,
                    color: Color(0xFF1565C0),
                    size: 32,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'KASIR BISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _item(context, Icons.point_of_sale, 'Kasir', const KasirPage()),
                _item(
                  context,
                  Icons.inventory_2_outlined,
                  'Data Produk',
                  const ProductsPage(),
                ),
                _item(
                  context,
                  Icons.bar_chart,
                  'Laporan Penjualan',
                  const ReportPage(),
                ),
                _item(
                  context,
                  Icons.auto_awesome,
                  'Smart Insight',
                  const SmartInsightPage(),
                ),
                _item(
                  context,
                  Icons.shopping_bag_outlined,
                  'Katalog Digital',
                  const CatalogPage(),
                ),
                _item(
                  context,
                  Icons.public,
                  'BISA JUALAN',
                  const OnlineSellingPage(),
                ),
                _item(
                  context,
                  Icons.fact_check_outlined,
                  'Hasil Pengujian',
                  const TestingPage(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        if (page is KasirPage) return;

        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}

// ============================================================
// DATA PRODUK
// ============================================================

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String search = '';

  void tambahProduk() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixText: 'Rp ',
                ),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = parseMoney(priceController.text);
                final stock = int.tryParse(stockController.text) ?? 0;

                if (name.isEmpty || price <= 0 || stock <= 0) {
                  return;
                }

                setState(() {
                  products.add(
                    Product(
                      name: name,
                      price: price,
                      stock: stock,
                      barcode:
                          'MANUAL-${DateTime.now().millisecondsSinceEpoch}',
                      category: 'Umum',
                    ),
                  );
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((p) {
      return p.name.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Produk'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tambahProduk,
        icon: const Icon(Icons.add),
        label: const Text('Produk'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              onChanged: (value) {
                setState(() => search = value);
              },
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final p = filtered[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.inventory_2, color: Color(0xFF1565C0)),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${p.category} • Stok ${p.stock}\n'
                      'Barcode: ${p.barcode}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      rupiah(p.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PEMBAYARAN
// ============================================================

class PaymentPage extends StatefulWidget {
  final int total;
  final List<CartItem> cart;
  final void Function(int payment) onSuccess;

  const PaymentPage({
    super.key,
    required this.total,
    required this.cart,
    required this.onSuccess,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final moneyController = TextEditingController();
  int payment = 0;

  int get change => payment - widget.total;

  void quickMoney(int value) {
    setState(() {
      payment = value;
      moneyController.text = value.toString();
    });
  }

  void process() {
    if (payment < widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran belum mencukupi.')),
      );
      return;
    }

    widget.onSuccess(payment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'TOTAL PEMBAYARAN',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    rupiah(widget.total),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: moneyController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  payment = parseMoney(value);
                });
              },
              decoration: InputDecoration(
                labelText: 'Uang diterima',
                prefixText: 'Rp ',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _moneyButton(widget.total),
                _moneyButton(50000),
                _moneyButton(100000),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: change >= 0
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    change >= 0 ? 'KEMBALIAN' : 'UANG KURANG',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    rupiah(change.abs()),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: change >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: process,
                icon: const Icon(Icons.check_circle),
                label: const Text('SELESAIKAN TRANSAKSI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moneyButton(int value) {
    return OutlinedButton(
      onPressed: () => quickMoney(value),
      child: Text(rupiah(value)),
    );
  }
}

// ============================================================
// TRANSAKSI BERHASIL
// ============================================================

class SuccessPage extends StatelessWidget {
  final int total;
  final int change;

  const SuccessPage({super.key, required this.total, required this.change});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 70,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 7),
              Text(
                'Total transaksi: ${rupiah(total)}\n'
                'Kembalian: ${rupiah(change)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const KasirPage()),
                      (route) => false,
                    );
                  },
                  child: const Text('KEMBALI KE KASIR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LAPORAN PENJUALAN
// Gambar 3: Data Penjualan -> Laporan
// ============================================================

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  int get totalSales =>
      sales.fold(0, (sum, transaction) => sum + transaction.total);

  int get totalTransactions => sales.length;

  int get totalProducts => sales.fold(
    0,
    (sum, transaction) =>
        sum +
        transaction.items.fold(0, (itemSum, item) => itemSum + item.quantity),
  );

  @override
  Widget build(BuildContext context) {
    final displaySales = sales.isEmpty ? 1250000 : totalSales;
    final displayTransactions = sales.isEmpty ? 48 : totalTransactions;
    final displayProducts = sales.isEmpty ? 137 : totalProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Data Penjualan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ringkasan transaksi yang menjadi dasar penyusunan laporan dan analisis usaha.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 14),
          _card(Icons.point_of_sale, 'Penjualan', rupiah(displaySales)),
          _card(
            Icons.receipt_long,
            'Jumlah Transaksi',
            '$displayTransactions transaksi',
          ),
          _card(Icons.inventory_2, 'Produk Terjual', '$displayProducts produk'),
          _card(
            Icons.trending_up,
            'Rata-rata Transaksi',
            rupiah(
              displayTransactions == 0
                  ? 0
                  : displaySales ~/ displayTransactions,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Penjualan 7 Hari',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _bar('Sen', 55),
                        _bar('Sel', 80),
                        _bar('Rab', 65),
                        _bar('Kam', 95),
                        _bar('Jum', 70),
                        _bar('Sab', 100),
                        _bar('Min', 85),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('Download Laporan'),
          ),
        ],
      ),
    );
  }

  Widget _card(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F2FD),
          child: Icon(icon, color: const Color(0xFF1565C0)),
        ),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _bar(String day, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 5),
        Text(day, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

// ============================================================
// SMART INSIGHT
// Gambar 3: Laporan -> Smart Insight
// ============================================================

class SmartInsightPage extends StatelessWidget {
  const SmartInsightPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSales = sales.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Insight'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 35),
                SizedBox(height: 12),
                Text(
                  'Smart Insight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Informasi ringkas berdasarkan data penjualan untuk membantu pemilik usaha memahami kondisi usahanya.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _insight(
            Icons.trending_up,
            'Produk Terlaris',
            hasSales
                ? _produkTerlaris()
                : 'Indomie Goreng menjadi produk yang paling banyak terjual.',
          ),
          _insight(Icons.warning_amber_rounded, 'Stok Menipis', _stokMenipis()),
          _insight(
            Icons.lightbulb_outline,
            'Saran Penjualan',
            'Pertimbangkan pembuatan paket promo berdasarkan produk yang sering dibeli.',
          ),
          _insight(
            Icons.access_time,
            'Jam Ramai',
            'Data waktu transaksi dapat digunakan untuk mengidentifikasi periode penjualan dengan aktivitas tertinggi.',
          ),
        ],
      ),
    );
  }

  String _produkTerlaris() {
    final Map<Product, int> counts = {};

    for (final transaction in sales) {
      for (final item in transaction.items) {
        counts[item.product] = (counts[item.product] ?? 0) + item.quantity;
      }
    }

    if (counts.isEmpty) {
      return 'Belum tersedia data transaksi yang memadai.';
    }

    final best = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);

    return '${best.key.name} menjadi produk dengan jumlah penjualan tertinggi.';
  }

  String _stokMenipis() {
    final low = products.where((p) => p.stock <= 10).toList();

    if (low.isEmpty) {
      return 'Belum terdapat produk yang berada pada batas stok rendah.';
    }

    return '${low.first.name} memiliki stok ${low.first.stock} dan perlu diperhatikan.';
  }

  Widget _insight(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Icon(icon, color: const Color(0xFF1565C0), size: 31),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(description),
        ),
      ),
    );
  }
}

// ============================================================
// KATALOG DIGITAL
// Gambar 3: Data Produk -> Katalog Digital
// ============================================================

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Digital'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shopping_bag, color: Color(0xFF1565C0), size: 35),
                SizedBox(height: 10),
                Text(
                  'Katalog Produk',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Data produk digunakan sebagai sumber informasi katalog digital.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...products.map(
            (product) => Card(
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Color(0xFF1565C0),
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(product.category),
                trailing: Text(rupiah(product.price)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Bagikan Katalog'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BISA JUALAN
// Gambar 3: Katalog Digital -> BISA JUALAN
// ============================================================

class OnlineSellingPage extends StatelessWidget {
  const OnlineSellingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BISA JUALAN'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.public, color: Colors.white, size: 40),
                SizedBox(height: 12),
                Text(
                  'BISA JUALAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pemanfaatan katalog digital untuk memperkenalkan produk UMKM melalui kanal penjualan digital.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _channel(Icons.chat, 'WhatsApp', 'Bagikan katalog melalui WhatsApp.'),
          _channel(
            Icons.camera_alt,
            'Instagram',
            'Promosikan produk melalui media sosial.',
          ),
          _channel(
            Icons.shopping_bag,
            'Marketplace',
            'Siapkan produk untuk penjualan online.',
          ),
          _channel(
            Icons.link,
            'Link Katalog',
            'Bagikan satu tautan katalog kepada pelanggan.',
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_link),
              label: const Text('Hubungkan Kanal Penjualan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _channel(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F2FD),
          child: Icon(icon, color: const Color(0xFF1565C0)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ============================================================
// HASIL PENGUJIAN
// ============================================================

class TestingPage extends StatelessWidget {
  const TestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tests = [
      _TestItem('Login', 'Pengguna dapat masuk ke aplikasi.', Icons.login),
      _TestItem(
        'Scanner Barcode',
        'Barcode dapat dipindai dan dicocokkan dengan data produk.',
        Icons.qr_code_scanner,
      ),
      _TestItem(
        'Produk Tidak Ditemukan',
        'Produk baru dapat ditambahkan menggunakan barcode hasil pemindaian.',
        Icons.add_box_outlined,
      ),
      _TestItem(
        'Keranjang',
        'Jumlah produk dapat ditambah dan dikurangi.',
        Icons.shopping_cart_outlined,
      ),
      _TestItem(
        'Perhitungan Total',
        'Subtotal dan total belanja dihitung otomatis.',
        Icons.calculate_outlined,
      ),
      _TestItem(
        'Pembayaran',
        'Nominal pembayaran dapat dimasukkan.',
        Icons.payments_outlined,
      ),
      _TestItem(
        'Perhitungan Kembalian',
        'Kembalian dihitung berdasarkan total transaksi.',
        Icons.currency_exchange,
      ),
      _TestItem(
        'Data Produk',
        'Produk baru tersimpan pada data produk prototype.',
        Icons.inventory_2_outlined,
      ),
      _TestItem(
        'Laporan',
        'Data transaksi digunakan untuk ringkasan laporan penjualan.',
        Icons.bar_chart,
      ),
      _TestItem(
        'Smart Insight',
        'Informasi insight dapat ditampilkan berdasarkan data penjualan.',
        Icons.auto_awesome,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pengujian'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fact_check_outlined, color: Colors.white, size: 42),
                SizedBox(height: 12),
                Text(
                  'Pengujian Prototype',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'KASIR BISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Daftar fungsi yang diuji pada prototype aplikasi.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  icon: Icons.check_circle_outline,
                  title: 'Fitur Diuji',
                  value: '10',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  icon: Icons.pending_actions,
                  title: 'Status',
                  value: 'Prototype',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Status pada halaman ini merupakan tampilan pengujian prototype. Hasil akhir diisi berdasarkan pengujian langsung pada perangkat.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Daftar Skenario Pengujian',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...tests.map((test) => _testCard(test)),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Color(0xFF1565C0),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Catatan Pengujian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pengujian mencakup proses login, pemindaian barcode, penambahan produk baru, transaksi, pembayaran, pengelolaan produk, laporan, dan fitur pendukung.',
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _testCard(_TestItem test) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(test.icon, color: const Color(0xFF1565C0)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    test.description,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Siap Diuji',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestItem {
  final String title;
  final String description;
  final IconData icon;

  const _TestItem(this.title, this.description, this.icon);
}