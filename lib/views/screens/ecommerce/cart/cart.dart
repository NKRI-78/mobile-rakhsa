import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

import 'package:rakhsa/views/screens/ecommerce/order/delivery.dart';

class Debouncer {
  final int milliseconds;
  Timer? timer;

  Debouncer({required this.milliseconds});

  void run(action) {
    timer?.cancel();
    timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    timer?.cancel();
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {

  late EcommerceProvider ecommerceProvider;

  Future<void> getData() async {
    if(!mounted) return;
      ecommerceProvider.getCart();
  }

  @override 
  void initState() {
    super.initState();

    ecommerceProvider = context.read<EcommerceProvider>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Consumer<EcommerceProvider>(
        builder: (_, notifier, __) {
          if(notifier.getCartStatus == GetCartStatus.loading) {
            return const SizedBox();
          }
          if(notifier.getCartStatus == GetCartStatus.empty) {
            return const SizedBox();
          }
          if(notifier.getCartStatus == GetCartStatus.error) {
            return const SizedBox();
          }
          return Container(
            height: 56.0,
            decoration: BoxDecoration(
              color: ColorResources.white,
              boxShadow: kElevationToShadow[4]
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
          
                Container(
                  margin: const EdgeInsets.only(
                    left: 10.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Total Pembayaran",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: ColorResources.hintColor
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(formatCurrency(notifier.cartData.totalPrice!),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.black
                        ),
                      )
                    ],
                  ),
                ),
                
                Flexible(
                  child: Container(
                    width: 110.0,
                    margin: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0
                    ),
                    child: CustomButton(
                      onTap: notifier.cartData.totalPrice == 0 
                      ? () {} 
                      : () {
                        Navigator.push(context, MaterialPageRoute(builder:(context) => const DeliveryScreen(
                          from: "cart",
                        )));
                      },
                      isBorder: false,
                      isBorderRadius: true,
                      sizeBorderRadius: 5.0,
                      isBoxShadow: false,
                      fontSize: Dimensions.fontSizeSmall,
                      isLoading: false,
                      btnColor: notifier.cartData.totalPrice == 0 
                      ? ColorResources.grey 
                      : const Color(0xFFFE1717),
                      btnTxt: "Selanjutnya",
                    ),
                  ),
                ),

              ],
            ),
          );

        },
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          return Future.sync(() {
            getData();
          });
        },
        child: Consumer<EcommerceProvider>(
          builder: (__, notifier, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                
                SliverAppBar(
                  backgroundColor: ColorResources.backgroundColor,
                  centerTitle: true,
                  leadingWidth: 33.0,
                  title: Text("Keranjang",
                    style: robotoRegular.copyWith(
                      color: ColorResources.black,
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.fontSizeLarge
                    ),
                  ),
                  leading: CupertinoNavigationBarBackButton(
                      color: ColorResources.black,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ) 
                  ),
      
                  if(notifier.getCartStatus == GetCartStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: CircularProgressIndicator.adaptive()
                        )
                      )
                    ),
      
                  if(notifier.getCartStatus == GetCartStatus.empty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text("Belum ada barang",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault
                          ),
                        )
                      )
                    ),
      
                  if(notifier.getCartStatus == GetCartStatus.error)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text("Hmm... Mohon tunggu yaa",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault
                          ),
                        )
                      )
                    ),
                  
                  if(notifier.getCartStatus == GetCartStatus.loaded)
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 20.0,
                        left: 16.0,
                        right: 16.0
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([

                          CheckboxListTile( 
                            title: Text('Pilih semua',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: ColorResources.black
                              ),
                            ),
                            value: notifier.selectedAll, 
                            onChanged: (bool? val) {
                              notifier.onSelectedAll(val!);
                            }
                          ),
                          
                          const SizedBox(height: 5.0),
                                    
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: notifier.cartData.stores!.length,
                            itemBuilder: (BuildContext context, int i) {
                              return CheckboxListTile(
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                                dense: false,
                                value: notifier.cartData.stores![i].selected,
                                onChanged: (bool? val) async {
                                  await notifier.storeSelected(
                                    i: i, 
                                    selected: val!
                                  );
                                },
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                      
                                    Text(notifier.cartData.stores![i].store.name,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeLarge
                                      ),
                                    ),

                                    const SizedBox(height: 8.0),

                                    Text(notifier.cartData.stores![i].store.address,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: ColorResources.hintColor
                                      ),
                                    ),
                                
                                    const SizedBox(height: 12.0),
                                      
                                    ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return const Divider(
                                          color: ColorResources.hintColor,
                                        );
                                      },
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: notifier.cartData.stores![i].items.length,
                                      itemBuilder: (BuildContext context, int z) {
                                        return CheckboxListTile(
                                          controlAffinity: ListTileControlAffinity.leading,
                                          contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                                          dense: false,
                                          value: notifier.cartData.stores![i].items[z].cart.selected,
                                          onChanged: (bool? val) {
                                            notifier.storeItemSelected(i: i, z: z, cartIdParam: notifier.cartData.stores![i].items[z].cart.id);
                                          },
                                          title: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                    
                                    
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                CachedNetworkImage(
                                                  imageUrl: notifier.cartData.stores![i].items[z].picture,
                                                  imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                                    return Container(
                                                      width: 30.0,
                                                      height: 30.0,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover
                                                        )
                                                      ),
                                                    );
                                                  },
                                                  placeholder: (BuildContext context, String url) {
                                                    return const Center(
                                                      child: SizedBox(
                                                        width: 30.0,
                                                        height: 30.0,
                                                        child: CircularProgressIndicator.adaptive()
                                                      )
                                                    );
                                                  },
                                                  errorWidget: (BuildContext context, String url, dynamic error) {
                                                    return const CircleAvatar(
                                                      maxRadius: 30.0,
                                                      backgroundImage: NetworkImage("https://dummyimage.com/300x300/000/fff"),
                                                    );
                                                  },
                                                ),
                                    
                                                SizedBox(
                                                  width: 180.0,
                                                  child: Text(notifier.cartData.stores![i].items[z].name,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: robotoRegular.copyWith(
                                                      fontSize: Dimensions.fontSizeDefault
                                                    ),
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 5.0),
                                                
                                                Text(formatCurrency(notifier.cartData.stores![i].items[z].price),
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions.fontSizeDefault,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 8.0),
                                    
                                                  SizedBox(
                                                    width: 200.0,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                      
                                                        Expanded(
                                                          flex: 25,
                                                          child: Bouncing(
                                                          onPress: () {
                                                            showModalBottomSheet(
                                                              shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(30.0),
                                                                  topRight: Radius.circular(30.0)
                                                                )
                                                              ),
                                                              context: context,
                                                              isScrollControlled: true,
                                                              builder: (BuildContext context) {
                                                                return Padding(
                                                                  padding: EdgeInsets.only(
                                                                    bottom: MediaQuery.of(context).viewInsets.bottom
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Container(
                                                                        margin: const EdgeInsets.only(top: 35.0),
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                                          children: [
                                                                            Container(
                                                                              margin: const EdgeInsets.only(
                                                                                top: 5.0,
                                                                                left: 10.0,
                                                                                right: 10.0,
                                                                                bottom: 5.0
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text("Catatan",
                                                                                    style: robotoRegular.copyWith(
                                                                                      fontSize: Dimensions.fontSizeLarge,
                                                                                      fontWeight: FontWeight.bold
                                                                                    ),
                                                                                  ),
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: const Padding(
                                                                                      padding: EdgeInsets.all(5.0),
                                                                                      child: Icon(
                                                                                        Icons.close,
                                                                                        size: 30.0,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ) 
                                                                            ),
                                                                            const Divider(
                                                                              height: 10.0,
                                                                              thickness: 1.5,
                                                                              color: ColorResources.greyBottomNavbar,
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.all(10.0),
                                                                              child: TextField(
                                                                                controller: notifier.cartData.stores![i].items[z].cart.noteC,
                                                                                maxLines: 8,
                                                                                maxLength: 100,
                                                                                decoration: const InputDecoration(
                                                                                  border: OutlineInputBorder(),
                                                                                  focusedBorder: OutlineInputBorder(),
                                                                                  enabledBorder: OutlineInputBorder()
                                                                                ),
                                                                                cursorColor: ColorResources.black,
                                                                              )
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ).whenComplete(() async {
                                                              await notifier.updateNote(
                                                                cartId: notifier.cartData.stores![i].items[z].cart.id, 
                                                                note: notifier.cartData.stores![i].items[z].cart.noteC.text
                                                              );
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(5.0),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                        
                                                                Text("Tulis Catatan",
                                                                  style: robotoRegular.copyWith(
                                                                    fontSize: Dimensions.fontSizeSmall,
                                                                    color: ColorResources.purple
                                                                  )
                                                                ),
                                        
                                                              ],
                                                            )
                                                            
                                                            
                                                          ),
                                                        ),
                                                      ),
                                    
                                                      Expanded(
                                                        flex: 45,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              height: 40.0,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                border: Border.all(
                                                                  color: ColorResources.hintColor
                                                                )
                                                              ),
                                                              child: TextField(
                                                                textAlign: TextAlign.center,
                                                                controller: notifier.cartData.stores![i].items[z].cart.totalCartC,
                                                                style: robotoRegular.copyWith(
                                                                  fontSize: Dimensions.fontSizeDefault,
                                                                ),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter.digitsOnly
                                                                ],
                                                                onChanged: (String val) {
                                        
                                                                  int qty = int.parse(val.isEmpty ? '0' : val);
                                        
                                                                  setState(() {
                                                                    notifier.cartData.stores![i].items[z].cart.qty = qty;
                                                                  });
                                                                      
                                                                  if(notifier.cartData.stores![i].items[z].cart.qty == 0) {
                                                                    setState(() {
                                                                      notifier.cartData.stores![i].items[z].cart.totalCartC =  TextEditingController(text: "1");
                                                                      notifier.cartData.stores![i].items[z].cart.totalCartC.selection = TextSelection.fromPosition(
                                                                        TextPosition(offset: notifier.cartData.stores![i].items[z].cart.totalCartC.text.length)
                                                                      );
                                                                    });
                                                                  } else {
                                                                    if(notifier.cartData.stores![i].items[z].cart.qty >= notifier.cartData.stores![i].items[z].stock) {
                                                                      setState(() {
                                                                        notifier.cartData.stores![i].items[z].cart.totalCartC =  TextEditingController(text: notifier.cartData.stores![i].items[z].stock.toString());
                                                                        notifier.cartData.stores![i].items[z].cart.totalCartC.selection = TextSelection.fromPosition(
                                                                          TextPosition(offset: notifier.cartData.stores![i].items[z].cart.totalCartC.text.length)
                                                                        );
                                                                        notifier.cartData.stores![i].items[z].cart.qty = int.parse(notifier.cartData.stores![i].items[z].stock.toString());
                                                                      });
                                                                      notifier.incrementTotalProduct(
                                                                        i,
                                                                        z,
                                                                        notifier.cartData.stores![i].items[z].cart.id,
                                                                        notifier.cartData.stores![i].items[z].cart.qty.toString()
                                                                      );
                                                                    } else {
                                                                      setState(() {
                                                                        notifier.cartData.stores![i].items[z].cart.qty = qty;
                                                                      });
                                                                      notifier.incrementTotalProduct(
                                                                        i,
                                                                        z,
                                                                        notifier.cartData.stores![i].items[z].cart.id,
                                                                        val
                                                                      );
                                                                    }
                                                                  }
                                                                  Debouncer debouncer = Debouncer(milliseconds: 50);
                                                                  debouncer.run(() => notifier.updateQty(
                                                                    cartId: notifier.cartData.stores![i].items[z].cart.id, 
                                                                    qty: notifier.cartData.stores![i].items[z].cart.qty
                                                                  ));
                                                                },
                                                                cursorColor: ColorResources.black,
                                                                decoration: InputDecoration(
                                                                  contentPadding: const EdgeInsets.only(
                                                                    left: 0.0,
                                                                    right: 0.0
                                                                  ),
                                                                  border: const OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                      color: ColorResources.black
                                                                    )
                                                                  ),
                                                                  focusedBorder: const OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                      color: Color(0xFF0F903B)
                                                                    )
                                                                  ),
                                                                  enabledBorder: const OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                      color: ColorResources.black
                                                                    )
                                                                  ),
                                                                  suffixIcon: Bouncing(
                                                                    onPress: () {
                                                                      int currval = int.parse(notifier.cartData.stores![i].items[z].cart.totalCartC.text);
                                        
                                                                      int stock = notifier.cartData.stores![i].items[z].stock;
                                        
                                                                      if(currval < stock) {
                                                                        setState(() {
                                                                          currval = currval + 1;
                                                                          notifier.cartData.stores![i].items[z].cart.totalCartC.text = (currval).toString();
                                                                        });
                                        
                                                                        notifier.incrementQty(i: i, z: z, qty: currval);
                                                                      }
                                                                    }, 
                                                                    child: const Icon(
                                                                      Icons.add,
                                                                      size: 15.0,
                                                                      color: ColorResources.black
                                                                    )
                                                                  ),
                                                                  prefixIcon: Bouncing(
                                                                    onPress: () {
                                                                      var currval = int.parse(notifier.cartData.stores![i].items[z].cart.totalCartC.text);
                                                                      
                                                                      if(currval > 1) {
                                                                        setState(() {
                                                                          currval = currval - 1;
                                                                          notifier.cartData.stores![i].items[z].cart.totalCartC.text = (currval).toString();
                                                                        });
                                        
                                                                        notifier.decrementQty(i: i, z: z, qty: currval);
                                                                      }
                                                                    }, 
                                                                    child: Icon(
                                                                      Icons.remove,
                                                                      size: 15.0,
                                                                      color: notifier.listenQty == 1 ||  notifier.listenQty == -1
                                                                      ? ColorResources.hintColor 
                                                                      : ColorResources.black
                                                                    )
                                                                  )
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ), 
                                                      ),
                                      
                                                      Bouncing(
                                                        onPress: () {
                                                          showGeneralDialog(
                                                            context: context,
                                                            barrierLabel: "Barrier",
                                                            barrierDismissible: true,
                                                            barrierColor: Colors.black.withOpacity(0.5),
                                                            transitionDuration: const Duration(milliseconds: 700),
                                                            pageBuilder: (BuildContext context, Animation<double> double, _) {
                                                              return Center(
                                                                child: Material(
                                                                  color: ColorResources.transparent,
                                                                  child: Container(
                                                                    margin: const EdgeInsets.all(20.0),
                                                                    height: 250.0,
                                                                    decoration: BoxDecoration(
                                                                      color: ColorResources.purple, 
                                                                      borderRadius: BorderRadius.circular(20.0)
                                                                    ),
                                                                    child: Stack(
                                                                      clipBehavior: Clip.none,
                                                                      children: [
                                                                                                        
                                                                        Align(
                                                                          alignment: Alignment.center,
                                                                          child: Text("Apakah kamu yakin ingin hapus dari Keranjang ?",
                                                                            style: robotoRegular.copyWith(
                                                                              fontSize: Dimensions.fontSizeDefault,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: ColorResources.white
                                                                            ),
                                                                          )
                                                                        ),
                                                                                                        
                                                                        Align(
                                                                          alignment: Alignment.bottomCenter,
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                            children: [
                                                                              Container(
                                                                                margin: const EdgeInsets.only(
                                                                                  top: 20.0,
                                                                                  bottom: 20.0
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    const Expanded(child: SizedBox()),
                                                                                    Expanded(
                                                                                      flex: 5,
                                                                                      child: CustomButton(
                                                                                        isBorderRadius: true,
                                                                                        isBoxShadow: false,
                                                                                        btnColor: ColorResources.white,
                                                                                        btnTextColor: ColorResources.black,
                                                                                        onTap: () {
                                                                                          Future.delayed(Duration.zero, () {
                                                                                            Navigator.pop(context);
                                                                                          });
                                                                                        }, 
                                                                                        btnTxt: "Batal"
                                                                                      ),
                                                                                    ),
                                                                                    const Expanded(child: SizedBox()),
                                                                                    Expanded(
                                                                                      flex: 5,
                                                                                      child: Consumer<EcommerceProvider>(
                                                                                        builder: (_, notifier, __) {
                                                                                          return CustomButton(
                                                                                            isBorderRadius: true,
                                                                                            isBoxShadow: false,
                                                                                            isLoading: notifier.deleteCartStatus == DeleteCartStatus.loading 
                                                                                            ? true 
                                                                                            : false,
                                                                                            btnColor: ColorResources.error ,
                                                                                            btnTextColor: ColorResources.white,
                                                                                            onTap: () async {
                                                                                              await notifier.deleteCart(cartId: notifier.cartData.stores![i].items[z].cart.id);
                                                                                              Future.delayed(Duration.zero, () {
                                                                                                Navigator.pop(context);
                                                                                              });
                                                                                            }, 
                                                                                            btnTxt: "OK"
                                                                                          );
                                                                                        },
                                                                                      )
                                                                                    ),
                                                                                    const Expanded(child: SizedBox()),
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ) 
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              );
                                                            },
                                                            transitionBuilder: (_, anim, __, child) {
                                                              Tween<Offset> tween;
                                                              if (anim.status == AnimationStatus.reverse) {
                                                                tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
                                                              } else {
                                                                tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
                                                              }
                                                              return SlideTransition(
                                                                position: tween.animate(anim),
                                                                child: FadeTransition(
                                                                  opacity: anim,
                                                                  child: child,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(5.0),
                                                          child: Icon(
                                                            Icons.delete,
                                                            color: ColorResources.error,
                                                          ),
                                                        ),
                                                      )
                                      
                                                    ],
                                                  ),
                                                ),
                                        
                                                notifier.cartData.stores![i].items[z].cart.noteC.text.isEmpty 
                                                ? const SizedBox() 
                                                : const SizedBox(height: 5.0),
                                        
                                                notifier.cartData.stores![i].items[z].cart.noteC.text.isEmpty 
                                                ? const SizedBox()
                                                : SizedBox(
                                                    width: 250.0,
                                                    child: Text("( ${notifier.cartData.stores![i].items[z].cart.noteC.text} )",
                                                    style: robotoRegular.copyWith(
                                                      fontSize: Dimensions.fontSizeExtraSmall,
                                                      color: ColorResources.black
                                                    ),
                                                  ),
                                                ),
                                                    
                                              ],
                                            )
                                          ],
                                        )
                                      );
                                        
                                        
                                
                                    }),
                                  ],
                                ),
                              );
                            },
                          )
                                    
                        ]
                      )
                    ),
                  )
              ],
            );
          },
        ) 
      )
    );
  }
}