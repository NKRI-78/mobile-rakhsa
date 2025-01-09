import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:rakhsa/views/screens/ecommerce/order/seller/list.dart';
import 'package:rakhsa/views/screens/ecommerce/store/add_product.dart';
import 'package:rakhsa/views/screens/ecommerce/store/bulk_delete_product.dart';
import 'package:rakhsa/views/screens/ecommerce/store/create_update_store.dart';
import 'package:rakhsa/views/screens/ecommerce/store/seller/products.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';


class StoreInfoScreen extends StatefulWidget {
  final String storeId;
  const StoreInfoScreen({
    required this.storeId,
    super.key
  });

  @override
  State<StoreInfoScreen> createState() => StoreInfoScreenState();
}

class StoreInfoScreenState extends State<StoreInfoScreen> {
  
  late EcommerceProvider ecommerceProvider;

  Future<void> getData() async {
    if(!mounted) return;
      await ecommerceProvider.getStore();
  }

  @override
  void initState() {
    super.initState();

    ecommerceProvider = context.read<EcommerceProvider>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          return Future.sync(() {
            getData();
          });
        },
        child: Consumer<EcommerceProvider>(
          builder: (__, notifier, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [

                if(notifier.getStoreStatus == GetStoreStatus.loading)
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

                if(notifier.getStoreStatus == GetStoreStatus.error)
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
                  
                if(notifier.getStoreStatus == GetStoreStatus.loaded)
                  SliverAppBar(
                    title: Text("Toko Saya",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: ColorResources.black
                      ),
                    ),
                    toolbarHeight: 150.0,
                    centerTitle: true,
                    leading: CupertinoNavigationBarBackButton(
                      color: ColorResources.black,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    bottom: PreferredSize(
                     preferredSize: const Size.fromHeight(80.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFC82927),
                        ),
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            const Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                                    
                            Expanded(
                              flex: 6,
                              child: CachedNetworkImage(
                                imageUrl: notifier.store!.data!.logo.toString(),
                                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                  return CircleAvatar(
                                    maxRadius: 30.0,
                                    backgroundImage: imageProvider,
                                  );
                                },
                                errorWidget: (BuildContext context, String url, Object error) {
                                  return const CircleAvatar(
                                    maxRadius: 30.0,
                                    backgroundImage: AssetImage('assets/images/default_image.png'),
                                  );
                                },
                                placeholder: (BuildContext context, String url) {
                                  return const CircleAvatar(
                                    maxRadius: 30.0,
                                    backgroundImage: AssetImage('assets/images/default_image.png'),
                                  );
                                },
                              ),
                            ),

                            const Expanded(
                              flex: 3,
                              child: SizedBox(),
                            ),

                            Expanded(
                              flex: 28,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                              
                                  SelectableText(notifier.store!.data?.name ?? "-",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                      color: ColorResources.white
                                    ),
                                  ),

                                  const SizedBox(height: 8.0),

                                  SelectableText(notifier.store!.data?.address ?? "-",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: ColorResources.white
                                    ),
                                  ),

                                  const SizedBox(height: 8.0),

                                  SelectableText(notifier.store!.data?.phone ?? "-",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: ColorResources.white
                                    ),
                                  ),

                                  const SizedBox(height: 4.0),

                                   SelectableText(notifier.store!.data?.email ?? "-",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: ColorResources.white
                                    ),
                                  ),
                                      
                                ],
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [

                        IconButton(
                          splashRadius: 20.0,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  const CreateStoreOrUpdateScreen()));
                          },
                          icon: const Icon(Icons.edit,
                            color: ColorResources.blue,
                            size: 16.0,
                          )
                        ),

                        IconButton(
                          splashRadius: 20.0,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => BulkDeleteProductScreen(storeId: widget.storeId)));
                          },
                          icon: const Icon(Icons.delete,
                            color: ColorResources.error,
                            size: 16.0,
                          )
                        ),

                        IconButton(
                          splashRadius: 20.0,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen(storeId: widget.storeId)));
                          },
                          icon: const Icon(Icons.add,
                            color: ColorResources.success,
                            size: 16.0,
                          )
                        ),

                      ],
                    ),
                  ),
            
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      const Divider(
                        height: 1.0,
                        color: ColorResources.black,
                      ),

                      ListTile(
                        dense: true,
                        title: Text("Daftar Produk",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: ColorResources.black
                          ),
                        ),
                        leading: const Icon(Icons.list),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsSellerScreen(storeId: notifier.store!.data?.id ?? "-")));
                        },
                      ),

                      const Divider(
                        height: 1.0,
                        color: ColorResources.black,
                      ),

                      ListTile(
                        dense: true,
                        title: Text("Daftar Transaksi",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: ColorResources.black
                          ),
                        ),
                        leading: const Icon(Icons.list),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ListOrderSellerScreen()));
                        },
                      ),

                      const Divider(
                        height: 1.0,
                        color: ColorResources.black,
                      ),
                                                    
                    ])
                  ),
                )
            
              ],
            );
          }
        ),
      )
    );
  }
}