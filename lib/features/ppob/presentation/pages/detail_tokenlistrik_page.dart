import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

import 'package:rakhsa/features/ppob/presentation/pages/payment_page.dart';
import 'package:rakhsa/features/ppob/presentation/providers/inquiry_plnpra_listener.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

class PPOBDetailTokenListrikPage extends StatefulWidget {
  static const route = '/ppob/tokenlistrik/detail';

  final String title;
  const PPOBDetailTokenListrikPage({
    required this.title,
    super.key
  });

  @override
  State<PPOBDetailTokenListrikPage> createState() => PPOBDetailTokenListrikPageState();
}

class PPOBDetailTokenListrikPageState extends State<PPOBDetailTokenListrikPage> {

  String productCode = "";
  String productDenom = "";
  String customerName = "";
  String customerNo = "";
  String ref2 = "";

  int productPrice = 0;
  int selectedAmount = -1;

  List<Map<String, dynamic>> denoms = [
    {
      "id": 1,
      "amount": 20000 
    },
    {
      "id": 2,
      "amount": 50000
    },
    {
      "id": 3,
      "amount": 100000
    },
    {
      "id": 4,
      "amount": 200000
    }
  ];

  late TextEditingController getC;

  TextEditingController controller = TextEditingController();

  Timer? debounce;

  void onPhoneChange() {
    setState(() {
                    
    });
  }

  @override 
  void initState() {
    super.initState();

    getC = TextEditingController();
    getC.addListener(onPhoneChange);
  }

  @override 
  void dispose() {
    debounce?.cancel();
    getC.removeListener(onPhoneChange);
    getC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
          
          ];
        },
        body: Consumer<InquiryPlnPraProvider>(
          builder: (BuildContext context, InquiryPlnPraProvider notifier, Widget? child) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [

                SliverToBoxAdapter(
                  child: Container(
                    height: 80.0,
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      top: 10.0, 
                      left: 5.0, 
                      right: 5.0, 
                      bottom: 5.0
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 3.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Expanded(
                            flex: 1,
                            child: SizedBox()
                          ),
                          Expanded(
                            flex: 25,
                            child: Container(
                              height: 50.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0)
                              ),
                              child: TextFormField(
                                controller: getC,
                                style: robotoRegular.copyWith(
                                  fontSize: 12.0
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Customer ID",
                                  hintStyle: robotoRegular.copyWith(
                                    fontSize: 12.0
                                  ),
                                  fillColor: Colors.white,
                                  border: InputBorder.none,
                                  focusedBorder: const UnderlineInputBorder(),
                                  enabledBorder: const UnderlineInputBorder(),
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16.0)
                                ),
                                onChanged: (val) {
                                  if (debounce?.isActive ?? false) debounce?.cancel();
                                  debounce = Timer(const Duration(milliseconds: 500), () {
                                    context.read<InquiryPlnPraProvider>().fetch(idpel: getC.text);
                                  });
                                },
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
                if(notifier.state == ProviderState.loading) 
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),

                if(notifier.state == ProviderState.error) 
                  SliverFillRemaining(
                    child: Center(
                      child: Text(notifier.message,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                if(notifier.state == ProviderState.loaded) 
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 20.0,
                        left: 15.0,
                        right: 15.0
                      ),
                      child: Bouncing(
                        onPress: () {
                          setState(() {
                            if(productCode == "") {
                              customerName = notifier.entity.namaPelanggan!;
                              customerNo = notifier.entity.idpel2!;
                              productCode = notifier.entity.kodeProduk!;
                              ref2 = notifier.entity.ref2!;
                            } else {
                              customerName = "";
                              customerNo = "";
                              productCode = "";
                              ref2 = "";
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              
                              Align(
                                alignment:Alignment.center,
                                child: Container(
                                  height: 80.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: productCode == notifier.entity.kodeProduk 
                                    ? const Color(0xff3CAEED)
                                    : const Color(0xffF1F1F1),
                                    boxShadow: kElevationToShadow[1],
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(notifier.entity.idpel2!,
                                        style: robotoRegular.copyWith(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: productCode == notifier.entity.kodeProduk 
                                          ? Colors.white 
                                          : Colors.black
                                        ),
                                      ),
                                      Text(notifier.entity.namaPelanggan!,
                                        style: robotoRegular.copyWith(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w600,
                                          color: productCode == notifier.entity.kodeProduk 
                                          ? Colors.white 
                                          : Colors.black
                                        ),
                                      ),
                                    ],
                                  ) 
                                ),
                              ),
                      
                            ],
                          ),
                        ),
                      )
                    ),
                  ),

                  if(productCode.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only( 
                          top: 20.0,
                          bottom: 20.0,
                          left: 15.0, 
                          right: 15.0
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8.0),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200.0,
                            childAspectRatio: 4.0 / 3.0,
                            crossAxisSpacing: 50.0,
                            mainAxisSpacing: 50.0,
                          ),
                          itemCount: denoms.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Bouncing(
                              onPress: () {
                                setState(() {
                                  if(selectedAmount != i) {
                                    selectedAmount = i;
                                    productPrice = denoms[i]["amount"];
                                  } else {
                                    selectedAmount = -1;
                                    productPrice = denoms[i]["amount"];
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    
                                    Align(
                                      alignment:Alignment.bottomCenter,
                                      child: Container(
                                        height: 80.0,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: selectedAmount == i
                                          ? const Color(0xff3CAEED)
                                          : const Color(0xffF1F1F1),
                                          boxShadow: kElevationToShadow[1],
                                          borderRadius: BorderRadius.circular(25.0),
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 20.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(formatCurrency(denoms[i]["amount"]),
                                                style: robotoRegular.copyWith(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: selectedAmount == i 
                                                  ? Colors.white 
                                                  : Colors.black
                                                ),
                                              ),
                                            ],
                                          ),
                                        ) 
                                      ),
                                    ),
                            
                                    Positioned(
                                      top: 0.0,
                                      left: 0.0,
                                      right: 0.0,
                                      child: Image.asset('assets/image/icons/ic-coin.png',
                                        width: 50.0,
                                        height: 50.0,
                                      )
                                    ),
                            
                                  ],
                                ),
                              ),
                            );
                          
                          }
                        ),
                      ),
                    ),
                
              ],
            );

          },
        ) 
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 20.0
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: productCode.isEmpty 
            ?Colors.grey
            : const Color(0xFFC82927),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)
            )
          ),
          onPressed: () {
            if(productCode.isEmpty) {
              ShowSnackbar.snackbarErr("Anda belum memilih Akun Pelanggan");
              return;
            }
            if(getC.text.isEmpty) {
              ShowSnackbar.snackbarErr("Anda belum mengisi Nomor ID Pelanggan");
              return;
            }
            if(selectedAmount == -1) {
              ShowSnackbar.snackbarErr("Anda belum memilih Denom");
              return; 
            }
            Navigator.pushNamed(
              context, PaymentPage.route, 
              arguments: {
                "customer_name": customerName,
                "customer_no": customerNo,
                "product_code": productCode, 
                "product_price": productPrice,
                "topupby": "-",
                "ref2": ref2,
                "type": "Token Listrik"
              }
            );
          }, 
          child: const Text("Selanjutnya",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          )
        )
      ),
    );
  }
  
}