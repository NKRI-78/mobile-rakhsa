import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:provider/provider.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

import 'package:rakhsa/features/ppob/presentation/pages/payment_page.dart';

import 'package:rakhsa/features/ppob/presentation/providers/inquiry_pulsa_listener.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

class PPOBDetailPaketDataPage extends StatefulWidget {
  static const route = '/ppob/paketdata/detail';

  final String title;
  const PPOBDetailPaketDataPage({
    required this.title,
    super.key
  });

  @override
  State<PPOBDetailPaketDataPage> createState() => PPOBDetailPaketDataPageState();
}

class PPOBDetailPaketDataPageState extends State<PPOBDetailPaketDataPage> {

  String productCode = "";
  int productPrice = 0;
  int selected = -1;

  late TextEditingController getC;

  Timer? debounce;

  void onPhoneChange() {
    if(getC.text.startsWith('0') || getC.text.startsWith('8')) {
      getC = TextEditingController(text: "62");
      getC.selection = TextSelection.fromPosition(TextPosition(offset: getC.text.length));
    }

    setState(() {});
  }

  Future<void> getData() async {
    if(!mounted) return;
      context.read<InquiryPulsaProvider>().reset();
  }

  @override 
  void initState() {
    super.initState();

    Future.microtask(() => getData());

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
    return buildUI();
  }

  Widget buildUI() {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            
          ];
        },
        body: Consumer<InquiryPulsaProvider>(
          builder: (_, notifier, __) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [

                SliverToBoxAdapter(
                  child: Container(
                    height: 80.0,
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0, bottom: 5.0),
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
                                  hintText: "Nomor Ponsel",
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
                                  if(val.startsWith('0') || val.startsWith('8')) {
                                    getC = TextEditingController(text: "62");
                                    getC.selection = TextSelection.fromPosition(TextPosition(offset: getC.text.length));
                                  } 
          
                                  setState(() {
                                      
                                  });
          
                                  if (debounce?.isActive ?? false) debounce?.cancel();
                                  debounce = Timer(const Duration(milliseconds: 500), () {
                                    context.read<InquiryPulsaProvider>().fetch(prefix: getC.text, type: "data");
                                  });
                                },
                              )
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Bouncing(
                              onPress: () async {
                                final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
                                getC.text = contact.phoneNumber!.number!.replaceAll(RegExp("[()+\\s-]+"), "");
                                if(!mounted) return;
                                  context.read<InquiryPulsaProvider>().fetch(prefix: getC.text, type: "data");
                                onPhoneChange();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10.0),
                                child: const Icon(
                                  Icons.contacts,
                                  color: Colors.black
                                ),
                              ),
                            ),
                          )
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
                          childAspectRatio: 4.0 / 3.5,
                          crossAxisSpacing: 50.0,
                          mainAxisSpacing: 50.0,
                        ),
                        itemCount: notifier.entity.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Bouncing(
                            onPress: () {
                              setState(() {
                                if(selected != i) {
                                  selected = i;
                                  productCode = notifier.entity[i].code;
                                  productPrice = notifier.entity[i].price;
                                } else {
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
                                      height: 100.0,
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
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(notifier.entity[i].name,
                                              textAlign: TextAlign.center,
                                              style: robotoRegular.copyWith(
                                                fontSize: 8.0,
                                                fontWeight: FontWeight.w600,
                                                color: selected == i 
                                                ? Colors.white 
                                                : Colors.black
                                              ),
                                            ),
                                            Text(formatCurrency(notifier.entity[i].price),
                                              style: robotoRegular.copyWith(
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w600,
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
            if(getC.text.isEmpty) {
              ShowSnackbar.snackbarErr("Anda belum mengisi nomor ponsel");
              return;
            }
            Navigator.pushNamed(
              context, PaymentPage.route, 
              arguments: {
                "customer_name": "-",
                "customer_no": getC.text,
                "product_code": productCode,
                "product_price": productPrice,
                "topupby": "-",
                "ref2": "-",
                "type": "data"
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