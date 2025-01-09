import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:date_count_down/date_count_down.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/common/helpers/ddmmyyyy.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';

import 'package:rakhsa/views/screens/ecommerce/order/seller/detail.dart';

class ListOrderSellerScreen extends StatefulWidget {
  const ListOrderSellerScreen({super.key});

  @override
  State<ListOrderSellerScreen> createState() => ListOrderSellerScreenState();
}

class ListOrderSellerScreenState extends State<ListOrderSellerScreen> with SingleTickerProviderStateMixin {

  late TabController tabC;
  late EcommerceProvider ep;

  Future<void> getData() async {
    if(!mounted) return;  
      await ep.listOrderSeller(orderStatus: "PAID");

    if(!mounted) return;
      await ep.getBadgeOrderDetail(orderStatus: "PAID");

    if(!mounted) return;
      await ep.getBadgeOrderDetail(orderStatus: "PACKING");
      
    if(!mounted) return;
      await ep.getBadgeOrderDetail(orderStatus: "ON PROCESS");
  }
  
  @override 
  void initState() {
    super.initState();

    tabC = TabController(length: 4, vsync: this);

    tabC.addListener(() {
      if(tabC.indexIsChanging) {
        if(tabC.index == 0) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            await ep.listOrderSeller(orderStatus: "PAID");
          });
        }
        if(tabC.index == 1) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            await ep.listOrderSeller(orderStatus: "PACKING");
          });
        }
        if(tabC.index == 2) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            await ep.listOrderSeller(orderStatus: "ON PROCESS");
           });
        }
        if(tabC.index == 3) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            await ep.listOrderSeller(orderStatus: "DELIVERED");
          });
        }
      }
    });
    
    ep = context.read<EcommerceProvider>();

    Future.delayed(Duration.zero, () => getData());
  }

  @override 
  void dispose() {
    tabC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Daftar Pesanan",
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: ColorResources.black
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
       Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorColor: const Color(0xFFC82927),
          controller: tabC,
          labelStyle: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: ColorResources.black
          ),
          tabs: [
            context.watch<EcommerceProvider>().badgeOrderDetailStatus == BadgeOrderDetailStatus.loading 
            ? const Tab(text: 'Dibayar')
            : ep.badgePaid == 0
            ? const Tab(text: 'Dibayar') 
            : Badge(
              label: Text(ep.badgePaid.toString()),
              child: const Tab(text: 'Dibayar')
            ),
            context.watch<EcommerceProvider>().badgeOrderDetailStatus == BadgeOrderDetailStatus.loading 
            ? const Tab(text: 'Dikemas')
            : ep.badgePacking == 0
            ? const Tab(text: 'Dikemas') 
            : Badge(
              label: Text(ep.badgePacking.toString()),
              child: const Tab(text: 'Dikemas')
            ),
            context.watch<EcommerceProvider>().badgeOrderDetailStatus == BadgeOrderDetailStatus.loading 
            ? const Tab(text: 'Dikirim')
            : ep.badgeDelivery == 0
            ? const Tab(text: 'Dikirim') 
            : Badge(
              label: Text(ep.badgeDelivery.toString()),
              child: const Tab(text: 'Dikirim')
            ),
            const Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabC,
        children: [
          paymentContent('PAID'),
          paymentContent('PACKING'),
          paymentContent('ON PROCESS'),
          paymentContent('DELIVERED'),
        ],
      ),
    );
  }

  Widget paymentContent(String orderStatusParam) {
    return Consumer<EcommerceProvider>(
      builder: (_, notifier, __) {
        if(notifier.listOrderSellerStatus == ListOrderSellerStatus.loading) {
          return const Center(
            child: SizedBox(
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator.adaptive()
            )
          );
        }
        if(notifier.listOrderSellerStatus == ListOrderSellerStatus.empty) {
          return Center(
            child: Text('Belum ada transaksi',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault
              ),
            )
          );
        }
        if(notifier.listOrderSellerStatus == ListOrderSellerStatus.error) {
          return Center(
            child: Text("Hmm... Mohon tunggu yaa",
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault
              ),
            )
          );
        }
        return RefreshIndicator.adaptive(
          onRefresh: () {
            return Future.sync(() {
              ep.listOrderSeller(orderStatus: orderStatusParam);
              ep.getBadgeOrderDetail(orderStatus: orderStatusParam);
            });
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20.0,
              left: 16.0,
              right: 16.0
            ),
            itemCount: notifier.orderSellers.length,
            itemBuilder: (BuildContext context, int i) {
              return Container(
                margin: const EdgeInsets.only(
                  top: 5.0,
                  bottom: 5.0
                ),
                child: Card(
                  elevation: 0.30,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailOrderSellerScreen(
                        storeId: notifier.orderSellers[i].store.id,
                        transactionId: notifier.orderSellers[i].transactionId
                      )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [

                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    
                                    Text(notifier.orderSellers[i].invoice,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault
                                      ),
                                    ),

                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: notifier.orderSellers[i].waybill));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(notifier.orderSellers[i].waybill,
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault
                                            ),
                                          )),
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Icon(
                                          Icons.copy,
                                          size: 12.0,
                                        ),
                                      ),
                                    ) 

                                  ],
                                ),
                                
                                notifier.orderSellers[i].orderStatus == "WAITING_PAYMENT"
                                ? Container(
                                    padding: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      color: ColorResources.countdown,
                                      borderRadius: BorderRadius.circular(10.0)
                                    ),
                                    child: CountDownText(
                                      due: DateTime.parse(notifier.orderSellers[i].expire),
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
                                        fontSize: Dimensions.fontSizeSmall
                                      ),
                                    ),
                                  )  
                                : const SizedBox()
                            
                              ],
                            ),
                          ),
                                        
                          const SizedBox(height: 15.0),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                             
                              Text(formatCurrency(notifier.orderSellers[i].totalPrice),
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.bold,
                                  color: ColorResources.primary
                                ),
                              )

                            ],
                          ),
                                        
                          const SizedBox(height: 10.0),
                                        
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                        
                              Text(formatDateDDMMYYYY(notifier.orderSellers[i].createdAt),
                                style: robotoRegular.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: ColorResources.black,
                                ),
                              ),
                                        
                              Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: ColorResources.primary,
                                  borderRadius: BorderRadius.circular(8.0)
                                ),
                                child: Text(orderStatus(notifier.orderSellers[i].orderStatus),
                                  style: robotoRegular.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: ColorResources.white,
                                  ),
                                )
                              )
                                        
                            ],
                          )
                      
                        ],
                      ),
                    ),
                  )
                )
              );
            },
          ),
        );
      },
    );
  }

  String orderStatus(String val) {
    String orderStatus = "";

    switch (val) {
      case "REFUND":
        orderStatus = "Batal"; 
      break;
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