class ListOrderSellerModel {
  int status;
  bool error;
  String message;
  List<ListOrderDataSeller> data;

  ListOrderSellerModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory ListOrderSellerModel.fromJson(Map<String, dynamic> json) => ListOrderSellerModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: List<ListOrderDataSeller>.from(json["data"].map((x) => ListOrderDataSeller.fromJson(x))),
  );
}

class ListOrderDataSeller {
  String transactionId;
  String orderStatus;
  String paymentStatus;
  String paymentCode;
  DateTime createdAt;
  String waybill;
  dynamic expire;
  String invoice;
  int totalPrice;
  Store store;
  List<OrderDataItem> items;
  Seller seller;
  Buyer buyer;

  ListOrderDataSeller({
    required this.transactionId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentCode,
    required this.createdAt,
    required this.waybill,
    required this.expire,
    required this.invoice,
    required this.totalPrice,
    required this.store,
    required this.items,
    required this.seller,
    required this.buyer,
  });

  factory ListOrderDataSeller.fromJson(Map<String, dynamic> json) => ListOrderDataSeller(
    transactionId: json["transaction_id"],
    orderStatus: json["order_status"],
    paymentStatus: json["payment_status"],
    paymentCode: json["payment_code"],
    createdAt: DateTime.parse(json["created_at"]),
    waybill: json["waybill"],
    expire: DateTime.parse(json["expire"]),
    invoice: json["invoice"],
    totalPrice: json["total_price"],
    store: Store.fromJson(json["store"]),
    items: List<OrderDataItem>.from(json["items"].map((x) => OrderDataItem.fromJson(x))),
    seller: Seller.fromJson(json["seller"]),
    buyer: Buyer.fromJson(json["buyer"]),
  );
}

class Buyer {
  String id;
  String email;
  String phone;
  String fullname;
  String avatar;

  Buyer({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullname,
    required this.avatar,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) => Buyer(
    id: json["id"],
    email: json["email"],
    phone: json["phone"],
    fullname: json["fullname"],
    avatar: json["avatar"],
  );
}


class Seller {
  String id;
  String email;
  String phone;
  String fullname;
  String avatar;

  Seller({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullname,
    required this.avatar,
  });

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
    id: json["id"],
    email: json["email"],
    phone: json["phone"],
    fullname: json["fullname"],
    avatar: json["avatar"],
  );
}

class OrderDataItem {
  OrderListProduct product;
  String courierId;
  int courierPrice;
  String courierService;
  int qty;

  OrderDataItem({
    required this.product,
    required this.courierId,
    required this.courierPrice,
    required this.courierService,
    required this.qty,
  });

  factory OrderDataItem.fromJson(Map<String, dynamic> json) => OrderDataItem(
    product: OrderListProduct.fromJson(json["product"]),
    courierId: json["courier_id"],
    courierPrice: json["courier_price"],
    courierService: json["courier_service"],
    qty: json["qty"],
  );
}

class OrderListProduct {
  String id;
  String title;
  List<Media> medias;
  int price;
  int stock;
  String caption;
  String note;
  ProductStore store;

  OrderListProduct({
    required this.id,
    required this.title,
    required this.medias,
    required this.price,
    required this.stock,
    required this.caption,
    required this.note,
    required this.store,
  });

  factory OrderListProduct.fromJson(Map<String, dynamic> json) => OrderListProduct(
    id: json["id"],
    title: json["title"],
    medias: List<Media>.from(json["medias"].map((x) => Media.fromJson(x))),
    price: json["price"],
    stock: json["stock"],
    caption: json["caption"],
    note: json["note"],
    store: ProductStore.fromJson(json["store"]),
  );
}

class Media {
  int id;
  String path;

  Media({
    required this.id,
    required this.path,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: json["id"],
    path: json["path"],
  );

}

class ProductStore {
  String id;
  String logo;
  String name;
  String address;
  String province;
  String city;

  ProductStore({
    required this.id,
    required this.logo,
    required this.name,
    required this.address,
    required this.province,
    required this.city,
  });

  factory ProductStore.fromJson(Map<String, dynamic> json) => ProductStore(
    id: json["id"],
    logo: json["logo"],
    name: json["name"],
    address: json["address"],
    province: json["province"],
    city: json["city"],
  );
}

class Store {
  String id;
  String logo;
  String name;

  Store({
    required this.id,
    required this.logo,
    required this.name,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json["id"],
    logo: json["logo"],
    name: json["name"],
  );
}
