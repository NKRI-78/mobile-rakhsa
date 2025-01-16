import 'dart:async';
import 'dart:io';

import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:lecle_flutter_absolute_path/lecle_flutter_absolute_path.dart';

import 'package:image_picker/image_picker.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';

import 'package:rakhsa/data/models/ecommerce/balance/balance.dart';

import 'package:rakhsa/data/models/ecommerce/store/store.dart' as s;

import 'package:rakhsa/data/models/ecommerce/cart/cart.dart';
import 'package:rakhsa/data/models/ecommerce/checkout/list.dart';
import 'package:rakhsa/data/models/ecommerce/courier/courier.dart';
import 'package:rakhsa/data/models/ecommerce/googlemaps/googlemaps.dart';
import 'package:rakhsa/data/models/ecommerce/order/buyer/detail.dart';
import 'package:rakhsa/data/models/ecommerce/order/buyer/list.dart';
import 'package:rakhsa/data/models/ecommerce/order/tracking.dart';
import 'package:rakhsa/data/models/ecommerce/payment/how_to.dart';
import 'package:rakhsa/data/models/ecommerce/payment/payment.dart';
import 'package:rakhsa/data/models/ecommerce/payment/response_emoney.dart';
import 'package:rakhsa/data/models/ecommerce/payment/response_va.dart';
import 'package:rakhsa/data/models/ecommerce/product/all.dart';
import 'package:rakhsa/data/models/ecommerce/product/category.dart';
import 'package:rakhsa/data/models/ecommerce/product/detail.dart';
import 'package:rakhsa/data/models/ecommerce/product/transaction.dart';
import 'package:rakhsa/data/models/ecommerce/region/city.dart';
import 'package:rakhsa/data/models/ecommerce/region/district.dart';
import 'package:rakhsa/data/models/ecommerce/region/province.dart';
import 'package:rakhsa/data/models/ecommerce/region/subdistrict.dart';
import 'package:rakhsa/data/models/ecommerce/shipping_address/shipping_address.dart';
import 'package:rakhsa/data/models/ecommerce/shipping_address/shipping_address_default.dart';
import 'package:rakhsa/data/models/ecommerce/shipping_address/shipping_address_detail.dart';
import 'package:rakhsa/data/models/ecommerce/order/seller/detail.dart';
import 'package:rakhsa/data/models/ecommerce/order/seller/list.dart';
import 'package:rakhsa/data/models/ecommerce/store/owner.dart';

import 'package:rakhsa/data/repository/ecommerce/ecommerce.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/data/repository/media/media.dart';
import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';
import 'package:rakhsa/views/screens/ecommerce/payment/receipt_emoney.dart';
import 'package:rakhsa/views/screens/ecommerce/payment/receipt_va.dart';


enum CreateStoreStatus { idle, loading, loaded, empty, error }
enum GetStoreStatus { idle, loading, loaded, empty, error }
enum CheckStoreOwnerStatus { idle, loading, loaded, empty, error }

enum BadgeOrderAllStatus { idle, loading, loaded, empty, error }
enum BadgeOrderDetailStatus { idle, loading, loaded, empty, error }

enum ListProductStatus { idle, loading, loaded, empty, error }
enum CreateProductStatus { idle, loading, loaded, empty, error }
enum UpdateProductStatus { idle, loading, loaded, empty, error }
enum ListProductTransactionStatus { idle, loading, loaded, empty, error }
enum DetailProductStatus { idle, loading, loaded, empty, error }
enum DeleteProductStatus { idle, loading, loaded, empty, error }
enum DeleteProductImageStatus { idle, loading, loaded, empty, error }

enum BalanceStatus { idle, loading, loaded, empty, error }

enum ConfirmOrderStatus { idle, loading, loaded, empty, error }
enum CancelOrderStatus { idle, loading, loaded, empty, error }

enum GetProductCategoryStatus { idle, loading, loaded, empty, error }

enum ListOrderStatus { idle, loading, loaded, empty, error }
enum ListOrderSellerStatus { idle, loading, loaded, empty, error }
enum DetailOrderStatus { idle, loading, loaded, empty, error }
enum DetailOrderSellerStatus { idle, loading, loaded, empty, error }

enum TrackingStatus { idle, loading, loaded, empty, error }

enum AddCartStatus { idle, loading, loaded, empty, error }
enum AddCartLiveStatus { idle, loading, loaded, empty, error }
enum GetCartStatus { idle, loading, loaded, empty, error }
enum DeleteCartStatus { idle, loading, loaded ,empty, error }

enum GetCourierStatus { idle, loading, loaded, empty, error }
enum AddCourierStatus { idle, loading, loaded, empty, error }

enum GetPaymentChannelStatus { idle, loading, loaded, empty, error }

enum GetShippingAddressListStatus { idle, loading, loaded, empty, error }
enum GetShippingAddressSingleStatus { idle, loading, loaded, empty, error }
enum GetShippingAddressDefaultStatus { idle, loading, loaded, empty, error }

enum DeleteShippingAddressStatus { idle, loading, loaded, empty, error }
enum CreateShippingAddressStatus { idle, loading, loaded, empty, error }
enum UpdateShippingAddressStatus { idle, loading, loaded, empty, error }

enum SelectPrimaryShippingAddressStatus { idle, loading, loaded, empty, error }

enum HowToPaymentStatus { idle, loading, loaded, empty, error }

enum GetCheckoutStatus { idle, loading, loaded ,empty, error }

enum PayStatus { idle, loading, loaded, empty, error }

class EcommerceProvider extends ChangeNotifier {
  final EcommerceRepo er;
  final MediaRepo mr;

  EcommerceProvider({
    required this.er,
    required this.mr
  });

  int balance = 0;

  String provinceName = "";
  String cityName = "";
  String subdistrictName = "";
  String tariffCode = ""; 

  int selectedTopupId = 0;
  int selectedTopupPrice = 0;

  late AnimationController controller;
  late Animation<double> animation;

  List<Asset> images = [];

  Future<void> pickImage({
    required BuildContext context, 
    required int i
  }) async {
    ImageSource? imageSource = await showDialog<ImageSource>(context: context, 
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Pilih sumber gambar",
          style: TextStyle(
            color: ColorResources.purple
          ),
        ),
        actions: [
          MaterialButton(
            child: const Text("Kamera",
              style: TextStyle(
                color: ColorResources.purple
              ),
            ),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          MaterialButton(
            onPressed: () => uploadImg(i: i),
            child: const Text( "Galeri",
              style: TextStyle(
                color: ColorResources.purple
              ),
            ),
          )
        ],
      )
    );

    if(imageSource != null) {
      XFile? filePath = await ImagePicker().pickImage(source: imageSource);
      File tempFile= File(filePath!.path);

      _productTransactions[i].befores.add(tempFile);
      _productTransactions[i].files = productTransactions[i].befores.toSet().toList();

      notifyListeners();
    }

  }

  void uploadImg({
    required int i
  }) async {
    List<Asset> resultList = [];

    if(productTransactions[i].files.isEmpty) {
      resultList = await MultiImagePicker.pickImages(
        androidOptions: const AndroidOptions(
          maxImages: 5,
        ),
        iosOptions: const IOSOptions(
          settings: CupertinoSettings(
            selection: SelectionSetting(
              max: 5
            )
          )
        ),
        selectedAssets: [],
      );
    } else if(productTransactions[i].files.length == 4) { 
      resultList = await MultiImagePicker.pickImages(
        androidOptions: const AndroidOptions(
          maxImages: 1,
        ),
        iosOptions: const IOSOptions(
          settings: CupertinoSettings(
            selection: SelectionSetting(
              max: 1
            )
          )
        ),
        selectedAssets: [],
      );
    } else if(productTransactions[i].files.length == 3) { 
      resultList = await MultiImagePicker.pickImages(
        androidOptions: const AndroidOptions(
          maxImages: 2,
        ),
        iosOptions: const IOSOptions(
          settings: CupertinoSettings(
            selection: SelectionSetting(
              max: 2
            )
          )
        ),
        selectedAssets: [],
      );
    } else if(productTransactions[i].files.length == 2) { 
        resultList = await MultiImagePicker.pickImages(
         androidOptions: const AndroidOptions(
          maxImages: 3,
        ),
        iosOptions: const IOSOptions(
          settings: CupertinoSettings(
            selection: SelectionSetting(
              max: 3
            )
          )
        ),
        selectedAssets: [],
      );
    } else { 
      resultList = await MultiImagePicker.pickImages(
        androidOptions: const AndroidOptions(
          maxImages: 4,
        ),
        iosOptions: const IOSOptions(
          settings: CupertinoSettings(
            selection: SelectionSetting(
              max: 4
            )
          )
        ),
        selectedAssets: [],
      );
    } 

    Future.delayed(Duration.zero, () {
      Navigator.pop(navigatorKey.currentContext!, true);
    });

    for (Asset imageAsset in resultList) {
      final filePath = await LecleFlutterAbsolutePath.getAbsolutePath(uri: imageAsset.identifier);
      File tempFile = File(filePath!);

      images = resultList;

      _productTransactions[i].befores.add(tempFile);
      _productTransactions[i].files = productTransactions[i].befores.toSet().toList();

      notifyListeners();
    }
  }

  void removeFile({
    required int i,
    required int z
  }) {
    _productTransactions[i].files.removeAt(z);
    _productTransactions[i].befores.removeAt(z);

    notifyListeners();
  }

  void onChangeRating({required int i, required double rating}) {
    _productTransactions[i].rating = rating;

    notifyListeners();
  }

  bool reached = false;
  bool hasMore = false;
  bool selectedAll = true;
  bool selectedAllProduct = false;

  int badge = 0;

  int badgeWaitingPayment = 0;
  int badgePaid = 0;
  int badgePacking = 0;
  int badgeDelivery = 0;
  
  int page = 1;

  int listenQty = -1;

  int submitLoadingReview = -1;

  int channelId = -1;
  int paymentFee = 0;

  String cat = "";
  String cartId = "";

  String paymentLogo = "";
  String paymentName = "";
  String paymentCode = "";
  String platform = "";

  String courierNameSelect = "";

  TextEditingController amountC = TextEditingController();

  GetStoreStatus _getStoreStatus = GetStoreStatus.idle;
  GetStoreStatus get getStoreStatus => _getStoreStatus;

  BalanceStatus _balanceStatus = BalanceStatus.idle;
  BalanceStatus get balanceStatus => _balanceStatus;

  BadgeOrderAllStatus _badgeOrderAllStatus = BadgeOrderAllStatus.idle;
  BadgeOrderAllStatus get badgeOrderAllStatus => _badgeOrderAllStatus;

  BadgeOrderDetailStatus _badgeOrderDetailStatus = BadgeOrderDetailStatus.idle;
  BadgeOrderDetailStatus get badgeOrderDetailStatus => _badgeOrderDetailStatus;

  HowToPaymentStatus _howToPaymentStatus = HowToPaymentStatus.idle;
  HowToPaymentStatus get howToPaymentStatus => _howToPaymentStatus;

  CreateStoreStatus _createStoreStatus = CreateStoreStatus.idle;
  CreateStoreStatus get createStoreStatus => _createStoreStatus;

  CreateProductStatus _createProductStatus = CreateProductStatus.idle;
  CreateProductStatus get createProductStatus => _createProductStatus;

  DeleteProductStatus _deleteProductStatus = DeleteProductStatus.idle;
  DeleteProductStatus get deleteProductStatus => _deleteProductStatus;

  DeleteProductImageStatus _deleteProductImageStatus = DeleteProductImageStatus.idle;
  DeleteProductImageStatus get deleteProductImageStatus => _deleteProductImageStatus;

  UpdateProductStatus _updateProductStatus = UpdateProductStatus.idle;
  UpdateProductStatus get updateProductStatus => _updateProductStatus;

  CheckStoreOwnerStatus _checkStoreOwnerStatus = CheckStoreOwnerStatus.idle;
  CheckStoreOwnerStatus get checkStoreOwnerStatus => _checkStoreOwnerStatus;

  ConfirmOrderStatus _confirmOrderStatus = ConfirmOrderStatus.idle;
  ConfirmOrderStatus get confirmOrderStatus => _confirmOrderStatus;

  CancelOrderStatus _cancelOrderStatus = CancelOrderStatus.idle;
  CancelOrderStatus get cancelOrderStatus => _cancelOrderStatus;

  ListProductStatus _listProductStatus = ListProductStatus.loading;
  ListProductStatus get listProductStatus => _listProductStatus;

  ListProductTransactionStatus _listProductTransactionStatus = ListProductTransactionStatus.loading;
  ListProductTransactionStatus get listProductTransactionStatus => _listProductTransactionStatus;

  GetProductCategoryStatus _getProductCategoryStatus = GetProductCategoryStatus.loading;
  GetProductCategoryStatus get getProductCategoryStatus => _getProductCategoryStatus;

  DetailProductStatus _detailProductStatus = DetailProductStatus.loading;
  DetailProductStatus get detailProductStatus => _detailProductStatus;

  ListOrderStatus _listOrderStatus = ListOrderStatus.loading;
  ListOrderStatus get listOrderStatus => _listOrderStatus;

  ListOrderSellerStatus _listOrderSellerStatus = ListOrderSellerStatus.idle;
  ListOrderSellerStatus get listOrderSellerStatus => _listOrderSellerStatus;

  DetailOrderStatus _detailOrderStatus = DetailOrderStatus.loading;
  DetailOrderStatus get detailOrderStatus => _detailOrderStatus;

  DetailOrderSellerStatus _detailOrderSellerStatus = DetailOrderSellerStatus.loading;
  DetailOrderSellerStatus get detailOrderSellerStatus => _detailOrderSellerStatus;

  PayStatus _payStatus = PayStatus.idle;
  PayStatus get payStatus => _payStatus;

  GetCartStatus _getCartStatus = GetCartStatus.loading; 
  GetCartStatus get getCartStatus => _getCartStatus;

  TrackingStatus _trackingStatus = TrackingStatus.loading;
  TrackingStatus get trackingStatus => _trackingStatus;

  AddCartStatus _addCartStatus = AddCartStatus.idle;
  AddCartStatus get addCartStatus => _addCartStatus;

  AddCartLiveStatus _addCartLiveStatus = AddCartLiveStatus.idle;
  AddCartLiveStatus get addCartLiveStatus => _addCartLiveStatus;

  DeleteCartStatus _deleteCartStatus = DeleteCartStatus.idle;
  DeleteCartStatus get deleteCartStatus => _deleteCartStatus;

  GetCourierStatus _getCourierStatus = GetCourierStatus.loading;
  GetCourierStatus get getCourierStatus => _getCourierStatus;

  GetCheckoutStatus _getCheckoutStatus = GetCheckoutStatus.loading;
  GetCheckoutStatus get getCheckoutStatus => _getCheckoutStatus;

  GetPaymentChannelStatus _getPaymentChannelStatus = GetPaymentChannelStatus.idle;
  GetPaymentChannelStatus get getPaymentChannelStatus => _getPaymentChannelStatus;

  GetShippingAddressListStatus _getShippingAddressListStatus = GetShippingAddressListStatus.loading;
  GetShippingAddressListStatus get getShippingAddressListStatus => _getShippingAddressListStatus;

  GetShippingAddressSingleStatus _getShippingAddressSingleStatus = GetShippingAddressSingleStatus.loading;
  GetShippingAddressSingleStatus get getShippingAddressSingleStatus => _getShippingAddressSingleStatus;

  GetShippingAddressDefaultStatus _getShippingAddressDefaultStatus = GetShippingAddressDefaultStatus.loading;
  GetShippingAddressDefaultStatus get getShippingAddressDefaultStatus => _getShippingAddressDefaultStatus;

  CreateShippingAddressStatus _createShippingAddressStatus = CreateShippingAddressStatus.idle; 
  CreateShippingAddressStatus get createShippingAddressStatus => _createShippingAddressStatus;

  DeleteShippingAddressStatus _deleteShippingAddressStatus = DeleteShippingAddressStatus.idle;
  DeleteShippingAddressStatus get deleteShippingAddressStatus => _deleteShippingAddressStatus;

  UpdateShippingAddressStatus _updateShippingAddressStatus = UpdateShippingAddressStatus.idle; 
  UpdateShippingAddressStatus get updateShippingAddressStatus => _updateShippingAddressStatus;

  SelectPrimaryShippingAddressStatus _selectPrimaryShippingAddressStatus = SelectPrimaryShippingAddressStatus.idle;
  SelectPrimaryShippingAddressStatus get  selectPrimaryShippingAddressStatus => _selectPrimaryShippingAddressStatus;

  CartData _cartData = CartData();
  CartData get cartData => _cartData;

  CheckoutListData _checkoutListData = CheckoutListData();
  CheckoutListData get checkoutListData => _checkoutListData;

  OwnerModel _ownerModel = OwnerModel();
  OwnerModel get ownerModel => _ownerModel;

  s.StoreModel? _store = s.StoreModel();
  s.StoreModel? get store => _store!;

  List<DataHowToPayment> _mbank = [];
  List<DataHowToPayment> get mbank => [..._mbank];

  List<DataHowToPayment> _atm = [];
  List<DataHowToPayment> get atm => [..._atm];

  List<DataHowToPayment> _emoney = [];
  List<DataHowToPayment> get emoney => [..._emoney]; 

  List<Product> _products = [];
  List<Product> get products => [..._products];

  List<Product> _productSellers = [];
  List<Product> get productSellers => [..._productSellers];
  
  List<ProductTransactionData> _productTransactions = [];
  List<ProductTransactionData> get productTransactions => [..._productTransactions];

  List<ProductCategoryData> _productCategories = [];
  List<ProductCategoryData> get productCategories => [..._productCategories];

  List<ProvinceData> _provinces = [];
  List<ProvinceData> get provinces => [..._provinces];

  List<CityData> _city = [];
  List<CityData> get city => [..._city];

  List<DistrictData> _district = [];
  List<DistrictData> get district => [..._district];

  List<SubdistrictData> _subdistrict = [];
  List<SubdistrictData> get subdistrict => [..._subdistrict];

  List<ShippingAddressData> _shippingAddress = [];
  List<ShippingAddressData> get shippingAddress => [..._shippingAddress];

  List<ListOrderData> _orders = [];
  List<ListOrderData> get orders => [..._orders];

  List<ListOrderDataSeller> _orderSellers = [];
  List<ListOrderDataSeller> get orderSellers => [..._orderSellers];

  DetailOrderData _detailOrderData = DetailOrderData();
  DetailOrderData get detailOrderData => _detailOrderData;

  DetailOrderSellerData _detailOrderSellerData = DetailOrderSellerData();
  DetailOrderSellerData get detailOrderSellerData => _detailOrderSellerData;

  ShippingAddressDetailData _shippingAddressDetailData = ShippingAddressDetailData();
  ShippingAddressDetailData get shippingAddressDetailData => _shippingAddressDetailData;

  ShippingAddressDataDefault _shippingAddressDataDefault = ShippingAddressDataDefault();
  ShippingAddressDataDefault get shippingAddressDataDefault => _shippingAddressDataDefault;

  ProductDetailData _productDetailData = ProductDetailData();
  ProductDetailData get productDetailData => _productDetailData;

  final TrackingData _trackingData = TrackingData();
  TrackingData get trackingData => _trackingData;

  void setStateConfirmOrderStatus(param) {
    _confirmOrderStatus = param;

    notifyListeners();
  }

  void setStateCancelOrderStatus(param) {
    _cancelOrderStatus = param;

    notifyListeners();
  }

  void setStateBadgeOrderAll(BadgeOrderAllStatus param) {
    _badgeOrderAllStatus = param;

    notifyListeners();
  }

  void setStateBadgeOrderDetail(BadgeOrderDetailStatus param) {
    _badgeOrderDetailStatus = param;

    notifyListeners();
  }

  void setStateHowToPayment(HowToPaymentStatus param) {
    _howToPaymentStatus = param;

    notifyListeners();
  }

  void setStateBalanceStatus(BalanceStatus param) {
    _balanceStatus = param;

    notifyListeners();
  }

  void setStateListProductStatus(ListProductStatus param) {
    _listProductStatus = param;
    
    notifyListeners();
  }

  void setStateGetProductCategoryStatus(GetProductCategoryStatus param) {
    _getProductCategoryStatus = param;

    notifyListeners();
  }

  void setStateDeleteProductStatus(DeleteProductStatus param) {
    _deleteProductStatus = param;

    notifyListeners();
  }

  void setStateDeleteProductImageStatus(DeleteProductImageStatus param) {
    _deleteProductImageStatus = param;

    notifyListeners();
  }

  void setStateCreateProductStatus(CreateProductStatus param) {
    _createProductStatus = param;

    notifyListeners();
  }

  void setStateUpdateProductStatus(UpdateProductStatus param) {
    _updateProductStatus = param;

    notifyListeners();
  }

  void setStateDetailProductStatus(DetailProductStatus param) {
    _detailProductStatus = param;

    notifyListeners();
  }

  void setStateTrackingStatus(TrackingStatus param) {
    _trackingStatus = param;

    notifyListeners();
  }

  void setStateListOrderStatus(ListOrderStatus param) {
    _listOrderStatus = param;

    notifyListeners();
  }

  void setStateListOrderSellerStatus(ListOrderSellerStatus param) {
    _listOrderSellerStatus = param;
    
    notifyListeners();
  }

  void setStateDetailOrderStatus(DetailOrderStatus param) {
    _detailOrderStatus = param;

    notifyListeners();
  }

  void setStateDetailOrderSellerStatus(DetailOrderSellerStatus param) {
    _detailOrderSellerStatus = param;

    notifyListeners();
  }

  void setStateListProductTransactionStatus(ListProductTransactionStatus param) {
    _listProductTransactionStatus = param;

    notifyListeners();
  }

  void setStateGetCartStatus(GetCartStatus param) {
    _getCartStatus = param;

    notifyListeners();
  }

  void setStateAddCartStatus(AddCartStatus param) {
    _addCartStatus = param;

    notifyListeners();
  }

  void setStateAddCartLiveStatus(AddCartLiveStatus param) {
    _addCartLiveStatus = param;

    notifyListeners();
  }

  void setStateSelectPrimaryAddressStatus(SelectPrimaryShippingAddressStatus param) {
    _selectPrimaryShippingAddressStatus = param;

    notifyListeners();
  }

  void setStateCreateShippingAddress(CreateShippingAddressStatus param) {
    _createShippingAddressStatus = param;

    notifyListeners();
  }

  void setStateDeleteShippingAddress(DeleteShippingAddressStatus param) {
    _deleteShippingAddressStatus = param;

    notifyListeners();
  }

  void setStateUpdateShippingAddress(UpdateShippingAddressStatus param) {
    _updateShippingAddressStatus = param;

    notifyListeners();
  }

  void setStateDeleteCartStatus(DeleteCartStatus param) {
    _deleteCartStatus = param;

    notifyListeners();
  }

  void setStateGetCourierStatus(GetCourierStatus param) {
    _getCourierStatus = param;

    notifyListeners();
  }

  void setStateGetShippingAddressList(GetShippingAddressListStatus param) {
    _getShippingAddressListStatus = param;

    notifyListeners();
  }

  void setStateGetShippingAddressSingle(GetShippingAddressSingleStatus param) {
    _getShippingAddressSingleStatus = param;

    notifyListeners();
  }

  void setStateGetShippingAddressDefault(GetShippingAddressDefaultStatus param) {
    _getShippingAddressDefaultStatus = param;

    notifyListeners();
  }

  void setStateCheckoutStatus(GetCheckoutStatus param) {
    _getCheckoutStatus = param;

    notifyListeners();
  }

  void setStatePayStatus(PayStatus param) {
    _payStatus = param;

    notifyListeners();
  }

  void setStateGetPaymentChannelStatus(GetPaymentChannelStatus param) {
    _getPaymentChannelStatus = param;

    notifyListeners();
  }

  void setStateGetStoreStatus(GetStoreStatus param) {
    _getStoreStatus = param;

    notifyListeners();
  }

  void setStateCreateStoreStatus(CreateStoreStatus param) {
    _createStoreStatus = param;

    notifyListeners();
  }

  void setStateCheckStoreOwnerStatus(CheckStoreOwnerStatus param) {
    _checkStoreOwnerStatus = param;

    notifyListeners();
  }

  void selectTopup({
    required int id,
    required int price   
  }) {
    selectedTopupId = id;
    selectedTopupPrice = price;
    amountC.text = "";

    notifyListeners();
  } 

  void onManualTopup({
    required int price
  }) {
    selectedTopupId = 0;
    selectedTopupPrice = price; 

    notifyListeners();
  }

  void selectCat({required String param, required String storeId}) {
    page = 1;
    cat = param;

    if(param == "Semua") {
      cat = "";
    }

    Future.delayed(const Duration(seconds: 1), () async {
      await fetchAllProduct(search: "");
      if(storeId != "") {
        await fetchAllProductSeller(search: "", storeId: storeId);
      }
    });

    notifyListeners();
  }

  void onSubmitLoadingReview({required int i}) {
    submitLoadingReview = i;

    notifyListeners();
  }

  Future<void> checkStoreOwner() async {
    setStateCheckStoreOwnerStatus(CheckStoreOwnerStatus.loading);
    try {

      final checkStoreOwner = await er.checkStoreOwner();
      _ownerModel = checkStoreOwner;

      setStateCheckStoreOwnerStatus(CheckStoreOwnerStatus.loaded);
    } catch(e) {
      setStateCheckStoreOwnerStatus(CheckStoreOwnerStatus.error);
    }
  }

  Future<void> getStore() async {
    setStateGetStoreStatus(GetStoreStatus.loading);
    try {

      final storeModel = await er.getStore();
      _store = storeModel;

      setStateGetStoreStatus(GetStoreStatus.loaded);
    } catch(e) {
      _store = null;

      setStateGetStoreStatus(GetStoreStatus.error);
    }
  } 

  Future<void> createStore({
    required String id, 
    required File logo, 
    required String name,
    required String caption,
    required String province, 
    required String city,
    required String district,
    required String subdistrict,
    required String address,
    required String email,
    required String phone,
    required String lat,
    required String lng,
    required bool isOpen,
    required String postCode
  }) async {
    setStateCreateStoreStatus(CreateStoreStatus.loading);
    try {

      Response? res = await mr.postMedia(logo);
      Map map = res.data;

      String logoPath = map['data']['path'];

      await er.createStore(
        id: id, 
        logo: logoPath, 
        name: name, 
        caption: caption, 
        province: province, 
        city: city, 
        district: district, 
        subdistrict: subdistrict, 
        address: address, 
        email: email, 
        phone: phone, 
        lat: lat, 
        lng: lng, 
        isOpen: isOpen, 
        postCode: postCode
      );

      Navigator.pop(navigatorKey.currentContext!);

      getStore();
      checkStoreOwner();

      setStateCreateStoreStatus(CreateStoreStatus.loaded);
    } catch(e) {
      setStateCreateStoreStatus(CreateStoreStatus.error);
    }
  }

  void onSelectedAllProduct(bool val) {
    selectedAllProduct = val;

    for (Product productSeller in productSellers) {
      productSeller.selected = val;
    }
  
    notifyListeners();
  }

  void onSelectedProduct({required String id, required bool val}) {
    int i = productSellers.indexWhere((el) => el.id == id);

    _productSellers[i].selected = val;

    notifyListeners();
  }

  void onSelectedAll(bool val) {
    selectedAll = val;

    if(selectedAll) {
      
      int totalPrice = 0;

      for (StoreItem store in cartData.stores!) {
        store.selected = selectedAll;

        for (StoreData storeData in store.items) {
          storeData.cart.selected = selectedAll;

          totalPrice += storeData.price * storeData.cart.qty;
        }
      }

      _cartData.totalPrice = totalPrice; 

      er.updateSelectedAll(selected: selectedAll);

    } else {

      int totalPrice = 0;

      for (StoreItem store in cartData.stores!) {
        store.selected = selectedAll;

        for (StoreData storeData in store.items) {
          storeData.cart.selected = selectedAll;
        }
      }

      _cartData.totalPrice = totalPrice; 

      er.updateSelectedAll(selected: selectedAll);

    }

    notifyListeners();
  }

  Future<void> storeSelected({required int i, required bool selected}) async {
    _cartData.stores![i].selected = !_cartData.stores![i].selected;

    for (StoreData item in cartData.stores![i].items) {
      if(item.cart.selected) {   

        item.cart.selected = false;
   
        int totalPrice = 0;
        
        for (StoreItem cis in cartData.stores!.where((el) => el.selected == true)) {
          for (StoreData cii in cis.items.where((el) => el.cart.selected == true)) {
            totalPrice += cii.price * cii.cart.qty;
          }
        }

        _cartData.totalPrice = totalPrice; 

        await er.updateSelected( 
          selected: item.cart.selected, 
          cartId: item.cart.id
        );
      } else {

        if(cartData.stores![i].selected == false) {
          item.cart.selected = false;
        } else {
          item.cart.selected = true;
        }
          
        int totalPrice = 0;
        
        for (StoreItem cis in cartData.stores!.where((el) => el.selected == true)) {
          for (StoreData cii in cis.items.where((el) => el.cart.selected == true)) {
            totalPrice += cii.price * cii.cart.qty;
          }
        }

        _cartData.totalPrice = totalPrice;   

        await er.updateSelected( 
          selected: item.cart.selected, 
          cartId: item.cart.id
        );
      }

    }

    bool allStoreActive = cartData.stores!.every((item) => item.selected == true);

    if(allStoreActive) {
      selectedAll = true;
    } else {
      selectedAll = false;
    }

    notifyListeners();
  }

  Future<void> storeItemSelected({
    required int i,
    required int z,
    required String cartIdParam
  }) async {
    if(cartData.stores![i].items[z].cart.selected)  {

      _cartData.stores![i].items[z].cart.selected = false;

      if(cartData.stores![i].items.where((el) => el.cart.selected == true).toList().isEmpty) {
        _cartData.stores![i].selected = false;
      }

      int totalPrice = 0;
      
      for (StoreItem cis in cartData.stores!.where((el) => el.selected == true)) {
        for (StoreData cii in cis.items.where((el) => el.cart.selected == true)) {
          totalPrice += cii.price * cii.cart.qty;
        }
      }

      _cartData.totalPrice = totalPrice;

      await er.updateSelected(selected: false, cartId: cartIdParam);

    }  else {
      
      _cartData.stores![i].selected = true;
      _cartData.stores![i].items[z].cart.selected = true;

      int totalPrice = 0;
      
      for (StoreItem cis in cartData.stores!.where((el) => el.selected == true)) {
        for (StoreData cii in cis.items.where((el) => el.cart.selected == true)) {
          totalPrice += cii.price * cii.cart.qty;
        }
      }

      _cartData.totalPrice = totalPrice;

      await er.updateSelected(selected: true, cartId: cartIdParam);
    }

    bool allStoreActive = cartData.stores!.every((item) => item.selected == true);

    if(allStoreActive) {
      selectedAll = true;
    } else {
      selectedAll = false;
    }

    notifyListeners();
  } 

  Future<void> getBalance() async {
    try { 
      BalanceModel balanceModel = await er.getBalance();
      
      balance = balanceModel.data.balance;

      setStateBalanceStatus(BalanceStatus.loaded);
    } catch(_) {
      setStateBalanceStatus(BalanceStatus.error);
    }
  }

  Future<void> listOrder({required String orderStatus}) async {
    setStateListOrderStatus(ListOrderStatus.loading);
    try {

      ListOrderModel listOrderModel = await er.getOrderList(orderStatus: orderStatus);
      
      _orders = [];
      _orders.addAll(listOrderModel.data);
      setStateListOrderStatus(ListOrderStatus.loaded);

      if(orders.isEmpty) {
        setStateListOrderStatus(ListOrderStatus.empty);
      }

    } catch(_) {
      setStateListOrderStatus(ListOrderStatus.error);
    }
  }

  Future<void> listOrderSeller({required String orderStatus}) async {
    setStateListOrderSellerStatus(ListOrderSellerStatus.loading);
    try {

      ListOrderSellerModel listOrderSellerModel = await er.getOrderSellerList(orderStatus: orderStatus);
      
      _orderSellers = [];
      _orderSellers.addAll(listOrderSellerModel.data);
      setStateListOrderSellerStatus(ListOrderSellerStatus.loaded);

      if(orderSellers.isEmpty) {
        setStateListOrderSellerStatus(ListOrderSellerStatus.empty);
      }
    } catch(_) {
      setStateListOrderSellerStatus(ListOrderSellerStatus.error);
    }
  }

  Future<void> detailOrder({required String transactionId}) async {
    setStateDetailOrderStatus(DetailOrderStatus.loading);
    try {

      DetailOrderModel detailOrderModel = await er.getOrderDetail(transactionId: transactionId);
      
      _detailOrderData = detailOrderModel.data;

      setStateDetailOrderStatus(DetailOrderStatus.loaded);
    } catch(_) {
      setStateDetailOrderStatus(DetailOrderStatus.error);
    }
  }

  Future<void> detailOrderSeller({
    required String storeId,
    required String transactionId
  }) async {
    setStateDetailOrderSellerStatus(DetailOrderSellerStatus.loading);
    try {

      DetailOrderSellerModel detailOrderSeller = await er.getOrderSellerDetail(
        storeId: storeId,
        transactionId: transactionId
      );

      _detailOrderSellerData = detailOrderSeller.data;

      setStateDetailOrderSellerStatus(DetailOrderSellerStatus.loaded);
    } catch(_) {
      setStateDetailOrderSellerStatus(DetailOrderSellerStatus.error);
    }
  }

  Future<void> confirmOrder({
    required String storeId,
    required String transactionId
  }) async {
    setStateConfirmOrderStatus(ConfirmOrderStatus.loading);
    try {
      await er.confirmOrder(
        storeId: storeId, 
        transactionId: transactionId
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(navigatorKey.currentContext!);
        Navigator.pop(navigatorKey.currentContext!);

        listOrder(orderStatus: "PAID");
      });
      setStateConfirmOrderStatus(ConfirmOrderStatus.loaded);
    } catch(_) {
      setStateConfirmOrderStatus(ConfirmOrderStatus.error);
    } 
  }

  Future<void> cancelOrder({required String transactionId}) async {
    setStateCancelOrderStatus(CancelOrderStatus.loading);
    try {
      await er.cancelOrder(transactionId: transactionId);
      setStateCancelOrderStatus(CancelOrderStatus.loaded);

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(navigatorKey.currentContext!);
        Navigator.pop(navigatorKey.currentContext!);

        listOrder(orderStatus: "WAITING_PAYMENT");
      });
    } catch(_) {
      setStateCancelOrderStatus(CancelOrderStatus.error);
    }
  }
  
  Future<TrackingModel> trackingOrder({required String waybill}) async {
    return er.getTracking(waybill: waybill);
  }

  Future<void> fetchAllProduct({required String search}) async {
    setStateListProductStatus(ListProductStatus.loading);

    page = 1;
    reached = false;

    try {
      
      ProductModel productModel = await er.fetchAllProduct(
        search: search, 
        page: page,
        cat: cat
      );

      hasMore = productModel.data.pageDetail.hasMore;

      _products = [];
      _products.addAll(productModel.data.products);
      
      setStateListProductStatus(ListProductStatus.loaded);

      if(products.isEmpty) {
        setStateListProductStatus(ListProductStatus.empty);
      }

    } catch (_) {
      setStateListProductStatus(ListProductStatus.error);
    } 
  }

  Future<void> fetchAllProductSeller({
    required String search,
    required String storeId
  }) async {
    setStateListProductStatus(ListProductStatus.loading);

    page = 1;
    reached = false;

    try {
      
      ProductModel productModel = await er.fetchAllProductSeller(
        search: search, 
        page: page,
        storeId: storeId,
        cat: cat,
      );

      hasMore = productModel.data.pageDetail.hasMore;

      _productSellers = [];
      _productSellers.addAll(productModel.data.products);
      
      setStateListProductStatus(ListProductStatus.loaded);

      if(productSellers.isEmpty) {
        setStateListProductStatus(ListProductStatus.empty);
      }

    } catch (_) {
      setStateListProductStatus(ListProductStatus.error);
    } 
  }

  Future<void> fetchAllProductCategory({required bool isFromCreateProduct}) async {
    try {

      ProductCategoryModel productCategoryModel = await er.fetchProductCategory();

      _productCategories = [];

      if(!isFromCreateProduct) {
        _productCategories.add(
          ProductCategoryData(
            id: "30a58b87-4157-44fd-b840-f5b3d6691820",
            name: "Semua"
          )
        );
      }
      _productCategories.addAll(productCategoryModel.data);
      setStateGetProductCategoryStatus(GetProductCategoryStatus.loaded);

      if(productCategories.isEmpty) {
        setStateGetProductCategoryStatus(GetProductCategoryStatus.empty);
      }

    } catch(_) {
      setStateGetProductCategoryStatus(GetProductCategoryStatus.error);
    }
  }

  Future<void> fetchAllProductTransaction({
    required String transactionId
  }) async {
    setStateListProductTransactionStatus(ListProductTransactionStatus.loading);
    try {

      ProductTransactionModel productTransactionModel = await er.fetchProductTransaction(transactionId: transactionId); 

      _productTransactions = [];
      _productTransactions.addAll(productTransactionModel.data);
      setStateListProductTransactionStatus(ListProductTransactionStatus.loaded);

      if(productTransactions.isEmpty) {
        setStateListProductTransactionStatus(ListProductTransactionStatus.empty);
      }

    } catch(_) {
      setStateListProductTransactionStatus(ListProductTransactionStatus.error);
    } 
  }

  Future<void> loadMoreProduct() async {
    page++;

    notifyListeners();

    ProductModel productModel = await er.fetchAllProduct(
      cat: cat, 
      page: page, 
      search: ""
    );

    hasMore = productModel.data.pageDetail.hasMore;

    _products.addAll(productModel.data.products);

    notifyListeners();
  }

  Future<void> deleteProduct({
    required String storeId,
    required String productId,
  }) async {
    setStateDeleteProductStatus(DeleteProductStatus.loading);

    try {
      await er.deleteProduct(productId: productId);

      Navigator.pop(navigatorKey.currentContext!);

      fetchAllProductSeller(search: "", storeId: "");

      fetchAllProduct(search: "");
    
      setStateDeleteProductStatus(DeleteProductStatus.loaded);
    } catch(_) {
      setStateDeleteProductStatus(DeleteProductStatus.error);  
    }
  }

  Future<void> deleteProductSelect({required String storeId}) async {
    setStateDeleteProductStatus(DeleteProductStatus.loading);  
    try {

      for (Product product in productSellers.where((el) => el.selected == true)) {
        String productId = product.id;
    
        await er.deleteProduct(productId: productId);
      }

      fetchAllProductSeller(search: "", storeId: storeId);

      setStateDeleteProductStatus(DeleteProductStatus.loaded);  
    } catch(_) {
      setStateDeleteProductStatus(DeleteProductStatus.error);  
    }
  }

  Future<void> deleteProductImage({
    required int id
  }) async {
    setStateDeleteProductImageStatus(DeleteProductImageStatus.loading);
    try {

      await er.deleteProductImage(id: id);

      setStateDeleteProductImageStatus(DeleteProductImageStatus.loaded);
    } catch(_) {
      setStateDeleteProductImageStatus(DeleteProductImageStatus.error);
    }
  }

  Future<void> createProduct({
    required String id,
    required String title,
    required List<File> files,
    required String description,
    required int price,
    required int weight,
    required int stock,
    required bool isDraft,
    required String catId,
    required String storeId
  }) async {
    setStateCreateProductStatus(CreateProductStatus.loading);
    
    try {

      await er.createProduct(
        id: id, 
        title: title, 
        description: description, 
        price: price,
        weight: weight, 
        stock: stock, 
        isDraft: isDraft, 
        catId: catId, 
        storeId: storeId
      );

      for (File file in files) {
        Response? res = await mr.postMedia(file);
        Map map = res.data;
        String path = map['data']['path'];

        await er.createProductImage(
          productId: id, 
          path: path
        );
      }

      Navigator.pop(navigatorKey.currentContext!);

      fetchAllProductSeller(search: "", storeId: storeId);

      fetchAllProduct(search: "");

      setStateCreateProductStatus(CreateProductStatus.loaded);
    } catch(_) {
      setStateCreateProductStatus(CreateProductStatus.error);
    }
  }

  Future<void> updateProduct({
    required String id,
    required String title,
    required List<File> files,
    required String description,
    required int price,
    required int weight,
    required int stock,
    required bool isDraft,
    required String catId,
    required String storeId
  }) async {
    setStateUpdateProductStatus(UpdateProductStatus.loading);

    try { 

      await er.updateProduct(
        id: id, 
        title: title,
        description: description, 
        price: price, 
        weight: weight, 
        stock: stock, 
        isDraft: isDraft,
        catId: catId
      );
    
      for (File file in files) {
        Response? res = await mr.postMedia(file);
        Map map = res.data;
        String path = map['data']['path'];

        await er.createProductImage(
          productId: id, 
          path: path
        );
      }

      Navigator.pop(navigatorKey.currentContext!);

      fetchProduct(productId: id);

      setStateUpdateProductStatus(UpdateProductStatus.loaded);
    } catch(_) {
      setStateUpdateProductStatus(UpdateProductStatus.error);
    }
  }
  
  Future<void> fetchProduct({required String productId}) async {
    setStateDetailProductStatus(DetailProductStatus.loading);
    try {
      ProductDetailModel productDetailModel = await er.getProduct(productId: productId);
      _productDetailData = productDetailModel.data;
      
      setStateDetailProductStatus(DetailProductStatus.loaded);
    } catch(_) {  
      setStateDetailProductStatus(DetailProductStatus.error);
    }
  }

  Future<void> productReview({
    required String productId, 
    required String transactionId,
    required String caption,
    required double rating,
    required List<File> files,   
  }) async {
    if(files.isNotEmpty) {
      for (File file in files) {
        Response? res = await mr.postMedia(file);
        Map map = res.data;
        await er.productReviewMedia(
          productId: productId,
          path: map['data']['path'],
        );
      }
    }

    await er.productReview(
      productId: productId,
      transactionId: transactionId,
      caption: caption, 
      rating: rating
    );

    Future.delayed(Duration.zero, () {
      fetchAllProductTransaction(transactionId: transactionId);
    });
  }

  Future<void> getShippingAddressList() async {
    setStateGetShippingAddressList(GetShippingAddressListStatus.loading);
    try { 
      
      ShippingAddressModel shippingAddressModel = await er.getShippingAddressList();

      _shippingAddress = [];
      _shippingAddress.addAll(shippingAddressModel.data);
      setStateGetShippingAddressList(GetShippingAddressListStatus.loaded);

      if(shippingAddress.isEmpty) {
        setStateGetShippingAddressList(GetShippingAddressListStatus.empty);
      }

    } catch(_) {
      setStateGetShippingAddressList(GetShippingAddressListStatus.error);
    }
  }

  Future<void> getShippingAddressSingle({required String id}) async {
    setStateGetShippingAddressSingle(GetShippingAddressSingleStatus.loading);
    try {

      ShippingAddressModelDetail shippingAddressModelDetail = await er.getShippingAddressDetail(id: id);
      _shippingAddressDetailData = shippingAddressModelDetail.data;

      setStateGetShippingAddressSingle(GetShippingAddressSingleStatus.loaded);
    } catch(_) {
      setStateGetShippingAddressSingle(GetShippingAddressSingleStatus.error);
    }
  }

  Future<void> getShippingAddressDefault() async {
    setStateGetShippingAddressDefault(GetShippingAddressDefaultStatus.loading);
    
    try {

      ShippingAddressModelDefault shippingAddressModelDefault = await er.getShippingAddressDefault();
      _shippingAddressDataDefault = shippingAddressModelDefault.data[0];

      setStateGetShippingAddressDefault(GetShippingAddressDefaultStatus.loaded);

      if(shippingAddressDataDefault.name == null) {
        setStateGetShippingAddressDefault(GetShippingAddressDefaultStatus.empty);
      }

    } catch(_) {
      setStateGetShippingAddressDefault(GetShippingAddressDefaultStatus.error);
    }
  }

  Future<void> createShippingAddress({
    required String label,
    required String address,
    required String province,
    required String city,
    required String district,
    required String postalCode,
    required String subdistrict
  }) async {
    setStateCreateShippingAddress(CreateShippingAddressStatus.loading);
    try {

      await er.createShippingAddress(
        label: label,
        address: address,
        province: province,
        city: city,
        district: district,
        postalCode: postalCode,
        subdistrict: subdistrict
      );
      
      Future.delayed(const Duration(seconds: 1), () {
        getShippingAddressList();
        getShippingAddressDefault();
      });

      Future.delayed(Duration.zero, () {
        Navigator.pop(navigatorKey.currentContext!);
      });

      setStateCreateShippingAddress(CreateShippingAddressStatus.loaded);
    } catch(_) {
      setStateCreateShippingAddress(CreateShippingAddressStatus.error);
    }
  }

  Future<void> deleteShippingAddress({
    required String id
  }) async {
    setStateDeleteShippingAddress(DeleteShippingAddressStatus.loading);
    try {

      await er.deleteShippingAddress(id: id);

      Future.delayed(const Duration(seconds: 1), () {
        getShippingAddressList();
        getShippingAddressDefault();
      });

      setStateDeleteShippingAddress(DeleteShippingAddressStatus.loaded);
    } catch(_) {
      setStateDeleteShippingAddress(DeleteShippingAddressStatus.error);
    }
  }

  Future<void> updateShippingAddress({
    required String id,
    required String label,
    required String address,
    required String province,
    required String city,
    required String district,
    required String postalCode,
    required String subdistrict
  }) async {
    setStateUpdateShippingAddress(UpdateShippingAddressStatus.loading);
    try {

      await er.updateShippingAddress(
        id: id,
        label: label,
        address: address,
        province: province,
        city: city,
        district: district,
        postalCode: postalCode,
        subdistrict: subdistrict
      );

      Future.delayed(const Duration(seconds: 1), () {
        getShippingAddressList();
        getShippingAddressDefault();
      });
      
      Future.delayed(Duration.zero, () {
        Navigator.pop(navigatorKey.currentContext!);
      });

      setStateUpdateShippingAddress(UpdateShippingAddressStatus.loaded);
    } catch(_) {
      setStateUpdateShippingAddress(UpdateShippingAddressStatus.error);
    }
  }

  Future<void> selectPrimaryShippingAddress({
    required String id,
    required String from
  }) async {  
    setStateSelectPrimaryAddressStatus(SelectPrimaryShippingAddressStatus.loading);
    try {

      await er.selectPrimaryAddress(id: id);

      Future.delayed(const Duration(seconds: 1), () {
        getShippingAddressList();
        getShippingAddressDefault();
        getCheckoutList(from: from);
      });

      setStateSelectPrimaryAddressStatus(SelectPrimaryShippingAddressStatus.loaded);
    } catch(_) {
      setStateSelectPrimaryAddressStatus(SelectPrimaryShippingAddressStatus.error);
    }
  }

  Future<void> getCart() async {
    try {

      CartModel cartModel = await er.getCart();
      _cartData = cartModel.data;
      setStateGetCartStatus(GetCartStatus.loaded);

      if(cartData.stores!.isEmpty) {
        setStateGetCartStatus(GetCartStatus.empty);
      }
       
    } catch(_) {
      setStateGetCartStatus(GetCartStatus.error);
    } 
  }

  Future<void> addToCart({
    required String productId,
    required int qty,
    required String note
  }) async {
    controller.forward();
    setStateAddCartStatus(AddCartStatus.loading);
    try {
      String dataCartId = await er.addToCart(note: note, qty: qty, productId: productId);
      setStateAddCartStatus(AddCartStatus.loaded);

      cartId = dataCartId;

      Future.delayed(const Duration(milliseconds: 300), () {
        controller.stop();
        notifyListeners();
      });

      Future.delayed(Duration.zero,() {
        getCart();
      });
    } catch(_) {
      setStateAddCartStatus(AddCartStatus.error);
    }
  }

  Future<void> addToCartLive({
    required String productId,
    required String note
  }) async {
    setStateAddCartLiveStatus(AddCartLiveStatus.loading);
    try {
      String dataCartId = await er.addToCartLive(note: note, productId: productId);
      setStateAddCartLiveStatus(AddCartLiveStatus.loaded);

      cartId = dataCartId;

      Future.delayed(Duration.zero,() {
        getCart();
      });
    } catch(_) {
      setStateAddCartLiveStatus(AddCartLiveStatus.error);
    }
  }

  Future<void> deleteCart({required String cartId}) async {
    setStateDeleteCartStatus(DeleteCartStatus.loading);
    try {
      await er.deleteCart(cartId: cartId);  
      setStateDeleteCartStatus(DeleteCartStatus.loaded);

      Future.delayed(const Duration(seconds: 1),() {
        getCart();
      });
    } catch(_) {
      setStateDeleteCartStatus(DeleteCartStatus.error);
    }
  }

  Future<void> deleteCartLiveAll() async {
    try {
      await er.deleteCartLiveAll();
    } catch(_) {}
  }

  Future<void> getCourierList({
    required BuildContext context,
    required String storeId,
    required String from
  }) async {
    setStateGetCourierStatus(GetCourierStatus.loading);
    try {

      CourierListModel courierList = await er.getCourier(
        storeId: storeId,
        from: from
      );

      showModalBottomSheet(
        context: context, 
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0)
          )
        ),
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: const EdgeInsets.all(15.0),
                    child: Text("Pilih Pengiriman",
                      style: robotoRegular.copyWith(
                        color: ColorResources.black,
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                ],
              ),
                                        
              ListView.separated(
                separatorBuilder: (BuildContext context, int i) {
                  return const Divider(
                    thickness: 2.0,
                    color: Color(0xffF0F0F0),
                  );
                },
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: courierList.data.length,
                itemBuilder: (BuildContext context, int i) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: courierList.data[i].costs.length,
                    itemBuilder: (BuildContext context, int z) {
                      final courierData = courierList.data[i].costs[z];

                      return InkWell(
                        onTap: () async {
                          String courierCode = courierList.data[i].code.toString();
                          String courierService = courierList.data[i].costs[z].service.toString();
                          String courierName = courierList.data[i].name.toString();
                          String courierDesc = courierList.data[i].costs[z].description.toString();
                          String costValue = courierList.data[i].costs[z].cost[0].value.toString();
                          String costNote =  courierList.data[i].costs[z].cost[0].note.toString();
                          String costEtd = courierList.data[i].costs[z].cost[0].etd.toString();

                          courierNameSelect = courierName;

                          await er.addCourier(
                            courierCode: courierCode, 
                            courierService: courierService,
                            courierName: courierName, courierDesc: courierDesc, 
                            costValue: costValue, costNote: costNote, 
                            costEtd: costEtd, storeId: storeId
                          );

                          Future.delayed(const Duration(seconds: 1), () {
                            getCheckoutList(from: from);
                          });

                          Future.delayed(Duration.zero, () {
                            Navigator.pop(context);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 10.0, 
                              right: 10.0
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${courierData.service} (${formatCurrency(courierList.data[i].costs[z].cost[0].value)})",
                                      style: const TextStyle(
                                        fontSize: Dimensions.fontSizeDefault,
                                        fontWeight: FontWeight.bold,
                                        color: ColorResources.black
                                      ),
                                    ),
                                    Container(
                                      width: 60.0,
                                      height: 30.0,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.fitHeight,
                                          image: AssetImage('assets/images/logo/jne.jpg')
                                        )
                                      ),
                                    )
                                  ],
                                ),
                                Text("${courierList.data[i].costs[z].cost[0].etd} hari",
                                  style: const TextStyle(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: ColorResources.black
                                  ),
                                ),
                              ],
                            )
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          );
        },
      );

      setStateGetCourierStatus(GetCourierStatus.loaded);

    } catch(_) {
      setStateGetCourierStatus(GetCourierStatus.error);
    }
  }

  Future<void> clearCourier() async {
    await er.clearCourier();
  }

  void clearPayment() {
    channelId = -1;
    paymentFee = 0;

    notifyListeners();
  } 

  Future<void> getCheckoutList({required String from}) async {
    setStateCheckoutStatus(GetCheckoutStatus.loading);
    try {

      CheckoutListModel checkoutListModel = await er.getCheckoutList(
         from: from
      );
      _checkoutListData = checkoutListModel.data;
      setStateCheckoutStatus(GetCheckoutStatus.loaded);

    } catch(e) {
      setStateCheckoutStatus(GetCheckoutStatus.error);
    }
  }
 
  Future<void> decrementQty({required int i, required int z, required int qty}) async {
    _cartData.stores![i].selected = true;
    _cartData.stores![i].items[z].cart.selected = true;
    _cartData.stores![i].items[z].cart.qty = qty;

    int totalPriceQty = 0;

    listenQty = qty;

    for (StoreItem stores in cartData.stores!.where((el) => el.selected == true)) {
      for (StoreData cii in stores.items.where((el) => el.cart.selected == true)) {
        totalPriceQty += cii.price * cii.cart.qty; 
      }
    }

    _cartData.totalPrice = totalPriceQty;

    await er.updateQty(cartId:  _cartData.stores![i].items[z].cart.id, qty: cartData.stores![i].items[z].cart.qty);

    notifyListeners();
  }

  Future<void> incrementQty({required int i, required int z, required int qty}) async {
    _cartData.stores![i].selected = true;
    _cartData.stores![i].items[z].cart.selected = true;
    _cartData.stores![i].items[z].cart.qty = qty;

    int totalPriceQty = 0;

    listenQty = qty;

    for (StoreItem stores in cartData.stores!.where((el) => el.selected == true)) {
      for (StoreData cii in stores.items.where((el) => el.cart.selected == true)) {
        totalPriceQty += cii.price * cii.cart.qty; 
      }
    }

    _cartData.totalPrice = totalPriceQty;

    await er.updateQty(cartId:  _cartData.stores![i].items[z].cart.id, qty: cartData.stores![i].items[z].cart.qty);

    notifyListeners();
  }

  void incrementTotalProduct(int i, int z, String cartId, String val) {
    var qty = int.parse(val.toString());

    _cartData.stores![i].items[z].cart.qty = qty;

    int totalPrice = 0;
      
    for (StoreItem cis in cartData.stores!.where((el) => el.selected == true).toList()) {
      for (StoreData cii in cis.items.where((el) => el.cart.selected == true).toList()) {
        totalPrice += cii.price * cii.cart.qty;
      }
    }

    _cartData.totalPrice = totalPrice;
   
    notifyListeners();
  }

  Future<void> updateQty({
    required String cartId, 
    required int qty
  }) async {
    await er.updateQty( 
      cartId: cartId, 
      qty: qty
    );
  }

  Future<void> updateNote({required String cartId, required String note}) async {
    try {

      await er.updateNote(
        cartId: cartId, 
        note: note
      );

      notifyListeners();

    } catch(_) {

    }
  }

  Future<List<ProvinceData>> getProvince({required String search}) async {
    try {

      ProvinceModel provinceModel = await er.getProvince(search: search);
      _provinces = [];
      _provinces.addAll(provinceModel.data);

      notifyListeners();

      return provinceModel.data;

    } catch(_) {
      throw [];    
    }
  }

  Future<List<CityData>> getCity({
    required String provinceName,
    required String search
  }) async {
    try {

      CityModel cityModel = await er.getCity(
        provinceName: provinceName,
        search: search
      );
      
      _city = [];
      _city.addAll(cityModel.data);

      notifyListeners();

      return cityModel.data;

    } catch(_) {
      throw [];
    }
  }

  Future<List<DistrictData>> getDistrict({
    required String cityName,
    required String search  
  }) async {
    try {

      DistrictModel districtModel = await er.getDistrict(
        cityName: cityName,
        search: search
      );
      _district = [];
      _district.addAll(districtModel.data);

      notifyListeners();

      return districtModel.data;

    } catch(_) {  
      throw [];
    } 
  }

  Future<List<SubdistrictData>> getSubdistrict({
    required String districtName,
    required String search
  }) async {
    try {

      SubdistrictModel subdistrictModel = await er.getSubdistrict(
        districtName: districtName,
        search: search,
      );
      _subdistrict = [];
      _subdistrict.addAll(subdistrictModel.data);

      notifyListeners();
      
      return subdistrictModel.data;

    } catch(_) {
      throw [];
    }
  }

  Future<void> getBadgeOrderAll() async {
    setStateBadgeOrderAll(BadgeOrderAllStatus.loading);
    try {

      int badgeData = await er.getBadgeOrderAll();

      badge = badgeData;

      setStateBadgeOrderAll(BadgeOrderAllStatus.loaded);

      if(badge == 0) {
        setStateBadgeOrderAll(BadgeOrderAllStatus.empty);
      }

    } catch(_) {
      setStateBadgeOrderAll(BadgeOrderAllStatus.error);
    }
  } 

  Future<void> getBadgeOrderDetail({required String orderStatus}) async {
    setStateBadgeOrderDetail(BadgeOrderDetailStatus.loading);
    try {

      int badgeData = await er.getBadgeOrderStatus(orderStatus: orderStatus);

      if(orderStatus == "WAITING_PAYMENT") {
        badgeWaitingPayment = badgeData;
      }

      if(orderStatus == "PAID") {
        badgePaid = badgeData;
      }

      if(orderStatus == "PACKING") {
        badgePacking = badgeData;
      }

      if(orderStatus == "ON PROCESS") {
        badgeDelivery = badgeData;
      }

      setStateBadgeOrderDetail(BadgeOrderDetailStatus.loaded);

    } catch(_) {
      setStateBadgeOrderDetail(BadgeOrderDetailStatus.error);
    }
  }

  Future<List<PredictionModel>> getAutocomplete(String query) async {
    try {
      Dio dio = Dio();
      Response res = await dio.get("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${RemoteDataSourceConsts.gmaps}");
      Map<String, dynamic> data = res.data;
      AutocompleteModel autocompleteModel = AutocompleteModel.fromJson(data);

      for (var prediction in autocompleteModel.predictions) {
        await addPostalCodeToPrediction(prediction, dio);
      }

      return autocompleteModel.predictions;
    } on DioException catch(e) {
      debugPrint(e.response!.data.toString());
    } catch(e) {
      debugPrint(e.toString());
    }
    return [];
  }

  Future<void> addPostalCodeToPrediction(PredictionModel prediction, Dio dio) async {
    try {
      final placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=${prediction.placeId}"
        "&key=${RemoteDataSourceConsts.gmaps}";

      Response res = await dio.get(placeDetailsUrl);
      Map<String, dynamic> details = res.data;

      List addressComponents = details['result']['address_components'] ?? [];

      String postalCode = "";

      for (var component in addressComponents) {
        var types = (component['types'] as List);

        if (types.isNotEmpty && types.contains('postal_code')) {
          postalCode = component["long_name"].toString();
          break; 
        }
      }

      debugPrint("=== GET POSTAL CODE ${postalCode.toString()} ===");
    } catch (e) {
      debugPrint('Error fetching postal code: $e');
    }
  }


  Future<void> getPaymentChannel({
    required BuildContext context
  }) async {
    setStateGetPaymentChannelStatus(GetPaymentChannelStatus.loading);
    try {

      // BalanceModel balanceModel = await er.getBalance();

      PaymentChannelModel paymentChannelModel = await er.getPaymentChannel();

      setStateGetPaymentChannelStatus(GetPaymentChannelStatus.loaded);
      
      Future.delayed(Duration.zero, () {
        
        showModalBottomSheet(
          context: context, 
          isDismissible: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0)
            )
          ),
          builder: (BuildContext context) {
            return Container(
              height: 560.0,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
              
                      Container(
                        margin: const EdgeInsets.all(15.0),
                        child: Text("Pilih Pembayaran",
                          style: robotoRegular.copyWith(
                            color: ColorResources.black,
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ),
              
                    ],
                  ),
                                      
                  ListView.separated(
                    separatorBuilder: (BuildContext context, int i) {
                      return const Divider(
                        thickness: 2.0,
                      );
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: paymentChannelModel.data.data.where((el) => el.paymentType == "VIRTUAL_ACCOUNT").length,
                    itemBuilder: (BuildContext context, int i) {
                      PaymentChannelItem payment = paymentChannelModel.data.data[i];

                      return Bouncing(
                        onPress: () async {
                          channelId = payment.id;

                          paymentLogo = payment.logo;
                          paymentName = payment.name;
                          paymentCode = payment.nameCode;
                          platform = payment.platform;
                          paymentFee = payment.fee;

                          Future.delayed(Duration.zero, () => notifyListeners());

                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 10.0, 
                              right: 10.0
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [

                                    CachedNetworkImage(
                                      imageUrl: payment.logo,
                                      imageBuilder: (context, imageProvider) {
                                        return Container(
                                          width: 30.0,
                                          height: 30.0,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.fitHeight,
                                              image: imageProvider
                                            )
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(width: 10.0),

                                    Text(payment.name,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: ColorResources.black
                                      ),
                                    ),

                                  ],
                                ),
                                Text("Pilih",
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.black
                                  ),
                                )
                              ],
                            )
                          ),
                        ),
                      );
                      
                    },
                  )
              
                ],
              ),
            );
          }
        );
        
      });

    } catch(_) {
      setStateGetPaymentChannelStatus(GetPaymentChannelStatus.error);
    }
  }

  Future<void> pay({
    required int amount,
    required int cost,
    required String from
  }) async {
    setStatePayStatus(PayStatus.loading);
    
    try {
      
      if(paymentCode == "gopay" || paymentCode == "shopee" || paymentCode == "ovo" || paymentCode == "dana") {

        ResponseMidtransEmoney responseMidtransEmoney = await er.emoneyPay(
          amount: amount, 
          app: "raksha", 
          from: from,
          channelId: channelId, 
          platform: platform,
          paymentCode: paymentCode
        );

        Navigator.pushReplacement(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => PaymentReceiptEmoney(
          amount: amount,
          cost: cost,
          type: paymentName,
          responseMidtransEmoneyData: responseMidtransEmoney.data,
        )));

      } else {
       
        ResponseMidtransVa responseMidtransVa = await er.pay(
          amount: amount, 
          app: "raksha", 
          from: from,
          channelId: channelId, 
          platform: platform,
          paymentCode: paymentCode
        );

        Navigator.pushReplacement(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => PaymentReceiptVaScreen(
          responseMidtransVaData: responseMidtransVa.data,
          amount: amount,
          cost: cost,
        )));

      }

      channelId = -1;

      setStatePayStatus(PayStatus.loaded);
    } catch(_) {
      setStatePayStatus(PayStatus.error);
    }
  }

  Future<void> howToPayment({required String channelId}) async {
    setStateHowToPayment(HowToPaymentStatus.loading);
    try {
      HowToPaymentModel howToPayment = await er.howToPayment(channelId: channelId);

      _atm = [];
      _atm.addAll(howToPayment.data.atm);

      _mbank = [];
      _mbank.addAll(howToPayment.data.mbank);

      _emoney = [];
      _emoney.addAll(howToPayment.data.emoney);

      setStateHowToPayment(HowToPaymentStatus.loaded);
    } catch(_) {
      setStateHowToPayment(HowToPaymentStatus.error);
    }
  }
 
  Future<void> payTopup() async {
     setStatePayStatus(PayStatus.loading);
    
    try {

      if(paymentCode == "gopay" || paymentCode == "shopee" || paymentCode == "ovo" || paymentCode == "dana") {

        ResponseMidtransEmoney responseMidtransEmoney = await er.emoneyPayTopup(
          amount: selectedTopupPrice, 
          app: "raksha", 
          channelId: channelId, 
          platform: platform,
          paymentCode: paymentCode
        );

        Navigator.pushReplacement(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) =>  PaymentReceiptEmoney(
          amount: selectedTopupPrice,
          cost: 0,
          responseMidtransEmoneyData: responseMidtransEmoney.data,
          type: paymentName,
        )));

      } else {
       
        ResponseMidtransVa responseMidtransVa = await er.payTopup(
          amount: selectedTopupPrice, 
          app: "raksha", 
          channelId: channelId, 
          platform: platform,
          paymentCode: paymentCode
        );

        Navigator.pushReplacement(navigatorKey.currentContext!, MaterialPageRoute(builder: (context) => PaymentReceiptVaScreen(
          amount: selectedTopupPrice,
          cost: 0,
          responseMidtransVaData: responseMidtransVa.data,
        )));

      }

      channelId = -1;

      setStatePayStatus(PayStatus.loaded);
    } catch(_) {
      setStatePayStatus(PayStatus.error);
    }
  } 

}