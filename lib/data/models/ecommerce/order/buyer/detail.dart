class DetailOrderModel {
  int status;
  bool error;
  String message;
  DetailOrderData data;

  DetailOrderModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory DetailOrderModel.fromJson(Map<String, dynamic> json) => DetailOrderModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data:  DetailOrderData.fromJson(json["data"]),
  );
}

class DetailOrderData {
  String? transactionId;
  String? orderStatus;
  String? paymentStatus;
  String? paymentAccess;
  String? paymentCode;
  DateTime? expire;
  int? totalCost;
  int? totalPrice;
  String? invoice;
  DateTime? createdAt;
  bool? isReviewed;
  List<DetailOrderDataItem>? items;

  DetailOrderData({
    this.transactionId,
    this.orderStatus,
    this.paymentStatus,
    this.paymentAccess,
    this.paymentCode,
    this.expire,
    this.totalCost,
    this.totalPrice,
    this.invoice,
    this.createdAt,
    this.isReviewed,
    this.items,
  });

  factory DetailOrderData.fromJson(Map<String, dynamic> json) => DetailOrderData(
    transactionId: json["transaction_id"],
    orderStatus: json["order_status"],
    paymentStatus: json["payment_status"],
    paymentAccess: json["payment_access"],
    paymentCode: json["payment_code"],
    expire: DateTime.parse(json["expire"]),
    totalCost: json["total_cost"],
    totalPrice: json["total_price"],
    invoice: json["invoice"],
    createdAt: DateTime.parse(json["created_at"]),
    isReviewed: json["is_reviewed"],
    items: List<DetailOrderDataItem>.from(json["items"].map((x) => DetailOrderDataItem.fromJson(x))),
  );
}

class DetailOrderDataItem {
  DetailOrderProduct product;
  Seller seller;
  Buyer buyer;
  String waybill;
  String courierId;
  int courierPrice;
  String courierService;
  int courierWeight;
  int qty;

  DetailOrderDataItem({
    required this.product,
    required this.seller,
    required this.buyer,
    required this.waybill,
    required this.courierId,
    required this.courierPrice,
    required this.courierService,
    required this.courierWeight,
    required this.qty,
  });

  factory DetailOrderDataItem.fromJson(Map<String, dynamic> json) => DetailOrderDataItem(
    product: DetailOrderProduct.fromJson(json["product"]),
    seller: Seller.fromJson(json["seller"]),
    buyer: Buyer.fromJson(json["buyer"]),
    waybill: json["waybill"],
    courierId: json["courier_id"],
    courierPrice: json["courier_price"],
    courierService: json["courier_service"],
    courierWeight: json["courier_weight"],
    qty: json["qty"],
  );
}

class Buyer {
  String id;
  String email;
  String phone;
  String fullname;
  String avatar;
  String address;

  Buyer({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullname,
    required this.avatar,
    required this.address,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) => Buyer(
    id: json["id"],
    email: json["email"],
    phone: json["phone"],
    fullname: json["fullname"],
    avatar: json["avatar"],
    address: json["address"],
  );
}

class Seller {
  String id;
  String email;
  String phone;
  String fullname;
  String avatar;
  String address;

  Seller({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullname,
    required this.avatar,
    required this.address,
  });

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
    id: json["id"],
    email: json["email"],
    phone: json["phone"],
    fullname: json["fullname"],
    avatar: json["avatar"],
    address: json["address"],
  );
}

class DetailOrderProduct {
  String id;
  String title;
  List<Media> medias;
  int price;
  int stock;
  String caption;
  String note;
  Store store;

  DetailOrderProduct({
    required this.id,
    required this.title,
    required this.medias,
    required this.price,
    required this.stock,
    required this.caption,
    required this.note,
    required this.store,
  });

  factory DetailOrderProduct.fromJson(Map<String, dynamic> json) => DetailOrderProduct(
    id: json["id"],
    title: json["title"],
    medias: List<Media>.from(json["medias"].map((x) => Media.fromJson(x))),
    price: json["price"],
    stock: json["stock"],
    caption: json["caption"],
    note: json["note"],
    store: Store.fromJson(json["store"]),
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

class Store {
  String id;
  String logo;
  String name;
  String address;
  String province;
  String city;

  Store({
    required this.id,
    required this.logo,
    required this.name,
    required this.address,
    required this.province,
    required this.city,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json["id"],
    logo: json["logo"],
    name: json["name"],
    address: json["address"],
    province: json["province"],
    city: json["city"],
  );
}
