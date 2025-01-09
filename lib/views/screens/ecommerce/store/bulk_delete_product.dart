import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class BulkDeleteProductScreen extends StatefulWidget {
  final String storeId;
  const BulkDeleteProductScreen({
    required this.storeId,
    super.key
  });

  @override
  State<BulkDeleteProductScreen> createState() => BulkDeleteProductScreenState();
}

class BulkDeleteProductScreenState extends State<BulkDeleteProductScreen> {

  late EcommerceProvider ecommerceProvider;

  Future<void> getData() async {

    if(!mounted) return;
      await ecommerceProvider.fetchAllProductSeller(search: "", storeId: widget.storeId);
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
      appBar: AppBar(
        backgroundColor: ColorResources.backgroundColor,
        centerTitle: true,
        elevation: 0.0,
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Hapus Produk",
          style: robotoRegular.copyWith(
            color: ColorResources.black,
            fontSize: Dimensions.fontSizeDefault,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Consumer<EcommerceProvider>(
        builder: (_, notifier, __) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
          
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    
                    Expanded(
                      flex: 14,
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0
                        ),
                        child: CheckboxListTile(
                          value: notifier.selectedAllProduct,
                          onChanged: (bool? val) {
                            notifier.onSelectedAllProduct(val!);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text("Pilih semua",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: ColorResources.black
                            ),
                          ),
                        ),
                      ),
                    ),
            
                    notifier.productSellers.isEmpty 
                    ? const Flexible(
                        flex: 2,
                        child: SizedBox()
                      ) 
                    : Flexible(
                        flex: 2,
                        child: SizedBox(
                        width: 28.0,
                        height: 28.0,
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: notifier.selectedAllProduct 
                            ? ColorResources.error 
                            : ColorResources.grey,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6.0)
                            )
                          ),
                          child: GestureDetector(
                            onTap: notifier.selectedAllProduct 
                            ? () async {
                                showGeneralDialog(
                                  context: context,
                                  barrierLabel: "Barrier",
                                  barrierDismissible: true,
                                  barrierColor: Colors.black.withOpacity(0.5),
                                  transitionDuration: const Duration(milliseconds: 700),
                                  pageBuilder: (BuildContext context, Animation<double> double, _) {
                                    return Center(
                                      child: Material(
                                        color: ColorResources.transparent,
                                        child: Container(
                                          margin: const EdgeInsets.all(20.0),
                                          height: 250.0,
                                          decoration: BoxDecoration(
                                            color: ColorResources.primary, 
                                            borderRadius: BorderRadius.circular(20.0)
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                                                              
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text("Apakah kamu yakin ingin hapus Produk ?",
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions.fontSizeDefault,
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorResources.white
                                                  ),
                                                )
                                              ),
                                                                              
                                              Align(
                                                alignment: Alignment.bottomCenter,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(
                                                        top: 20.0,
                                                        bottom: 20.0
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: [
                                                          const Expanded(child: SizedBox()),
                                                          Expanded(
                                                            flex: 5,
                                                            child: CustomButton(
                                                              isBorderRadius: true,
                                                              isBoxShadow: false,
                                                              btnColor: ColorResources.white,
                                                              btnTextColor: ColorResources.black,
                                                              onTap: () {
                                                                Navigator.pop(context);
                                                              }, 
                                                              btnTxt: "Batal"
                                                            ),
                                                          ),
                                                          const Expanded(child: SizedBox()),
                                                          Expanded(
                                                            flex: 5,
                                                            child: Consumer<EcommerceProvider>(
                                                              builder: (_, notifier, __) {
                                                                return CustomButton(
                                                                  isBorderRadius: true,
                                                                  isBoxShadow: false,
                                                                  isLoading: notifier.deleteProductStatus == DeleteProductStatus.loading 
                                                                  ? true 
                                                                  : false,
                                                                  btnColor: ColorResources.error,
                                                                  btnTextColor: ColorResources.white,
                                                                  onTap: () async {
                                                                    await notifier.deleteProductSelect();
                                                                    Future.delayed(Duration.zero, () {
                                                                      Navigator.pop(context);
                                                                    });
                                                                  }, 
                                                                  btnTxt: "OK"
                                                                );
                                                              },
                                                            )
                                                          ),
                                                          const Expanded(child: SizedBox()),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ) 
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    );
                                  },
                                  transitionBuilder: (_, anim, __, child) {
                                    Tween<Offset> tween;
                                    if (anim.status == AnimationStatus.reverse) {
                                      tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
                                    } else {
                                      tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
                                    }
                                    return SlideTransition(
                                      position: tween.animate(anim),
                                      child: FadeTransition(
                                        opacity: anim,
                                        child: child,
                                      ),
                                    );
                                  },
                                );
                              } 
                            : () {},
                            child: const Icon(
                              Icons.delete,
                              size: 15.0,
                              color: ColorResources.white,
                            ),
                          )
                        )
                      ),
                    )
                  ],
                ),
          
              if(notifier.listProductStatus == ListProductStatus.loaded)
                ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                    bottom: 20.0,                           
                    left: 8.0,
                    right: 8.0
                  ),
                  itemCount: notifier.productSellers.length,
                  itemBuilder: (BuildContext context, int i) {
                    return CheckboxListTile(
                      value: notifier.productSellers[i].selected,
                      onChanged: (bool? val) {
                        notifier.onSelectedProduct(
                          id: notifier.productSellers[i].id, 
                          val: val!
                        );
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                      
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                      
                              CachedNetworkImage(
                                imageUrl: notifier.productSellers[i].medias.isNotEmpty 
                                ? notifier.productSellers[i].medias.first.path 
                                : '-',
                                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                  return Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(6.0)
                                      ),
                                      image: DecorationImage(image: imageProvider)
                                    ),
                                  );
                                },
                                placeholder: (BuildContext context, String url) {
                                  return Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(6.0)
                                      ),
                                      image: DecorationImage(image: AssetImage('assets/images/default_image.png'))
                                    ),
                                  );
                                },
                                errorWidget: (BuildContext context, String url, dynamic error) {
                                  return Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(6.0)
                                      ),
                                      image: DecorationImage(image: AssetImage('assets/images/default_image.png'))
                                    ),
                                  );
                                },
                              ),
                      
                              const SizedBox(width: 10.0),
                      
                              Text(notifier.productSellers[i].title,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                      
                            ],
                          ),
                        ],
                      ),
                    );                   
                  },
                )
              ],
            )
             
          );
        }
      )
    );
  }
}