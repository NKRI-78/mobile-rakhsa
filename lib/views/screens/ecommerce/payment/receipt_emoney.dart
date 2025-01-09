import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:rakhsa/data/models/ecommerce/payment/response_emoney.dart';

import 'package:rakhsa/services/navigation.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/common/utils/currency.dart';

import 'package:rakhsa/views/basewidgets/button/custom.dart';

import 'package:rakhsa/views/screens/home/home.dart';

class PaymentReceiptEmoney extends StatefulWidget {
  final int amount;
  final int cost;
  final String type;
  final ResponseMidtransEmoneyData responseMidtransEmoneyData;

  const PaymentReceiptEmoney({super.key, 
    required this.amount,
    required this.cost,
    required this.type,
    required this.responseMidtransEmoneyData
  });

  @override
  State<PaymentReceiptEmoney> createState() => PaymentReceiptEmoneyState();
}

class PaymentReceiptEmoneyState extends State<PaymentReceiptEmoney> {

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        NS.push(context, const DashboardScreen());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Info Pembayaran',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: ColorResources.black
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text('Order ID : ${widget.responseMidtransEmoneyData.data.orderId}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault
              ),
            ),
            Text('Jenis Pembayaran : ${widget.type.toUpperCase()}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault
              ),
            ),
            Text('Jumlah Pembelian : ${CurrencyHelper.formatCurrency(widget.amount)}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault
              ),
            ),
            widget.cost == 0 
            ? const SizedBox() 
            : Text('Biaya Kurir : ${CurrencyHelper.formatCurrency(widget.cost)}',
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault
                ),
              ),
            Text('Admin : ${CurrencyHelper.formatCurrency(widget.responseMidtransEmoneyData.data.channel.fee)}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault
              ),
            ),
            Text('Total Pembayaran : ${CurrencyHelper.formatCurrency(widget.responseMidtransEmoneyData.data.totalAmount)}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault
              ),
            ),
            
            const SizedBox(height: 20.0),
  
            Center(
              child: CachedNetworkImage(
                imageUrl: widget.responseMidtransEmoneyData.data.data.actions[0].url,
                errorWidget: (context, url, error) {
                  return Center(
                    child: Image.network('https://dummyimage.com/300x300/000/fff')
                  );
                },
                placeholder: (context, url) {
                  return const Center(
                    child: CircularProgressIndicator()
                  );
                },
              )
            ),
  
            const SizedBox(height: 25.0),
  
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
  
                Expanded(
                  flex: 4,
                  child: CustomButton(
                    onTap: () {
                      NS.pushReplacement(context, const DashboardScreen());
                    },
                    isBorderRadius: true,
                    isBoxShadow: false,
                    btnColor: ColorResources.primary,
                    btnTxt: "Halaman utama",
                  )
                ),
  
                const Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
  
                Expanded(
                  flex: 4,
                  child: CustomButton(
                    onTap: () async {
                      await launchUrl(Uri.parse(widget.responseMidtransEmoneyData.data.data.actions[1].url));
                    },
                    isBorderRadius: true,
                    isBoxShadow: false,
                    btnColor: const Color(0xFF00AA13),
                    btnTxt: "Bayar via aplikasi",
                  )
                ),
  
              ],
            ),
            
          ],
        ),
      )),
    );
  }
}
