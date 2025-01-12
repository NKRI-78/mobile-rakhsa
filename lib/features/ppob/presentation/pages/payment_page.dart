import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/capitalize.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

import 'package:rakhsa/features/ppob/presentation/providers/get_balance_listener.dart';
import 'package:rakhsa/features/ppob/presentation/providers/inquiry_topup_listener.dart';
import 'package:rakhsa/features/ppob/presentation/providers/pay_pln_pra_pln_notifier.dart';
import 'package:rakhsa/features/ppob/presentation/providers/pay_pulsa_and_paket_listener.dart';
import 'package:rakhsa/features/ppob/presentation/providers/payment_channel_listener.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

class PaymentPage extends StatefulWidget {
  static const route = '/payment';
  
  final String customerName;
  final String customerNo;
  final String productCode;
  final int productPrice;
  final String topupby;
  final String ref2;
  final String type;

  const PaymentPage({
    required this.customerName,
    required this.customerNo,
    required this.productCode,
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
      context.read<GetBalanceProvider>().fetch();

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
      body:  NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 20.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      
                          Container(
                            margin: const EdgeInsets.only(
                              top: 35.0,
                              bottom: 35.0,
                              left: 20.0,
                              right: 20.0
                            ),
                            child: Bouncing(
                              onPress: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset('assets/image/icons/ic-appbar-back.png',
                                width: 30.0,
                                height: 30.0,
                              ),
                            ),
                          ),
                      
                        ],
                      ),  
                      
                      Text("Pembayaran",
                        style: robotoRegular.copyWith(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      
                    ],
                  ),
                )
              ),
                  
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
            child: RefreshIndicator(
              onRefresh: () {
                return Future.sync(() {});
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  
                                  if(paymentChannelNotifier.paymentChannel == "")
                                    Text("Metode Pembayaran",
                                      style: robotoRegular.copyWith(
                                        color: Colors.grey,
                                        fontSize: 9.0,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
        
                                  if(widget.type == "data" && paymentChannelNotifier.paymentName != null)
                                    Consumer<GetBalanceProvider>(
                                      builder: (BuildContext context, GetBalanceProvider wallet, Widget? child) {
                                        return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
        
                                          Text(paymentChannelNotifier.paymentName ?? "",
                                            style: robotoRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
        
                                          const SizedBox(width: 10.0),
        
                                          if(wallet.state == ProviderState.loading) 
                                            const Text("..."),
        
                                          if(wallet.state == ProviderState.error)
                                            const Text("..."),
        
                                          if(wallet.state == ProviderState.loaded)
                                            Text(formatCurrency(wallet.balance),
                                              style: robotoRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
        
                                        ],
                                      );
                                    },
                                  ),
        
                                  if(widget.type == "pulsa" && paymentChannelNotifier.paymentName != null)
                                    Consumer<GetBalanceProvider>(
                                      builder: (BuildContext context, GetBalanceProvider wallet, Widget? child) {
                                        return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
        
                                          Text(paymentChannelNotifier.paymentName ?? "",
                                            style: robotoRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
        
                                          const SizedBox(width: 10.0),
        
                                          if(wallet.state == ProviderState.loading) 
                                            const Text("..."),
        
                                          if(wallet.state == ProviderState.error)
                                            const Text("..."),
        
                                          if(wallet.state == ProviderState.loaded)
                                            Text(formatCurrency(wallet.balance),
                                              style: robotoRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
        
                                        ],
                                      );
                                    },
                                  ),
        
                                  if(widget.type != "data" && widget.type != "pulsa")
                                    Text(paymentChannelNotifier.paymentName ?? "",
                                      style: robotoRegular.copyWith(
                                        color: Colors.black,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                            
                                  Bouncing(
                                    onPress: () async {
                                      
                                    },
                                    child: Text("Pilih Metode Pembayaran",
                                      style: robotoRegular.copyWith(
                                        color: const Color(0xff0055A6),
                                        fontSize: 12.0,
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
        
                                  const Text("Billing Information"),
        
                                  const SizedBox(height: 12.0),
                                  
                                  if(widget.type != "iuran")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
        
                                        Text("Service",
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                            fontSize: 13.0
                                          ),
                                        ),
        
                                        Text(widget.type.capitalize())
        
                                      ],
                                    ),
        
        
                                  if(widget.type == "iuran")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
        
                                        Text("Service",
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                            fontSize: 13.0
                                          ),
                                        ),
        
                                        Text(widget.productCode)
        
                                      ],
                                    ),
        
                                  if(widget.type == "pulsa" || widget.type == "data")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
        
                                        Text("Top-up for",
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                            fontSize: 13.0
                                          ),
                                        ),
                                      
                                        context.watch<ProfileNotifier>().state == ProviderState.loading 
                                        ? const Text("...") 
                                        : context.watch<ProfileNotifier>().state == ProviderState.error 
                                        ? const Text("...") 
                                        : Text(context.read<ProfileNotifier>().entity.data?.username ?? "-")
        
                                      ],
                                    ),
        
                                  if(widget.type == "iuran")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
        
                                        Text("Customer name",
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                            fontSize: 13.0
                                          ),
                                        ),
                                      
                                        context.watch<ProfileNotifier>().state == ProviderState.loading 
                                        ? const Text("...") 
                                        : context.watch<ProfileNotifier>().state == ProviderState.error 
                                        ? const Text("...") 
                                        : Text(context.read<ProfileNotifier>().entity.data?.username ?? "-")
        
                                      ],
                                    ),
        
                                  if(widget.type == "iuran")
                                    const SizedBox(height: 5.0),
        
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
                                            fontSize: 13.0
                                          ),
                                        ),
                                      
                                        Text(widget.customerName)
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
                                            fontSize: 13.0
                                          ),
                                        ),
        
                                        Text(widget.customerNo)
        
                                      ],
                                    ),
                                  
                                  const SizedBox(height: 5.0),
        
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
        
                                      Text("Metode Pembayaran",
                                        style: robotoRegular.copyWith(
                                          color: Colors.grey,
                                          fontSize: 13.0
                                        ),
                                      ),
        
                                      SizedBox(
                                        width: 180.0,
                                        child: Text(paymentChannelNotifier.paymentName ?? "-",
                                        textAlign: TextAlign.end,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        )
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
                                          fontSize: 13.0
                                        ),
                                      ),
        
                                      Text(formatCurrency(widget.productPrice),
                                        style: robotoRegular,
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
          child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.watch<PaymentChannelProvider>().paymentName != null 
            ? const Color(0xFFC82927) 
            : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            )
          ),
          onPressed: () async {

            PaymentChannelProvider paymentChannelProvider = context.read<PaymentChannelProvider>();
            PayPulsaAndPaketDataProvider payPulsaAndPaketDataProvider = context.read<PayPulsaAndPaketDataProvider>();
            PayPlnPraProvider payPlnPraProvider = context.read<PayPlnPraProvider>();
            InquiryTopupProvider inquiryTopupProvider = context.read<InquiryTopupProvider>();

            if(paymentChannelProvider.paymentName == "") {
              await ShowSnackbar.snackbarErr("Metode pembayaran belum dipilih");
              return;
            }

            switch (widget.type) {
              case "pulsa":
                await payPulsaAndPaketDataProvider.pay(
                  productCode: widget.productCode,
                  phone: widget.customerNo
                );

                Future.delayed(Duration.zero, () async {
                  if(payPulsaAndPaketDataProvider.message != "") {
                    await ShowSnackbar.snackbarErr(
                      payPulsaAndPaketDataProvider.message
                    );
                  } else {
                    await ShowSnackbar.snackbarOk(
                      "Pembayaran berhasil"
                    );
                  }
                });
              break;
              case "data":
                await payPulsaAndPaketDataProvider.pay(
                  productCode: widget.productCode,
                  phone: widget.customerNo
                );

                Future.delayed(Duration.zero, () async {
                  if(payPulsaAndPaketDataProvider.message != "") {
                    await ShowSnackbar.snackbarErr(payPulsaAndPaketDataProvider.message);
                  } else {
                    await ShowSnackbar.snackbarOk("Pembayaran berhasil");
                  }
                });
              break;
              case "Token Listrik":
                await payPlnPraProvider.pay(
                  idpel: widget.customerNo, 
                  ref2: widget.ref2, 
                  nominal: widget.productPrice.toString()
                );

                Future.delayed(Duration.zero, () async {
                  if(payPlnPraProvider.message != "") {
                    await ShowSnackbar.snackbarErr(
                      payPlnPraProvider.message
                    );
                  } else {
                    await ShowSnackbar.snackbarOk("Pembayaran berhasil");
                  }
                });
              break;  
              case "topup":

               if(paymentChannelProvider.paymentChannel == "" || paymentChannelProvider.paymentChannel == null) {
                  await ShowSnackbar.snackbarErr("Metode pembayaran belum dipilih");
                }

                await inquiryTopupProvider.inquiryTopup(
                  productId: widget.productCode, 
                  productPrice: widget.productPrice,
                  topupby: widget.topupby,
                  channel: paymentChannelProvider.paymentChannel!,
                );

                Future.delayed(Duration.zero, () async {
                  if(inquiryTopupProvider.message != "") {
                    await ShowSnackbar.snackbarErr(inquiryTopupProvider.message);
                  } else {
                    await ShowSnackbar.snackbarOk("Segera melakukan pembayaran, info mengenai pembayaran akan dikirimkan melalui Inbox");
                  }
                });
              break;
              default:
            }

          },
          child: widget.type == "topup" 
          ? (context.watch<InquiryTopupProvider>().state == ProviderState.loading 
            ? const CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              )
            : Text('Bayar',
              style: robotoRegular.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ))
          : widget.type == "Token Listrik" 
          ? (context.watch<PayPlnPraProvider>().state == ProviderState.loading 
            ? const CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              )
            : Text('Bayar',
                style: robotoRegular.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              )
            )
          : (context.watch<PayPulsaAndPaketDataProvider>().state == ProviderState.loading 
          ? const CircularProgressIndicator.adaptive(
             backgroundColor: Colors.white,
            )
          : Text('Bayar',
            style: robotoRegular.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ))
        )
      )
    );
  }

}