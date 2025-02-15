import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/capitalize.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/ppob/data/models/payment_model.dart';
import 'package:rakhsa/features/ppob/presentation/pages/success_create_transaction.dart';

import 'package:rakhsa/features/ppob/presentation/providers/pay_ppob_notifier.dart';
import 'package:rakhsa/features/ppob/presentation/providers/payment_channel_listener.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class PaymentPage extends StatefulWidget {
  static const route = '/payment';
  
  final String customerName;
  final String customerNo;
  final String productId;
  final String productName;
  final int productPrice;
  final String topupby;
  final String ref2;
  final String type;

  const PaymentPage({
    required this.customerName,
    required this.customerNo,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.topupby,
    required this.ref2,
    required this.type,
    super.key
  });

  @override
  State<PaymentPage> createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {

  Future<void> getData() async {
    if(!mounted) return;
      context.read<PaymentChannelProvider>().reset();

    if(!mounted) return;
      context.read<PaymentChannelProvider>().fetch();

    if(!mounted) return;
      context.read<ProfileNotifier>().getProfile();
  }

  @override 
  void initState() {
    super.initState();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                centerTitle: true,
                leading: CupertinoNavigationBarBackButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text("Pembayaran",
                  style: robotoRegular.copyWith(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ];
          }, 
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)
              ),
            ),
            child: RefreshIndicator.adaptive(
              onRefresh: () {
                return getData();
              },
              child: Consumer<PaymentChannelProvider>(
                builder: (BuildContext context, PaymentChannelProvider paymentChannelNotifier, Widget? child) {
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
        
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
        
                            Container(
                              margin: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                top: 10.0,
                                bottom: 10.0,
                              ),
                              child: Text("Pilihan Pembayaran",
                                style: robotoRegular.copyWith(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
        
                            Container(
                              margin: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [

                                  const Icon(
                                    Icons.payment,
                                    size: 20.0,
                                  ),
                                  
                                  Bouncing(
                                    onPress: () async {
                                      showModalBottomSheet(
                                        context: context, 
                                        builder: (BuildContext context) {
                                          return Consumer<PaymentChannelProvider>(
                                            builder: (BuildContext context, PaymentChannelProvider paymentChannelProvider, Widget? child) {
                                              if(paymentChannelNotifier.state == ProviderState.loading) {
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 16.0,
                                                    height: 16.0,
                                                    child: SpinKitChasingDots(
                                                      color: primaryColor,
                                                    ),
                                                  )
                                                );
                                              }
                                              if(paymentChannelNotifier.state == ProviderState.error) {
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 16.0,
                                                    height: 16.0,
                                                    child: SpinKitChasingDots(
                                                      color: primaryColor,
                                                    ),
                                                  )
                                                );
                                              }
                                              return Container(
                                                margin: const EdgeInsets.all(16.0),
                                                width: double.infinity,
                                                child: ListView.separated(
                                                  separatorBuilder: (BuildContext context, int i) {
                                                    return const Divider(
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  itemCount: paymentChannelNotifier.entity.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    PaymentData paymentData = paymentChannelNotifier.entity[i];

                                                    return InkWell(
                                                      onTap: () {
                                                        paymentChannelNotifier.selectPaymentChannel(paymentData: paymentData);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets.only(
                                                          top: 6.0,
                                                          bottom: 6.0,
                                                          left: 8.0, 
                                                          right: 8.0,
                                                        ),
                                                        padding: const EdgeInsets.only(
                                                          top: 6.0,
                                                          bottom: 6.0,
                                                          left: 6.0,
                                                          right: 6.0
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          mainAxisSize: MainAxisSize.max,
                                                          children: [
                                                            Text(paymentData.name,
                                                              style: robotoRegular.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                                color: ColorResources.black
                                                              ),
                                                            ),
                                                      
                                                            Icon(paymentChannelNotifier.paymentName == paymentData.name
                                                              ? Icons.check
                                                              : Icons.chevron_right,
                                                              color: paymentChannelNotifier.paymentName == paymentData.name 
                                                              ?ColorResources.green  
                                                              :ColorResources.black,
                                                              size: 17.0,
                                                            )
                                                          ],
                                                        ) 
                                                      ),
                                                    );
                                                  },
                                                )
                                              );
                                            }
                                          );
                                        },
                                      );
                                    },  
                                    child: Text(paymentChannelNotifier.paymentName.isEmpty 
                                    ? "Pilih Metode Pembayaran" 
                                    : paymentChannelNotifier.paymentName,
                                      style: robotoRegular.copyWith(
                                        color: primaryColor,
                                        fontSize: Dimensions.fontSizeSmall,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                          
                                ],
                              ),
                            ),
        
                            const SizedBox(height: 10.0),
        
                            const Divider(
                              color: Colors.grey,
                              height: 5.0,
                              thickness: 1.0,
                            ),
        
                            const SizedBox(height: 10.0),
        
                            Container(
                              margin: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
        
                                  Text("Billing Information",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      fontWeight: FontWeight.bold,
                                      color: ColorResources.black
                                    ),
                                  ),
        
                                  const SizedBox(height: 12.0),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("Product",
                                        style: robotoRegular.copyWith(
                                          color: Colors.grey,
                                          fontSize: Dimensions.fontSizeSmall
                                        ),
                                      ),
                                      Text(widget.productName.capitalizeEachWord(),
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: ColorResources.black
                                        ),
                                      )
                                    ],
                                  ),

                                  const SizedBox(height: 5.0),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("Service",
                                        style: robotoRegular.copyWith(
                                          color: Colors.grey,
                                          fontSize: Dimensions.fontSizeSmall
                                        ),
                                      ),
                                      Text(widget.type.capitalizeEachWord(),
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: ColorResources.black
                                        ),
                                      )
                                    ],
                                  ),

                                  const SizedBox(height: 5.0),
        
                                  if(widget.type == "pulsa" || widget.type == "data")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text("Top-up for",
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                            fontSize: Dimensions.fontSizeSmall
                                          ),
                                        ),
                                        context.watch<ProfileNotifier>().state == ProviderState.loading 
                                        ? const Text("...") 
                                        : context.watch<ProfileNotifier>().state == ProviderState.error 
                                        ? const Text("...") 
                                        : Text(context.read<ProfileNotifier>().entity.data?.username ?? "-",
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: ColorResources.black
                                          ),
                                        )
        
                                      ],
                                    ),
        
                                  if(widget.type == "pulsa" || widget.type == "data")
                                    const SizedBox(height: 5.0),
        
                                  if(widget.type == "Token Listrik" && widget.type == "Token Listrik")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text("Top-up for",
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                            fontSize: Dimensions.fontSizeSmall
                                          ),
                                        ),
                                        Text(widget.customerName,
                                          style: robotoRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: Dimensions.fontSizeSmall
                                          ),
                                        )
                                      ],
                                    ),
        
                                  if(widget.type == "pulsa" || widget.type == "data")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text("Phone number",
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                            fontSize: Dimensions.fontSizeSmall
                                          ),
                                        ),
                                        Text(widget.customerNo,
                                          style: robotoRegular.copyWith(
                                            color: ColorResources.black,
                                            fontSize: Dimensions.fontSizeSmall
                                          ),
                                        )
                                      ],
                                    ),
        
                                  const SizedBox(height: 5.0),
        
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("Total Pembayaran",
                                        style: robotoRegular.copyWith(
                                          color: Colors.grey,
                                          fontSize: Dimensions.fontSizeSmall
                                        ),
                                      ),
                                      Text(formatCurrency(widget.productPrice),
                                        style: robotoRegular.copyWith(
                                          color: ColorResources.black,
                                          fontSize: Dimensions.fontSizeSmall
                                        ),
                                      )
                                    ],
                                  ),
        
                                ],
                              ) 
                            )
        
                          ],
                        )
                      )
        
                    ],
                  );
                },
              ) 
            ),
          )
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(20.0),
          child: CustomButton(
            onTap: context.watch<PaymentChannelProvider>().paymentName != "" 
            ? () async {
                PaymentChannelProvider paymentChannelProvider = context.read<PaymentChannelProvider>();
                PayPpobNotifier payPpobProvider = context.read<PayPpobNotifier>();

                if(paymentChannelProvider.paymentName == "") {
                  await ShowSnackbar.snackbarErr("Metode pembayaran belum dipilih");
                  return;
                }

                await payPpobProvider.pay(
                  idpel: widget.customerNo,
                  productId: widget.productId,
                  paymentCode: paymentChannelProvider.paymentCode,
                  paymentChannel: paymentChannelProvider.paymentChannel,
                  type: "PULSA",
                );

                Future.delayed(Duration.zero, () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                    return SuccessCreateTransactioPage(
                      productName: widget.productName,
                      productPrice: widget.productPrice,
                      productType: widget.type,
                      orderId: payPpobProvider.orderId,
                      paymentName: paymentChannelProvider.paymentName,
                      paymentAccess: payPpobProvider.paymentAccess,
                      paymentType: payPpobProvider.paymentType
                    );
                  }), (route) => route.isFirst);
                });
              } 
            : () {},
            isBorder: false,
            isBorderRadius: true,
            isBoxShadow: false,
            isLoading: context.watch<PayPpobNotifier>().state == ProviderState.loading 
            ? true 
            : false,
            sizeBorderRadius: 20.0,
            btnTxt: "Bayar",
            btnColor: context.watch<PaymentChannelProvider>().paymentName != "" 
            ? primaryColor
            :Colors.grey, 
          )
      )
    );
  }

}