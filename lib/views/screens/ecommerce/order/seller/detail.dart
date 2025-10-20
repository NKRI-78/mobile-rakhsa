// import 'dart:io';
// import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
// import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:date_count_down/date_count_down.dart';
import 'package:barcode_widget/barcode_widget.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:rakhsa/common/helpers/ddmmyyyy.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/grams_to_kg.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

import 'package:rakhsa/views/screens/ecommerce/order/tracking.dart';

class DetailOrderSellerScreen extends StatefulWidget {
  final String transactionId;
  final String storeId;

  const DetailOrderSellerScreen({
    required this.transactionId,
    required this.storeId,
    super.key,
  });

  @override
  State<DetailOrderSellerScreen> createState() =>
      DetailOrderSellerScreenState();
}

class DetailOrderSellerScreenState extends State<DetailOrderSellerScreen> {
  bool btnUnduhResi = true;
  bool icCopyResi = true;

  late EcommerceProvider ep;

  Future<void> getData() async {
    if (!mounted) return;
    await ep.detailOrderSeller(
      transactionId: widget.transactionId,
      storeId: widget.storeId,
    );
  }

  // Future<void> takeScreenshot() async {
  //   setState(() {
  //     btnUnduhResi = false;
  //     icCopyResi = false;
  //   });

  //   try {

  // Future.delayed(const Duration(seconds: 1), () async {
  //   RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List pngBytes = byteData!.buffer.asUint8List();

  //   final directory = (await getApplicationDocumentsDirectory()).path;
  //   String fileName = 'screenshot.png';
  //   File imgFile = File('$directory/$fileName');
  //   imgFile.writeAsBytes(pngBytes);

  //   await GallerySaver.saveImage(imgFile.path);
  // });

  // Future.delayed(const Duration(seconds: 2), () {
  //   setState(() {
  //     btnUnduhResi = true;
  //     icCopyResi = true;
  //   });
  // });

  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Screenshot saved!')));
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to take screenshot: $e')));
  //   }
  // }

  @override
  void initState() {
    super.initState();

    ep = context.read<EcommerceProvider>();

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
        title: Text(
          "Detail Pesanan",
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            fontWeight: FontWeight.bold,
            color: ColorResources.black,
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<EcommerceProvider>(
        builder: (BuildContext context, EcommerceProvider notifier, Widget? child) {
          if (notifier.detailOrderSellerStatus ==
              DetailOrderSellerStatus.loading) {
            return const Center(
              child: SizedBox(
                width: 32.0,
                height: 32.0,
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
          if (notifier.detailOrderSellerStatus ==
              DetailOrderSellerStatus.error) {
            return Center(
              child: Text(
                "Hmm... Mohon tunggu yaa",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20.0,
              left: 16.0,
              right: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notifier.detailOrderSellerData.invoice.toString(),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: ColorResources.black,
                        ),
                      ),

                      notifier.detailOrderSellerData.expire == null
                          ? const SizedBox()
                          : notifier.detailOrderSellerData.item!.orderStatus ==
                                "WAITING_PAYMENT"
                          ? Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: ColorResources.countdown,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: CountDownText(
                                due: notifier.detailOrderSellerData.expire,
                                finishedText: "Kedaluwarsa",
                                showLabel: false,
                                longDateName: true,
                                daysTextLong: " Hari ",
                                hoursTextLong: " Jam ",
                                minutesTextLong: " Menit ",
                                secondsTextLong: " Detik ",
                                style: robotoRegular.copyWith(
                                  color: ColorResources.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),

                  const SizedBox(height: 10.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDateDDMMYYYY(
                          notifier.detailOrderSellerData.createdAt!,
                        ),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: ColorResources.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          orderStatus(
                            notifier.detailOrderSellerData.item!.orderStatus
                                .toString(),
                          ),
                          style: robotoRegular.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeSmall,
                            color: ColorResources.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10.0),

                  const Divider(color: ColorResources.hintColor),

                  const SizedBox(height: 15.0),

                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            notifier.detailOrderSellerData.item?.store.logo ??
                            "-",
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        placeholder: (BuildContext context, String url) {
                          return const Center(
                            child: SizedBox(
                              width: 32.0,
                              height: 32.0,
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        },
                        errorWidget:
                            (BuildContext context, String url, dynamic error) {
                              return Container(
                                width: 45.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://dummyimage.com/300x300/000/fff',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                      ),

                      const SizedBox(width: 8.0),

                      Text(
                        notifier.detailOrderSellerData.item?.store.name ?? "-",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        notifier.detailOrderSellerData.item!.products.length,
                    itemBuilder: (BuildContext context, int i) {
                      final item =
                          notifier.detailOrderSellerData.item!.products[i];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10.0,
                              bottom: 10.0,
                            ),
                            child: Card(
                              elevation: 0.30,
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: item.product.medias.isEmpty
                                              ? "https://dummyimage.com/300x300/000/fff"
                                              : item.product.medias.first.path,
                                          imageBuilder:
                                              (context, imageProvider) {
                                                return Container(
                                                  width: 45.0,
                                                  height: 45.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5.0,
                                                        ),
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                          placeholder:
                                              (
                                                BuildContext context,
                                                String url,
                                              ) {
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 32.0,
                                                    height: 32.0,
                                                    child:
                                                        CircularProgressIndicator.adaptive(),
                                                  ),
                                                );
                                              },
                                          errorWidget:
                                              (
                                                BuildContext context,
                                                String url,
                                                dynamic error,
                                              ) {
                                                return Container(
                                                  width: 45.0,
                                                  height: 45.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5.0,
                                                        ),
                                                    image: const DecorationImage(
                                                      image: NetworkImage(
                                                        'https://dummyimage.com/300x300/000/fff',
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),

                                        const SizedBox(width: 12.0),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 200.0,
                                              child: Text(
                                                item.product.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: robotoRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 5.0),

                                            Text(
                                              "${formatCurrency(item.product.price)} x ${item.qty}",
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    item.product.note.isEmpty
                                        ? const SizedBox()
                                        : const SizedBox(height: 10.0),

                                    item.product.note.isEmpty
                                        ? const SizedBox()
                                        : Text(
                                            "Catatan : ${item.product.note}",
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          RepaintBoundary(
                            key: GlobalKey(),
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: const BoxDecoration(
                                color: ColorResources.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        "Kurir",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      // btnUnduhResi
                                      // ? notifier.detailOrderSellerData.item!.waybill == "-"
                                      // ? const SizedBox()
                                      // : InkWell(
                                      //     onTap: () async {
                                      //       await takeScreenshot();
                                      //     },
                                      //     child: Text("Unduh resi",
                                      //       style: robotoRegular.copyWith(
                                      //         color: ColorResources.blue,
                                      //         fontSize: Dimensions.fontSizeSmall
                                      //       ),
                                      //     )
                                      //   )
                                      // : const SizedBox()
                                    ],
                                  ),

                                  const SizedBox(height: 5.0),

                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Nama",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),

                                      Text(
                                        item.courierId.toUpperCase(),
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5.0),

                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Layanan",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),

                                      Text(
                                        item.courierService,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5.0),

                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Biaya",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),

                                      Text(
                                        formatCurrency(item.courierPrice),
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5.0),

                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Berat",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),

                                      Text(
                                        gramsToKilograms(
                                          double.parse(
                                            item.courierWeight.toString(),
                                          ),
                                        ),
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15.0),

                                  notifier
                                              .detailOrderSellerData
                                              .item!
                                              .waybill ==
                                          "-"
                                      ? const SizedBox()
                                      : BarcodeWidget(
                                          height: 50.0,
                                          barcode: Barcode.code128(),
                                          margin: EdgeInsets.zero,
                                          padding: EdgeInsets.zero,
                                          drawText: false,
                                          data: notifier
                                              .detailOrderSellerData
                                              .item!
                                              .waybill,
                                        ),

                                  notifier
                                              .detailOrderSellerData
                                              .item!
                                              .waybill ==
                                          "-"
                                      ? const SizedBox()
                                      : const SizedBox(height: 15.0),

                                  notifier
                                              .detailOrderSellerData
                                              .item!
                                              .waybill ==
                                          "-"
                                      ? const SizedBox()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  "No Resi",
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: ColorResources.black,
                                                  ),
                                                ),

                                                icCopyResi
                                                    ? InkWell(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                            ClipboardData(
                                                              text: notifier
                                                                  .detailOrderSellerData
                                                                  .item!
                                                                  .waybill,
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                notifier
                                                                    .detailOrderSellerData
                                                                    .item!
                                                                    .waybill,
                                                                style: robotoRegular
                                                                    .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeDefault,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                5.0,
                                                              ),
                                                          child: Icon(
                                                            Icons.copy,
                                                            size: 12.0,
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),

                                            Text(
                                              notifier
                                                  .detailOrderSellerData
                                                  .item!
                                                  .waybill,
                                              style: robotoRegular.copyWith(
                                                color: ColorResources.primary,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),

                                  const SizedBox(height: 8.0),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Pengirim",
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              notifier
                                                      .detailOrderSellerData
                                                      .item
                                                      ?.store
                                                      .name ??
                                                  "-",
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: ColorResources.black,
                                              ),
                                            ),

                                            const SizedBox(height: 5.0),

                                            Text(
                                              item.seller.phone,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: ColorResources.black,
                                              ),
                                            ),

                                            const SizedBox(height: 5.0),

                                            Text(
                                              item.seller.address,
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                                color: ColorResources.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10.0),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Penerima",
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              item.buyer.fullname,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: ColorResources.black,
                                              ),
                                            ),

                                            const SizedBox(height: 5.0),

                                            Text(
                                              item.buyer.phone,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: ColorResources.black,
                                              ),
                                            ),

                                            const SizedBox(height: 5.0),

                                            Text(
                                              item.buyer.address,
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                                color: ColorResources.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          notifier.detailOrderSellerData.item!.waybill == "-"
                              ? const SizedBox()
                              : const SizedBox(height: 6.0),

                          const Divider(color: ColorResources.hintColor),

                          const SizedBox(height: 10.0),

                          notifier.detailOrderSellerData.item!.waybill == "-"
                              ? const SizedBox()
                              : CustomButton(
                                  onTap: () {
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => TrackingScreen(waybill: notifier.detailOrderSellerData.item!.waybill)));
                                  },
                                  isBorderRadius: true,
                                  isBoxShadow: false,
                                  btnColor: ColorResources.primary,
                                  btnTextColor: ColorResources.white,
                                  btnTxt: "Tracking",
                                ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30.0),

                  Text(
                    "Pembayaran",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Metode Pembayaran",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: ColorResources.black,
                        ),
                      ),

                      Text(
                        notifier.detailOrderSellerData.paymentCode!
                            .toUpperCase(),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15.0),

                  // notifier.detailOrderSellerData.item!.orderStatus == "DELIVERED"
                  // ? CustomButton(
                  //     isBorder: false,
                  //     isBorderRadius: true,
                  //     isBoxShadow: false,
                  //     btnColor: notifier.detailOrderSellerData.isReviewed!
                  //     ? ColorResources.hintColor
                  //     : ColorResources.redOnboarding,
                  //     btnTxt: "Komplain",
                  //     onTap: notifier.detailOrderSellerData.isReviewed!
                  //     ? () {}
                  //     : () async {
                  //       showGeneralDialog(
                  //         context: context,
                  //         barrierLabel: "Barrier",
                  //         barrierDismissible: true,
                  //         barrierColor: Colors.black.withOpacity(0.5),
                  //         transitionDuration: const Duration(milliseconds: 700),
                  //         pageBuilder: (BuildContext context, Animation<double> double, _) {
                  //           return Center(
                  //             child: Material(
                  //               color: ColorResources.transparent,
                  //               child: Container(
                  //                 margin: const EdgeInsets.all(20.0),
                  //                 height: 250.0,
                  //                 decoration: BoxDecoration(
                  //                   color: ColorResources.white,
                  //                   borderRadius: BorderRadius.circular(20.0)
                  //                 ),
                  //                 child: Stack(
                  //                   clipBehavior: Clip.none,
                  //                   children: [

                  //                     Align(
                  //                       alignment: Alignment.center,
                  //                       child: Text("Apa kamu yakin ingin komplain ?",
                  //                         style: robotoRegular.copyWith(
                  //                           fontSize: Dimensions.fontSizeLarge,
                  //                           fontWeight: FontWeight.bold,
                  //                           color: ColorResources.black
                  //                         ),
                  //                       )
                  //                     ),

                  //                     Align(
                  //                       alignment: Alignment.bottomCenter,
                  //                       child: Column(
                  //                         mainAxisSize: MainAxisSize.min,
                  //                         mainAxisAlignment: MainAxisAlignment.end,
                  //                         children: [
                  //                           Container(
                  //                             margin: const EdgeInsets.only(
                  //                               top: 20.0,
                  //                               bottom: 20.0
                  //                             ),
                  //                             child: Row(
                  //                               mainAxisSize: MainAxisSize.max,
                  //                               children: [
                  //                                 const Expanded(child: SizedBox()),
                  //                                 Expanded(
                  //                                   flex: 5,
                  //                                   child: CustomButton(
                  //                                     isBorderRadius: true,
                  //                                     isBoxShadow: false,
                  //                                     fontSize: Dimensions.fontSizeSmall,
                  //                                     isBorder: true,
                  //                                     btnBorderColor: Colors.black,
                  //                                     btnColor: ColorResources.white,
                  //                                     btnTextColor: ColorResources.black,
                  //                                     onTap: () {
                  //                                  Navigator.pop(context);
                  //                                     },
                  //                                     btnTxt: "Batal"
                  //                                   ),
                  //                                 ),
                  //                                 const Expanded(child: SizedBox()),
                  //                                 Expanded(
                  //                                   flex: 5,
                  //                                   child: Consumer<EcommerceProvider>(
                  //                                     builder: (_, notifier, __) {
                  //                                       return CustomButton(
                  //                                         isBorderRadius: true,
                  //                                         isBoxShadow: false,
                  //                                         isLoading: notifier.cancelOrderStatus == CancelOrderStatus.loading
                  //                                         ? true
                  //                                         : false,
                  //                                         fontSize: Dimensions.fontSizeSmall,
                  //                                         btnColor: ColorResources.success,
                  //                                         btnTextColor: ColorResources.white,
                  //                                         onTap: () async {
                  //                                           NS.push(context, const ComplaintScreen());
                  //                                         },
                  //                                         btnTxt: "Ya"
                  //                                       );
                  //                                     },
                  //                                   )
                  //                                 ),
                  //                                 const Expanded(child: SizedBox()),
                  //                               ],
                  //                             ),
                  //                           )
                  //                         ],
                  //                       )
                  //                     )
                  //                   ],
                  //                 ),
                  //               ),
                  //             )
                  //           );
                  //         },
                  //         transitionBuilder: (_, anim, __, child) {
                  //           Tween<Offset> tween;
                  //           if (anim.status == AnimationStatus.reverse) {
                  //             tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
                  //           } else {
                  //             tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
                  //           }
                  //           return SlideTransition(
                  //             position: tween.animate(anim),
                  //             child: FadeTransition(
                  //               opacity: anim,
                  //               child: child,
                  //             ),
                  //           );
                  //         },
                  //       );
                  //     },
                  //   )
                  // : const SizedBox(),
                  const SizedBox(height: 15.0),

                  notifier.detailOrderSellerData.paymentCode == "gopay" ||
                          notifier.detailOrderSellerData.paymentCode ==
                              "shopee" ||
                          notifier.detailOrderSellerData.paymentCode ==
                              "dana" ||
                          notifier.detailOrderSellerData.paymentCode == "ovo"
                      ? notifier.detailOrderSellerData.item!.orderStatus ==
                                    "DELIVERED" ||
                                notifier
                                        .detailOrderSellerData
                                        .item!
                                        .orderStatus ==
                                    "REFUND"
                            ? const SizedBox()
                            : Center(
                                child: CachedNetworkImage(
                                  width: 350.0,
                                  height: 350.0,
                                  imageUrl: notifier
                                      .detailOrderSellerData
                                      .paymentAccess
                                      .toString(),
                                  errorWidget: (context, url, error) {
                                    return Center(
                                      child: Image.network(
                                        'https://dummyimage.com/300x300/000/fff',
                                      ),
                                    );
                                  },
                                  placeholder: (context, url) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  "No VA",
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: ColorResources.black,
                                  ),
                                ),

                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: notifier
                                            .detailOrderSellerData
                                            .paymentAccess
                                            .toString(),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          notifier
                                              .detailOrderSellerData
                                              .paymentAccess
                                              .toString(),
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Icon(Icons.copy, size: 12.0),
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              notifier.detailOrderSellerData.paymentAccess
                                  .toString(),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                  const SizedBox(height: 15.0),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Biaya Kurir",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: ColorResources.black,
                        ),
                      ),

                      Text(
                        formatCurrency(
                          notifier.detailOrderSellerData.totalCost!,
                        ),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15.0),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Admin",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: ColorResources.black,
                        ),
                      ),

                      Text(
                        notifier.detailOrderSellerData.paymentCode == "gopay" ||
                                notifier.detailOrderSellerData.paymentCode ==
                                    "shopee" ||
                                notifier.detailOrderSellerData.paymentCode ==
                                    "dana" ||
                                notifier.detailOrderSellerData.paymentCode ==
                                    "ovo"
                            ? formatCurrency(1500)
                            : formatCurrency(6500),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15.0),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Harga",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: ColorResources.black,
                        ),
                      ),

                      Text(
                        formatCurrency(
                          notifier.detailOrderSellerData.totalPrice!,
                        ),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15.0),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Total Biaya",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.black,
                        ),
                      ),

                      Text(
                        formatCurrency(
                          notifier.detailOrderSellerData.totalPrice! +
                              notifier.detailOrderSellerData.totalCost! +
                              (notifier.detailOrderSellerData.paymentCode ==
                                          "gopay" ||
                                      notifier
                                              .detailOrderSellerData
                                              .paymentCode ==
                                          "shopee" ||
                                      notifier
                                              .detailOrderSellerData
                                              .paymentCode ==
                                          "dana" ||
                                      notifier
                                              .detailOrderSellerData
                                              .paymentCode ==
                                          "ovo"
                                  ? 1500
                                  : 6500),
                        ),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15.0),

                  notifier.detailOrderSellerData.item!.orderStatus == "PAID"
                      ? CustomButton(
                          onTap: () async {
                            showGeneralDialog(
                              context: context,
                              barrierLabel: "Barrier",
                              barrierDismissible: true,
                              barrierColor: Colors.black.withOpacity(0.5),
                              transitionDuration: const Duration(
                                milliseconds: 700,
                              ),
                              pageBuilder: (BuildContext context, Animation<double> double, _) {
                                return Center(
                                  child: Material(
                                    color: ColorResources.transparent,
                                    child: Container(
                                      margin: const EdgeInsets.all(20.0),
                                      height: 250.0,
                                      decoration: BoxDecoration(
                                        color: ColorResources.white,
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Apakah kamu yakin ingin konfirmasi pesanan ?",
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                fontWeight: FontWeight.bold,
                                                color: ColorResources.black,
                                              ),
                                            ),
                                          ),

                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 20.0,
                                                    bottom: 20.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      const Expanded(
                                                        child: SizedBox(),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: CustomButton(
                                                          isBorderRadius: true,
                                                          isBoxShadow: false,
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          isBorder: true,
                                                          btnBorderColor:
                                                              Colors.black,
                                                          btnColor:
                                                              ColorResources
                                                                  .white,
                                                          btnTextColor:
                                                              ColorResources
                                                                  .black,
                                                          onTap: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          btnTxt: "Batal",
                                                        ),
                                                      ),
                                                      const Expanded(
                                                        child: SizedBox(),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Consumer<EcommerceProvider>(
                                                          builder: (_, notifier, __) {
                                                            return CustomButton(
                                                              isBorderRadius:
                                                                  true,
                                                              isBoxShadow:
                                                                  false,
                                                              isLoading:
                                                                  notifier.confirmOrderStatus ==
                                                                      ConfirmOrderStatus
                                                                          .loading
                                                                  ? true
                                                                  : false,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              btnColor:
                                                                  ColorResources
                                                                      .success,
                                                              btnTextColor:
                                                                  ColorResources
                                                                      .white,
                                                              onTap: () async {
                                                                await ep.confirmOrder(
                                                                  transactionId:
                                                                      notifier
                                                                          .detailOrderSellerData
                                                                          .transactionId!,
                                                                  storeId: notifier
                                                                      .detailOrderSellerData
                                                                      .item!
                                                                      .store
                                                                      .id,
                                                                );
                                                              },
                                                              btnTxt: "Ya",
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const Expanded(
                                                        child: SizedBox(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              transitionBuilder: (_, anim, __, child) {
                                Tween<Offset> tween;
                                if (anim.status == AnimationStatus.reverse) {
                                  tween = Tween(
                                    begin: const Offset(-1, 0),
                                    end: Offset.zero,
                                  );
                                } else {
                                  tween = Tween(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  );
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
                          },
                          isBorder: false,
                          isBoxShadow: false,
                          isBorderRadius: true,
                          btnColor: ColorResources.success,
                          btnTxt: "Konfirmasi pesanan",
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String orderStatus(String val) {
    String orderStatus = "";

    switch (val) {
      case "PAID":
        orderStatus = "Dibayar";
        break;
      case "PACKING":
        orderStatus = "Dikemas";
        break;
      case "ON PROCESS":
        orderStatus = "Dikirim";
        break;
      case "DELIVERED":
        orderStatus = "Selesai";
        break;
      default:
    }

    return orderStatus;
  }
}
