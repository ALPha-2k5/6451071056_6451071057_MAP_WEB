import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/customer_model.dart';

class SeedService {
  final _db = FirebaseFirestore.instance;

  Future<void> seedAll() async {
    await _clearCollection('categories');
    await _clearCollection('products');
    await _clearCollection('orders');
    await _clearCollection('users');

    await seedCategories();
    await seedCustomers();
    await seedProducts();
    await seedOrders();
  }

  Future<void> _clearCollection(String collectionPath) async {
    final snapshot = await _db.collection(collectionPath).get();
    for (var doc in snapshot.docs) {
      try {
        await doc.reference.delete();
      } catch (_) {}
    }
  }

  Future<void> seedCategories() async {
    final categories = [
      CategoryModel(
        id: 'cat_1',
        name: 'Trái Cây Nhập Khẩu',
        imageURL:
            'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?q=80&w=800&auto=format&fit=crop',
        isActive: true,
        isFeatured: true,
        priority: 1,
        numberOfProducts: 0,
        viewCount: 150,
        createdBy: 'admin',
        updatedBy: 'admin',
      ),
      CategoryModel(
        id: 'cat_2',
        name: 'Trái Cây Theo Mùa',
        imageURL:
            'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?q=80&w=800&auto=format&fit=crop',
        isActive: true,
        isFeatured: true,
        priority: 2,
        numberOfProducts: 0,
        viewCount: 250,
        createdBy: 'admin',
        updatedBy: 'admin',
      ),
      CategoryModel(
        id: 'cat_3',
        name: 'Giỏ Quà Trái Cây',
        imageURL:
            'https://images.unsplash.com/photo-1576021182211-9ea8dced3690?q=80&w=800&auto=format&fit=crop',
        isActive: true,
        isFeatured: false,
        priority: 3,
        numberOfProducts: 0,
        viewCount: 120,
        createdBy: 'admin',
        updatedBy: 'admin',
      ),
    ];

    for (var cat in categories) {
      await _db.collection('categories').doc(cat.id).set(cat.toMap());
    }
  }

  Future<void> seedCustomers() async {
    final customers = [
      CustomerModel(
        id: 'user_1',
        firstName: 'Nguyễn',
        lastName: 'Văn A',
        email: 'vana@gmail.com',
        phone: '0987654321',
        username: 'vana',
        gender: 'Nam',
        createdAt: DateTime.now(),
      ),
      CustomerModel(
        id: 'user_2',
        firstName: 'Trần',
        lastName: 'Thị B',
        email: 'thib@gmail.com',
        phone: '0123456789',
        username: 'thib',
        gender: 'Nữ',
        createdAt: DateTime.now(),
      ),
    ];

    for (var cus in customers) {
      await _db.collection('users').doc(cus.id).set({
        'firstName': cus.firstName,
        'lastName': cus.lastName,
        'email': cus.email,
        'phone': cus.phone,
        'username': cus.username,
        'gender': cus.gender,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> seedProducts() async {
    final products = [
      ProductModel(
        id: 'prod_1',
        title: 'Táo Fuji Nhật Bản 1kg',
        price: 180000,
        thumbnail:
            'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?q=80&w=800&auto=format&fit=crop',
        stock: 50,
        categoryIds: ['cat_1'],
        isActive: true,
        isFeatured: true,
        soldQuantity: 15,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: 'prod_2',
        title: 'Dâu Tây Mộc Châu Hộp 500g',
        price: 150000,
        thumbnail:
            'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?q=80&w=800&auto=format&fit=crop',
        stock: 30,
        categoryIds: ['cat_2'],
        isActive: true,
        isFeatured: true,
        soldQuantity: 10,
        createdAt: DateTime.now(),
      ),
    ];

    for (var prod in products) {
      await _db.collection('products').doc(prod.id).set(prod.toMap());
    }
  }

  Future<void> seedOrders() async {
    final orders = [
      {
        'id': 'ORD1001',
        'userId': 'user_1',
        'products': [
          {'productId': 'prod_1', 'quantity': 1, 'price': 180000},
        ],
        'subTotal': 180000,
        'totalAmount': 180000,
        'orderStatus': 'delivered',
        'paymentStatus': 'paid',
        'paymentMethod': 'Credit Card',
        'itemCount': 1,
        'orderDate': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'shippingAddress': {'city': 'Hồ Chí Minh', 'street': 'Quận 1'},
      },
      {
        'id': 'ORD1002',
        'userId': 'user_2',
        'products': [
          {'productId': 'prod_2', 'quantity': 1, 'price': 150000},
        ],
        'subTotal': 150000,
        'totalAmount': 150000,
        'orderStatus': 'pending',
        'paymentStatus': 'pending',
        'paymentMethod': 'COD',
        'itemCount': 1,
        'orderDate': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'shippingAddress': {'city': 'Hà Nội', 'street': 'Hoàn Kiếm'},
      },
    ];

    for (var order in orders) {
      await _db.collection('orders').add(order);
    }
  }
}
