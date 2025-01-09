import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:rakhsa/data/models/ecommerce/payment/response_va.dart';

import 'package:rakhsa/services/navigation.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/currency.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/views/basewidgets/button/custom.dart';

import 'package:rakhsa/views/screens/home/home.dart';

class PaymentReceiptVaScreen extends StatefulWidget {
  final int amount;
  final int cost;
  final ResponseMidtransVaData responseMidtransVaData;

  const PaymentReceiptVaScreen({
    super.key, 
    required this.amount,
    required this.cost,
    required this.responseMidtransVaData
  });
  
  @override
  State<PaymentReceiptVaScreen> createState() => PaymentReceiptVaScreenState();
}

class PaymentReceiptVaScreenState extends State<PaymentReceiptVaScreen> {

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
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              buildDataRow('Order ID', widget.responseMidtransVaData.data.orderId),
              buildDataRow('Transaksi Status', widget.responseMidtransVaData.data.transactionStatus.toString().toUpperCase()),
              buildDataRow('Transaksi ID', widget.responseMidtransVaData.data.transactionId),
              buildDataRow('Tgl Kadaluarsa', DateFormat('yyyy-MM-dd HH:mm').format(widget.responseMidtransVaData.data.expire)),
              const Divider(),
              const SizedBox(height: 5.0),
              buildDataRow('Bank', widget.responseMidtransVaData.data.data.bank.toString().toUpperCase()),
              buildDataRow('Nomor VA', widget.responseMidtransVaData.data.data.vaNumber.toString()),
              buildDataRow('Jenis Pembayaran', widget.responseMidtransVaData.data.channel.paymentType),
              buildDataRow('Jumlah Pembelian', CurrencyHelper.formatCurrency(widget.amount)),
              widget.cost == 0 
              ? const SizedBox() 
              : buildDataRow('Biayar Kurir', CurrencyHelper.formatCurrency(widget.cost)),
              buildDataRow('Admin', CurrencyHelper.formatCurrency(widget.responseMidtransVaData.data.channel.fee)),
              buildDataRow('Total Pembayaran', CurrencyHelper.formatCurrency(widget.responseMidtransVaData.data.totalAmount)),
              const Divider(),
              const SizedBox(height: 5.0),
              buildDataRow('Nama', widget.responseMidtransVaData.data.channel.name),
              buildDataRow('Platform', widget.responseMidtransVaData.data.channel.platform),
              const SizedBox(height: 15.0),
              CustomButton(
                onTap: () {
                  NS.pushReplacement(context, const DashboardScreen());
                },
                isBorderRadius: true,
                isBoxShadow: false,
                btnColor: ColorResources.primary,
                btnTxt: "Halaman utama",
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold
                ),
              ),
              label == "Nomor VA" || label == "Transaksi ID" || label == "Order ID"
              ? InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(value,
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
              : const SizedBox()
            ],
          ),
          Flexible(
            child: Text(value,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall
              ),
            ),
          ),
        ],
      ),
    );
  }
}
