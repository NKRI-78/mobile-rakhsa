import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/ppob/presentation/pages/payment.dart';
import 'package:rakhsa/features/ppob/presentation/providers/get_denom_topup_listener.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

class DenomTopupPage extends StatefulWidget {
  static const route = '/denom/topup';

  const DenomTopupPage({
    super.key
  });

  @override
  State<DenomTopupPage> createState() => DenomTopupPageState();
}

class DenomTopupPageState extends State<DenomTopupPage> {

  TextEditingController controller = TextEditingController();

  Timer? debounce;
  
  String typeTopup = "without";
  String productCode = "";
  int productPrice = 0;
  int selected = -1;

  Future<void> getData() async {
    if(!mounted) return;
      context.read<GetDenomTopupProvider>().fetch();
  }

  @override 
  void initState() {
    super.initState();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    debounce?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [];
        },
        body: Consumer<GetDenomTopupProvider>(
          builder: (_, notifier, __) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
              
                if(notifier.state == ProviderState.loading) 
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),

                if(notifier.state == ProviderState.error) 
                  SliverFillRemaining(
                    child: Center(
                      child: Text(notifier.message),
                    ),
                  ),

                if(notifier.state == ProviderState.empty) 
                  SliverFillRemaining(
                    child: Center(
                      child: Text(notifier.message),
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
                        itemCount: notifier.entity.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Bouncing(
                            onPress: () {
                              setState(() {
                                if(selected != i) {
                                  controller.text = "";
                                  typeTopup = "without";
                                  selected = i;
                                  productCode = notifier.entity[i].id;
                                  productPrice = notifier.entity[i].denom;
                                } else {
                                  controller.text = "";
                                  typeTopup = "without";
                                  selected = -1;
                                  productCode = "";
                                  productPrice = 0;
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
                                        color: selected == i
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
                                            Text(formatCurrency(notifier.entity[i].denom).toString(),
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeDefault,
                                                fontWeight: FontWeight.bold,
                                                color: selected == i 
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

                  SliverToBoxAdapter(
                    child: Container(
                    margin: const EdgeInsets.only( 
                      bottom: 20.0,
                      left: 15.0, 
                      right: 15.0
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        TextFormField(
                          controller: controller,
                          style: robotoRegular.copyWith(
                            fontSize: 12.0
                          ),
                          inputFormatters: [
                            // CurrencyTextInputFormatter(
                            //   locale: 'id_ID',
                            //   decimalDigits: 0,
                            //   symbol: '',
                            // ),
                          ],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '( Min Rp 10.000 )',
                            prefixText: 'Rp ',
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(),
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.all(16.0)
                          ),
                          onChanged: (text) async {
                            String formattedValue = text.replaceAll(RegExp(r'[^\d]'), '');
                            
                            setState(() {
                              productCode = "4eea972e-daee-48b5-a29d-e1532b3fad21";
                              typeTopup = "with";
                            });

                            if (debounce?.isActive ?? false) debounce?.cancel();
                              debounce = Timer(const Duration(seconds: 2), () {
                              if(int.parse(formattedValue) < 10000) {
                                setState(() {
                                  controller = TextEditingController(text: "10.000");
                                  controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                                });
                              } else {
                                setState(() {
                                  productPrice = int.parse(formattedValue);
                                });
                              }
                            });

                            productPrice = int.parse(formattedValue);
                          },
                        ),

                      ],
                    )
                  )
                )
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
              ShowSnackbar.snackbarErr("Anda belum memilih denom");
              return;
            }

            if(productPrice < 10000) {
              ShowSnackbar.snackbarErr("Minimum Topup Saldo Rp 10.000");
              return;
            }

            Navigator.pushNamed(
              context, PaymentPage.route, 
              arguments: {
                "customer_name": "-",
                "customer_no": "-",
                "product_code": productCode, 
                "product_price": productPrice,
                "topupby": typeTopup,
                "ref2": "-",
                "type": "topup"
              }
            );
          }, 
          child: Text("Selanjutnya",
            style: robotoRegular.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          )
        )
      ),
    );
  }
  
}