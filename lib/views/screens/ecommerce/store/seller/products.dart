import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/data/models/ecommerce/product/category.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/views/screens/ecommerce/product/widget/product_item.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

class ProductsSellerScreen extends StatefulWidget {
  final String storeId;

  const ProductsSellerScreen({
    required this.storeId,
    super.key
  });

  @override
  State<ProductsSellerScreen> createState() => ProductsSellerScreenState();
}

class ProductsSellerScreenState extends State<ProductsSellerScreen> {

  Timer? debounce;

  late TextEditingController searchC;
  late FocusNode searchFn;

  late EcommerceProvider ep;

  Future<void> getData() async {
    if(!mounted) return; 
      await ep.fetchAllProductSeller(search: "", storeId: widget.storeId);
      
    if(!mounted) return;
      await ep.fetchAllProductCategory(isFromCreateProduct: false);
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
            ep.fetchAllProductSeller(
              search: searchC.text, 
              storeId: widget.storeId
            );
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
                    title: Text("Daftar Produk",
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
                                                storeId: widget.storeId
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
                    ]
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
                            flex: 5,
                            child: TextField(
                              controller: searchC,
                              focusNode: searchFn,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: ColorResources.black
                              ),
                              decoration: InputDecoration(
                                labelText: "Cari Produk",
                                labelStyle: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: ColorResources.black
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
                          : 2.0 / 3.3,
                          mainAxisSpacing: 10.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int i) {
                            if (i < notifier.productSellers.length) {
                              final product = notifier.productSellers[i];
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
                          ? notifier.productSellers.length + 1 
                          : notifier.productSellers.length,
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