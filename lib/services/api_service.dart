import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.39:3000", // your PC IP
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<List<dynamic>> getProducts() async {
    try {
      final response = await dio.get("/products");
      return response.data;
    } catch (e) {
      print("Dio error: $e");
      rethrow;
    }
  }

  //create product
  Future<void> createProduct(Map<String, dynamic> product) async {
    await dio.post(
      "/products",
      data: product,
    );
  }

  // Update product
  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    await dio.put("/products/$id", data: product);
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    await dio.delete("/products/$id");
  }

  Future<List<dynamic>> getCart(int userId) async {
    final response = await dio.get("/cart", queryParameters: {"userId": userId});
    return response.data;
  }

  Future<void> addToCart(Map<String, dynamic> cartItem) async {
    await dio.post("/cart", data: cartItem);
  }

  Future<void> removeFromCart(int cartItemId) async {
    await dio.delete("/cart/$cartItemId");
  }

  Future<void> clearCart(int userId) async {
    final cartItems = await getCart(userId);
    for (var item in cartItems) {
      await removeFromCart(item['id']);
    }
  }

  // Mock login using db.json
  Future<String> login(String email, String password) async {
    try {
      final response = await dio.get("/users");
      final users = response.data as List;

      final user = users.firstWhere(
            (u) => u['email'] == email && u['password'] == password,
        orElse: () => null,
      );

      if (user != null) {
        return "mock_token_${user['id']}"; // return fake token
      } else {
        throw Exception("Invalid credentials");
      }
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  // register user
  Future<String?> register(String email, String password) async {
    // check if user exists
    final res = await dio.get("/users", queryParameters: {"email": email});
    if ((res.data as List).isNotEmpty) return null;

    final newUser = {"email": email, "password": password};
    final createRes = await dio.post("/users", data: newUser);
    return createRes.data['id'].toString();
  }

  Future<List<Map<String, dynamic>>> searchProducts(
      String query, {
        int page = 1,
        int limit = 10,
      }) async {
    final response = await dio.get(
      "/products",
      queryParameters: {
        "q": query,
        "_page": page,
        "_limit": limit,
      },
      options: Options(
        headers: {"Cache-Control": "no-cache"},
      ),
    );

    // ensure each item is a Map<String, dynamic>
    final data = (response.data as List)
        .whereType<Map<String, dynamic>>()
        .toList();

    return data;
  }

  Future<Map<String, dynamic>> checkout(int userId, List<Map<String, dynamic>> cartItems) async {
    final data = {
      "userId": userId,
      "items": cartItems,
      "paymentMethod": "mock_card",
      "status": "pending",
    };
    final response = await dio.post("/orders", data: data);
    return response.data;
  }

  // TRIGGER WEBHOOK
  Future<Map<String, dynamic>> triggerWebhook(String orderId, String event) async {
    final int id = int.parse(orderId);
    // PATCH the order in json-server to update status
    final response = await dio.patch("/orders/$id", data: {"status": event});
    return response.data;
  }

  Future<List<dynamic>> getOrders(int userId) async {
    try {
      final response = await dio.get(
        "/orders",
        queryParameters: {"userId": userId},
        options: Options(
          headers: {"Cache-Control": "no-cache"},
          validateStatus: (status) => status! < 500,
        ),
      );
      return response.data ?? [];
    } catch (e) {
      print("Get orders error: $e");
      return [];
    }
  }
}

