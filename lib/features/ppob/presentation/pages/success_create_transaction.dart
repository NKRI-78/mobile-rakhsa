import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class SuccessCreateTransactioPage extends StatefulWidget {
  final String productName;
  final int productPrice;
  final String productType;
  final String orderId;
  final String paymentName;
  final String paymentAccess;
  final String paymentType;

  const SuccessCreateTransactioPage({
    super.key, 
    required this.productName,
    required this.productPrice,
    required this.productType,
    required this.orderId,
    required this.paymentName,
    required this.paymentAccess,
    required this.paymentType
  });

  @override
  State<SuccessCreateTransactioPage> createState() => SuccessCreateTransactioPageState();
}

class SuccessCreateTransactioPageState extends State<SuccessCreateTransactioPage> {

  @override
  void initState() {
    super.initState();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? val) {
        if(!didPop) return;
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: 180.0,
            child: CustomButton(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  RoutesNavigation.dashboard, (route) => route.isFirst
                );
              }, 
              isBorderRadius: true,
              isBorder: false,
              isBoxShadow: false,
              fontSize: Dimensions.fontSizeSmall,
              btnTxt: "Halaman Utama"
            ),
          )
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
      
            SliverAppBar(
              title: Text("Info Transaksi",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: ColorResources.black
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),

            SliverPadding(
              padding: const EdgeInsets.only(
                top: 15.0,
                left: 20.0,
                right: 20.0,
                bottom: 15.0
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  fieldTransaction(name: "Order ID", value: widget.orderId),

                  const SizedBox(height: 14.0),

                  fieldTransaction(name: "Nama Produk", value: widget.productName),

                  const SizedBox(height: 14.0),

                  fieldTransaction(name: "Jenis Produk", value: widget.productType),

                  const SizedBox(height: 14.0),

                  fieldTransaction(name: "Metode Pembayaran", value: widget.paymentType.toUpperCase()),

                  const SizedBox(height: 14.0),

                  fieldTransaction(name: "Nama Pembayaran", value: widget.paymentName.toUpperCase()),

                  const SizedBox(height: 14.0),

                  fieldTransaction(name: "Harga", value: formatCurrency(widget.productPrice)),

                  const SizedBox(height: 14.0),

                  if(widget.paymentType == "va") 
                    Container(
                      margin: const EdgeInsets.only(
                        top: 30.0,
                        left: 16.0,
                        right: 16.0
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("No Virtual Account",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: ColorResources.black,
                              )
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(widget.paymentAccess,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeOverLarge,
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.black,
                                  )
                                ),
                                const SizedBox(width: 5.0),
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: widget.paymentAccess.toString()
                                    ));
                                    ShowSnackbar.snackbarDefault("${widget.paymentAccess.toString()} disalin");
                                  },
                                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(Icons.copy,
                                      size: 20.0,
                                      color: ColorResources.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ) 
                      ),
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   mainAxisSize: MainAxisSize.max,
                    //   children: [
                    //     Expanded(
                    //       flex: 6,
                    //       child: Row(
                    //         children: [
                    //           Text(
                    //             "No Virtual Akun",
                    //             style: robotoRegular.copyWith(
                    //               fontSize: Dimensions.fontSizeDefault,
                    //               fontWeight: FontWeight.bold,
                    //               color: ColorResources.black,
                    //             ),
                    //           ),
                    //           Expanded(
                    //             child: IconButton(
                    //               icon: const Icon(
                    //                 Icons.copy, 
                    //                 size: 13.0, 
                    //                 color: Colors.grey
                    //               ),
                    //               onPressed: () {
                    //                 Clipboard.setData(ClipboardData(text: "${widget.paymentAccess} disalin"));
                    //                 ScaffoldMessenger.of(context).showSnackBar(
                    //                   SnackBar(
                    //                     content: Text(
                    //                       widget.paymentAccess,
                    //                       style: robotoRegular.copyWith(
                    //                         color: ColorResources.black,
                    //                         fontSize: Dimensions.fontSizeDefault
                    //                       ),
                    //                     )
                    //                   ),
                    //                 );
                    //               },
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     Expanded(
                    //       flex: 6,
                    //       child: Text(
                    //         ":",
                    //         style: robotoRegular.copyWith(
                    //           fontSize: Dimensions.fontSizeDefault,
                    //         ),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       flex: 4,
                    //       child: Text(
                    //         widget.paymentAccess,
                    //         style: robotoRegular.copyWith(
                    //           fontSize: Dimensions.fontSizeDefault,
                    //           color: ColorResources.black,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // Row(
                    //   mainAxisSize: MainAxisSize.max,
                    //   children: [

                    //     Expanded(child: fieldTransaction(name: "Nomor Virtual Account", value: widget.paymentAccess)),

                    //     Expanded(
                    //       child: InkWell(
                    //         onTap: () async {
                    //           await Clipboard.setData(
                    //             ClipboardData(text: widget.paymentAccess.toString()
                    //           ));
                    //           ShowSnackbar.snackbarDefault("${widget.paymentAccess.toString()} disalin");
                    //         },
                    //         borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    //         child: const Padding(
                    //           padding: EdgeInsets.all(6.0),
                    //           child: Icon(Icons.copy,
                    //             size: 15.0,
                    //             color: ColorResources.black,
                    //           ),
                    //         ),
                    //       ),
                    //     )
                    //   ],
                    // ),

                  if(widget.paymentType != "va")
                    CachedNetworkImage(
                      imageUrl: widget.paymentAccess.toString(),
                      imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                        return Container(
                          width: double.infinity,
                          height: 330.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: imageProvider
                            )
                          ),
                        );
                      },
                      placeholder: (BuildContext context, String url) {
                        return Container(
                          width: double.infinity,
                          height: 330.0,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('assets/images/default_image.png')
                            )
                          ),
                        );
                      },
                      errorWidget: (BuildContext context, String url, Object error) {
                        return Container(
                          width: double.infinity,
                          height: 330.0,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('assets/images/default_image.png')
                            )
                          ),
                        );
                      },
                    )
                    

                ])
              ),
            )
      
          ],
        )
      ),
    );
  }


  Widget fieldTransaction({required String name, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [

        Expanded(
          flex: 6,
          child: Text(name,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: ColorResources.black
            ),
          )
        ),

        Expanded(
          flex: 6,
          child: Text(":",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            ),
          )
        ),

        Expanded(
          flex: 6,
          child: Text(value,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: ColorResources.black
            ),
          )
        )
      ],
    );
  }

}