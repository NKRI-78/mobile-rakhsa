import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:provider/provider.dart';

import 'package:rakhsa/data/models/ecommerce/product/category.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

import 'package:rakhsa/views/screens/ecommerce/cart/cart.dart';
import 'package:rakhsa/views/screens/ecommerce/order/buyer/list.dart';
import 'package:rakhsa/views/screens/ecommerce/product/widget/product_item.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {

  Timer? debounce;

  late TextEditingController searchC;
  late FocusNode searchFn;

  late EcommerceProvider ep;

  Future<void> getData() async {
    if(!mounted) return; 
      await ep.fetchAllProduct(search: "");

    if(!mounted) return;
      await ep.fetchAllProductCategory(isFromCreateProduct: false);

    if(!mounted) return;
      await ep.getBadgeOrderAll();

    if(!mounted) return;
      await ep.getCart();
  }

  @override 
  void initState() {
    super.initState();
    
    searchC = TextEditingController();
    searchFn = FocusNode();

    ep = context.read<EcommerceProvider>();

    searchC.addListener(() {

      if(searchC.text.isNotEmpty) {
        if (debounce?.isActive ?? false) debounce?.cancel();
          debounce = Timer(const Duration(milliseconds: 1000), () {
            ep.fetchAllProduct(search: searchC.text);
          });
      }

    });

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    debounce?.cancel();

    searchC.dispose();
    searchFn.dispose();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EcommerceProvider>(
        builder: (_, notifier, __) {
          return NotificationListener(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                notifier.reached = true;

                if(notifier.hasMore) {
                  notifier.loadMoreProduct(); 
                }
              }
              return true;
            },
            child: RefreshIndicator.adaptive(
              onRefresh: () {
                return Future.sync(() {
                  getData();
                });
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()
                ),
                slivers: [
              
                  SliverAppBar(
                    title: Text("Toko HP3KI",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: ColorResources.black
                      ),
                    ),
                    centerTitle: true,
                    leading: CupertinoNavigationBarBackButton(
                      color: ColorResources.black,
                      onPressed: () {
                   Navigator.pop(context);
                      },
                    ),
                    actions: [
                       notifier.getProductCategoryStatus == GetProductCategoryStatus.loading 
                      ? const SizedBox() 
                      : notifier.getProductCategoryStatus == GetProductCategoryStatus.empty 
                      ? const SizedBox() 
                      : notifier.getProductCategoryStatus == GetProductCategoryStatus.error 
                      ? const SizedBox() 
                      : IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (BuildContext context) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                   height: MediaQuery.of(context).size.height * 0.5,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    Text("Pilih Kategori",
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const Divider(),
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: notifier.productCategories.length,
                                        itemBuilder: (BuildContext context, int i) {
                                          ProductCategoryData category = notifier.productCategories[i];
                                          return ListTile(
                                            title: Text(category.name,
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeDefault,
                                                fontWeight: notifier.cat == category.name 
                                                ? FontWeight.bold 
                                                : FontWeight.normal
                                              ),
                                            ),
                                            onTap: () {
                                              notifier.selectCat(
                                                param: category.name, 
                                                storeId: ""
                                              );
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }, 
                        splashRadius: 15.0,
                        icon: const Icon(
                          Icons.filter_alt_sharp,
                        )
                      )
                    ],
                  ),
              
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 16.0,
                        right: 16.0
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                  
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                NS.push(context, const ListOrderBuyerScreen());
                              },
                              child: notifier.badgeOrderAllStatus == BadgeOrderAllStatus.loading 
                              ? const Icon(Icons.list)
                              : notifier.badgeOrderAllStatus == BadgeOrderAllStatus.empty 
                              ? const Icon(Icons.list)
                              : notifier.badgeOrderAllStatus == BadgeOrderAllStatus.error 
                              ? const Icon(Icons.list)
                              : Badge(
                                  offset: const Offset(-35, 0),
                                  label: Text(notifier.badge.toString(),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  child: const Icon(Icons.list)
                                )
                            )
                          ),
            
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: searchC,
                              focusNode: searchFn,
                              cursorColor: ColorResources.black,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: ColorResources.black
                              ),
                              decoration: InputDecoration(
                                labelText: "Cari Produk",
                                labelStyle: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                                contentPadding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 16.0,
                                  right: 16.0
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                                )
                              ),
                            ),
                          ),
                  
                          const SizedBox(width: 15.0),
            
                          if(notifier.getCartStatus == GetCartStatus.loading)
                            Bouncing(
                              onPress: () {
                                NS.push(context, const CartScreen());
                              },
                              child: const Icon(
                                Icons.shopping_cart,
                                size: 20.0
                              ),
                            ),
            
                          if(notifier.getCartStatus == GetCartStatus.error)
                            Bouncing(
                              onPress: () {
                                NS.push(context, const CartScreen());
                              },
                              child: const Icon(
                                Icons.shopping_cart,
                                size: 20.0
                              ),
                            ),
            
                          if(notifier.getCartStatus == GetCartStatus.empty)
                            Bouncing(
                              onPress: () {
                                NS.push(context, const CartScreen());
                              },
                              child: const Icon(
                                Icons.shopping_cart,
                                size: 20.0
                              ),
                            ),
                        
                          if(notifier.getCartStatus == GetCartStatus.loaded)
                            Bouncing(
                              onPress: () {
                                NS.push(context, const CartScreen());
                              },
                              child: Badge(
                                label: Text(notifier.cartData.totalItem.toString(),
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shopping_cart,
                                  size: 20.0
                                ),
                              ),
                            ),
            
                        ],
                      )
                    )
                  ),

                  if(notifier.listProductStatus == ListProductStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: CircularProgressIndicator.adaptive()
                        )
                      )
                    ),
              
                  if(notifier.listProductStatus == ListProductStatus.error)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text("Hmm... Mohon tunggu yaa",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault
                          ),
                        )
                      )
                    ),
                  
                  if(notifier.listProductStatus == ListProductStatus.empty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text("Yaa.. Produk tidak ditemukan",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault
                          ),
                        )
                      )
                    ),
              
                  if(notifier.listProductStatus == ListProductStatus.loaded)
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: MediaQuery.of(context).size.width > 400 
                          ? 2.0 / 2.6
                          : 2.0 / 3.0,
                          mainAxisSpacing: 10.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int i) {
                            if (i < notifier.products.length) {
                              final product = notifier.products[i];
                              return ProductItem(product: product);
                            } else if (notifier.hasMore) {
                              if(notifier.reached) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return const SizedBox();
                            } else {
                              return const SizedBox.shrink(); 
                            }
                          },
                          childCount: notifier.hasMore
                          ? notifier.products.length + 1 
                          : notifier.products.length,
                        ),
                      ),
                    ),
              
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}