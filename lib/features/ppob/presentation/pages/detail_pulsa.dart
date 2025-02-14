import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/ppob/presentation/pages/payment.dart';
import 'package:rakhsa/features/ppob/presentation/providers/inquiry_pulsa_listener.dart';

import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

class PPOBDetailPulsaPage extends StatefulWidget {
  final String title;
  final String type;

  const PPOBDetailPulsaPage({
    required this.title,
    required this.type,
    super.key
  });

  @override
  State<PPOBDetailPulsaPage> createState() => PPOBDetailPulsaPageState();
}

class PPOBDetailPulsaPageState extends State<PPOBDetailPulsaPage> {

  String productId = "";
  String productName = "";

  int productPrice = 0;
  int selected = -1;

  late TextEditingController getC;

  Timer? debounce;

  void onPhoneChange() {
    if(getC.text.startsWith('0') || getC.text.startsWith('8')) {
      getC = TextEditingController(text: "62");
      getC.selection = TextSelection.fromPosition(TextPosition(offset: getC.text.length));
    }

    setState(() {
                    
    });
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
    return Scaffold(
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 20.0
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: productId.isEmpty 
            ?Colors.grey
            :const Color(0XFFC82927),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)
            )
          ),
          onPressed: () {
            if(productId.isEmpty) {
              ShowSnackbar.snackbarErr("Anda belum memilih denom");
              return;
            }
            if(getC.text.isEmpty) {
              ShowSnackbar.snackbarErr("Anda belum mengisi nomor ponsel");
              return;
            }
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => PaymentPage(
                customerName: "-", 
                customerNo: getC.text, 
                productId: productId, 
                productName: productName,
                productPrice: productPrice, 
                topupby: "-", 
                ref2: "-", 
                type: widget.type
              ))
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
      body: Consumer<InquiryPulsaProvider>(
        builder: (BuildContext context, InquiryPulsaProvider notifier, Widget? child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
            
              SliverAppBar(
                title: Text("Pulsa & Paket Data",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.bold,
                    color: ColorResources.black
                  ),
                ),
                centerTitle: true,
                leading: CupertinoNavigationBarBackButton(
                  color: ColorResources.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  height: 80.0,
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 10.0,  left: 5.0, 
                    right: 5.0, bottom: 5.0
                  ),
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
                              fontSize: Dimensions.fontSizeSmall
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Nomor Ponsel",
                              hintStyle: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall
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
                                context.read<InquiryPulsaProvider>().fetch(prefix: getC.text, type: "pulsa");
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
                            context.read<InquiryPulsaProvider>().fetch(prefix: getC.text, type: "pulsa");
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
            
              if(notifier.state == ProviderState.loading) 
                const SliverFillRemaining(
                  child: Center(
                    child: SpinKitChasingDots(
                      color: primaryColor,
                    )
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
                        childAspectRatio: 3.6 / 3.0,
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                      ),
                      itemCount: notifier.entity.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Bouncing(
                          onPress: () {
                            setState(() {
                              if(selected != i) {
                                selected = i;
                                productId = notifier.entity[i].code;
                                productName = notifier.entity[i].name;
                                productPrice = notifier.entity[i].price;
                              } else {
                                selected = -1;
                                productId = "";
                                productPrice = 0;
                              }
                            });
                          },
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
                                    ? primaryColor
                                    : const Color(0xFFF4F4F4),
                                    boxShadow: kElevationToShadow[1],
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(notifier.entity[i].name,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: selected == i 
                                          ? ColorResources.white 
                                          : ColorResources.black
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Text(formatCurrency(notifier.entity[i].price),
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeExtraSmall,
                                          fontWeight: FontWeight.w600,
                                          color: selected == i 
                                          ? ColorResources.white 
                                          : ColorResources.black
                                        ),
                                      ),
                                    ],
                                  ) 
                                ),
                              ),
                                                  
                              // Positioned(
                              //   top: 0.0,
                              //   left: 0.0,
                              //   right: 0.0,
                              //   child: Image.asset('assets/image/icons/ic-coin.png',
                              //     width: 50.0,
                              //     height: 50.0,
                              //   )
                              // ),
                                                  
                            ],
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
    );
  }
  
}