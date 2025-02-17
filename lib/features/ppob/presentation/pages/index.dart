import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
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
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/ppob/data/models/payment_model.dart';
import 'package:rakhsa/features/ppob/presentation/providers/inquiry_pulsa_listener.dart';
import 'package:rakhsa/features/ppob/presentation/providers/payment_channel_listener.dart';

// import 'package:rakhsa/features/ppob/presentation/pages/detail_paketdata.dart';
// import 'package:rakhsa/features/ppob/presentation/pages/detail_pulsa.dart';
// import 'package:rakhsa/features/ppob/presentation/pages/detail_tokenlistrik.dart';

import 'package:rakhsa/shared/basewidgets/button/bounce.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class PPOBPage extends StatefulWidget {
  static const route = '/ppob';

  const PPOBPage({super.key});

  @override
  State<PPOBPage> createState() => PPOBPageState();
}

class PPOBPageState extends State<PPOBPage> {

  String productId = "";
  String productName = "";

  int productPrice = 0;
  int selected = -1;

  late InquiryPulsaProvider inquiryPulsaProvider;
  late PaymentChannelProvider paymentChannelProvider;  
  late ProfileNotifier profileProvider;
  late TextEditingController getC;

  Timer? debounce;

  int selectedIndex = -1;
  String selectedType = "";

  List<Map<String, dynamic>> categories = [
    {
      "id": 1,
      "name": "Pulsa",
      "link": "pulsapaketdata",
      "image": "assets/images/ppob/ic-pulsa.png",
    },
    {
      "id": 2,
      "name": "Paket Data",
      "image": "assets/images/ppob/ic-paket.png",
      "link": "paketdata"
    },
    {
      "id": 3,
      "name": "Listrik",
      "image": "assets/images/ppob/ic-listrik.png",
      "link": "tokenlistrik"
    },
  ];
  
  void onPhoneChange() {
    if(getC.text.startsWith('0') || getC.text.startsWith('8')) {
      getC = TextEditingController(text: "62");
      getC.selection = TextSelection.fromPosition(TextPosition(offset: getC.text.length));
    }

    setState(() {
                    
    });
  }

  void onChangeCategories({
    required String type,
    required int i
  }) {
    setState(() {
      selectedIndex = i;
      selectedType = type;
    });
    // switch (categories[i]["link"]) {
    //   case "pulsapaketdata":
    //     Navigator.push(context, 
    //       MaterialPageRoute(builder: (context) {
    //         return PPOBDetailPulsaPage(
    //           title: categories[i]["name"],
    //           type: "Pulsa / Paket Data",
    //         );
    //       })
    //     );
    //   break;
    //   case "Paket Data":
    //     Navigator.pushNamed(context, 
    //       PPOBDetailPaketDataPage.route,
    //       arguments: {
    //         "title": categories[i]["name"]
    //       }  
    //     );
    //   break;
    //   case "Token Listrik":
    //     Navigator.pushNamed(context, 
    //       PPOBDetailTokenListrikPage.route,
    //       arguments: {
    //         "title": categories[i]["name"]
    //       }
    //     );
    //   break;
    //   default:
    // }
  }

  Future<void> getData() async {
    if(!mounted) return;
      paymentChannelProvider.reset();

    if(!mounted) return;
      await paymentChannelProvider.fetch();
  }

  @override 
  void initState() {
    super.initState();

    inquiryPulsaProvider = context.read<InquiryPulsaProvider>();
    paymentChannelProvider = context.read<PaymentChannelProvider>();
    profileProvider = context.read<ProfileNotifier>();

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
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Pulsa & Tagihan",
          style: robotoRegular.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: Dimensions.fontSizeDefault,
            color: primaryColor
          ),
        ),
        elevation: 1.0,
        shadowColor: ColorResources.black,
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
       bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 20.0
        ),
        child: CustomButton(
          onTap: () {
            showModalBottomSheet(
              context: context, 
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: ColorResources.white
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                  
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                  
                              Text("Metode Pembayaran",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: ColorResources.black
                                ),
                              ),
                  
                              const SizedBox(height: 10.0),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                              
                                  Consumer<PaymentChannelProvider>(
                                     builder: (BuildContext context, PaymentChannelProvider notifier, Widget? child) {
                                      return Text(notifier.paymentName.isEmpty 
                                        ? "Belum ada" 
                                        : notifier.paymentName,
                                        style: robotoRegular.copyWith(
                                          color: greyDescColor,
                                          fontSize: Dimensions.fontSizeDefault
                                        ),
                                      );
                                    }
                                  ),
                              
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context, 
                                        builder: (BuildContext context) {
                                          return Consumer<PaymentChannelProvider>(
                                            builder: (BuildContext context, PaymentChannelProvider notifier, Widget? child) {
                                              if(notifier.state == ProviderState.loading) {
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
                                              if(notifier.state == ProviderState.error) {
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
                                                  itemCount: notifier.entity.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    PaymentData paymentData = notifier.entity[i];

                                                    return InkWell(
                                                      onTap: () {
                                                        notifier.selectPaymentChannel(paymentData: paymentData);
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
                                                      
                                                            Icon(notifier.paymentName == paymentData.name
                                                              ? Icons.check
                                                              : Icons.chevron_right,
                                                              color: notifier.paymentName == paymentData.name 
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
                                    child: Text("Pilih Metode Pembayaran" ,
                                      style: robotoRegular.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Dimensions.fontSizeDefault
                                      ),
                                    ),
                                  )
                              
                                ],
                              ),
                              
                            ],
                          ),
                        ),
                  
                        const SizedBox(height: 8.0),
                  
                        const DottedLine(
                          dashLength: 5,
                          dashGapLength: 3,
                          lineThickness: 2,
                          dashColor: Colors.grey,
                        ),
                  
                        const SizedBox(height: 10.0),
                  
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                  
                              Text("Detail Transaksi",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: ColorResources.black
                                ),
                              ),
                  
                              const SizedBox(height: 8.0),
                                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text("Pembayaran Untuk",
                                    style: robotoRegular.copyWith(
                                      color: greyDescColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  ),
                                  Text(selectedType, 
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.black,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  )
                                ],
                              ),
                  
                              const SizedBox(height: 6.0),
                  
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text("Nama",
                                    style: robotoRegular.copyWith(
                                      color: greyDescColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  ),
                                  Text(profileProvider.entity.data?.username ?? "-", 
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.black,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  )
                                ],
                              ),
                  
                              const SizedBox(height: 12.0),
                  
                              Consumer<PaymentChannelProvider>(
                                builder: (BuildContext context, PaymentChannelProvider notifier, Widget? child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("Metode Pembayaran",
                                        style: robotoRegular.copyWith(
                                          color: greyDescColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Dimensions.fontSizeDefault
                                        ),
                                      ),
                                      Text(notifier.paymentCode.toUpperCase(), 
                                        style: robotoRegular.copyWith(
                                          color: ColorResources.black,
                                          fontSize: Dimensions.fontSizeDefault
                                        ),
                                      )
                                    ],
                                  );
                                }
                              ),
                  
                              const SizedBox(height: 12.0),
                  
                              Text("Harus dibayar",
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: ColorResources.black
                                ),
                              ),

                              const SizedBox(height: 8.0),
                          
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text("Total",
                                    style: robotoRegular.copyWith(
                                      color: greyDescColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  ),
                                  Text(formatCurrency(productPrice), 
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                  )
                                ],
                              ),

                            ],
                          )
                        ),

                        const SizedBox(height: 10.0),

                        Container(
                          margin: const EdgeInsets.all(20.0),
                          child: Selector<PaymentChannelProvider, String>(
                            selector: (BuildContext context, PaymentChannelProvider  provider) => provider.paymentCode,
                            builder: (BuildContext context, String paymentCode, Widget? child) {
                              return CustomButton(
                                onTap: paymentCode.isEmpty ? () {} : () {},
                                isBorder: false,
                                isBorderRadius: true,
                                btnColor: primaryColor,
                                btnTxt: "Bayar",
                              );
                            },
                          ),
                        )

                  
                      ],
                    )
                  ),
                );
              },
            );
          },
          isBorder: false,
          isBorderRadius: true,
          btnColor: primaryColor,
          btnTxt: "Selanjutnya",
        )
      ),
      body: Container(
        margin: const EdgeInsets.only( 
          top: 15.0,
          left: 15.0, 
          right: 15.0
        ),
        child: Consumer<InquiryPulsaProvider>(
          builder: (BuildContext context, InquiryPulsaProvider notifier, Widget? child) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
            
                SliverList(
                  delegate: SliverChildListDelegate([
                    
                    GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8.0),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 15.0,
                        crossAxisSpacing: 15.0
                      ),
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Bouncing(
                          onPress: () {
                            onChangeCategories(
                              i: i,
                              type: categories[i]["name"]
                            );
                            setState(() => selectedIndex = i);
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: selectedIndex == i 
                              ? primaryColor 
                              : ColorResources.white,
                              boxShadow: kElevationToShadow[1],
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(categories[i]["image"],
                                  height: 50.0,
                                  fit: BoxFit.scaleDown,
                                ),
                                const SizedBox(height: 10.0),
                                Text(categories[i]["name"],
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    fontWeight: FontWeight.w600,
                                    color: selectedIndex == i 
                                    ? ColorResources.white
                                    : ColorResources.black ,
                                  ),
                                ),
                              ],
                            ) 
                          ),
                        );
                      }
                    ),

                    selectedIndex == 0 
                    ? pulsaComponent()
                    : const SizedBox(), 
            
                  if(notifier.state == ProviderState.loading) 
                    const Center(
                      child: SpinKitChasingDots(
                        color: primaryColor,
                      )
                    ),
            
                  if(notifier.state == ProviderState.error) 
                    Center(
                      child: Text(notifier.message),
                    ),
            
                  if(notifier.state == ProviderState.empty) 
                    Center(
                      child: Text(notifier.message),
                    ),
            
                  if(notifier.state == ProviderState.loaded) 
                    Container(
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
                          childAspectRatio: 3.6 / 2.0,
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
                                      borderRadius: BorderRadius.circular(8.0),
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
                                                    
                              ],
                            ),
                          );
                        
                        }
                      ),
                    )
                    
                  ])
                )
            
              ],
            );
          }
        ),
      ),
    );
  }


  Widget pulsaComponent() {
    return Container(
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
                  inquiryPulsaProvider.fetch(prefix: getC.text, type: "pulsa");
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
              inquiryPulsaProvider.fetch(prefix: getC.text, type: "pulsa");
              onPhoneChange();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: const Icon(
                Icons.contacts,
                size: 26.0,
                color: primaryColor
              ),
            ),
          ),
        )
      ],
    ));
  }
}