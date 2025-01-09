import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rakhsa/common/helpers/censored_name.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';
import 'package:rakhsa/common/helpers/ddmmyyyy.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/views/basewidgets/preview/preview_review.dart';

import 'package:readmore/readmore.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/views/screens/ecommerce/store/edit_product.dart';
import 'package:rakhsa/views/screens/ecommerce/cart/cart.dart';
import 'package:rakhsa/views/screens/ecommerce/order/delivery.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({
    required this.productId,
    super.key
  });

  @override
  State<ProductDetailScreen> createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin  {

  late EcommerceProvider ep;

  int current = 0;

  Future<void> getData() async {
    if(!mounted) return;
      await ep.fetchProduct(productId: widget.productId);

    if(!mounted) return;
      await ep.checkStoreOwner();

    if(!mounted) return;
      await ep.getCart();
  }

  @override 
  void initState() {
    super.initState();
    
    ep = context.read<EcommerceProvider>();

    ep.controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    ep.animation = Tween<double>(begin: 0, end: 8).chain(CurveTween(curve: Curves.elasticIn)).animate(ep.controller)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ep.controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        ep.controller.forward();
      }
    });

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    ep.controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          
          Consumer<EcommerceProvider>(
            builder: (__, notifier, _) {
              return RefreshIndicator(
                onRefresh: () {
                  return Future.sync(() {

                  });
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                        
                    SliverAppBar(
                      elevation: 0.0,
                      toolbarHeight: 70.0,
                      leadingWidth: 33.0,
                      pinned: true,
                      floating: false,
                      centerTitle: false,
                      titleSpacing: 0.0,
                      title: const SizedBox(),
                      leading: CupertinoNavigationBarBackButton(
                        color: ColorResources.black,
                        onPressed: () {
                     Navigator.pop(context);
                        },
                      ),
                      actions: [

                      if(notifier.getCartStatus == GetCartStatus.loading)
                        Container(
                          margin: const EdgeInsets.only(
                            right: 16.0,
                            left: 16.0
                          ),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                            },
                            child: const Icon(
                              Icons.shopping_cart,
                              size: 20.0
                            ),
                          ),
                        ),

                      if(notifier.getCartStatus == GetCartStatus.error)
                        Container(
                          margin: const EdgeInsets.only(
                            right: 16.0,
                            left: 16.0
                          ),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                            },
                            child: const Icon(
                              Icons.shopping_cart,
                              size: 20.0
                            ),
                          ),
                        ),

                      if(notifier.getCartStatus == GetCartStatus.empty)
                        Container(
                          margin: const EdgeInsets.only(
                            right: 16.0,
                            left: 16.0
                          ),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                            },
                            child: AnimatedBuilder(
                              animation: ep.animation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, ep.animation.value),
                                  child: const Icon(
                                    Icons.shopping_cart,
                                    size: 20.0,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    
                      if(notifier.getCartStatus == GetCartStatus.loaded)
                        Container(
                          margin: const EdgeInsets.only(
                            top: 25.0,
                            right: 16.0,
                            left: 16.0
                          ),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                            },
                            child: Badge(
                              label: Text(notifier.cartData.totalItem.toString(),
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall
                                ),
                              ),
                              child: AnimatedBuilder(
                                animation: ep.animation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, ep.animation.value),
                                    child: const Icon(
                                      Icons.shopping_cart,
                                      size: 20.0,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                
                    if(notifier.detailProductStatus == DetailProductStatus.loading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: CircularProgressIndicator()
                          ),
                        )
                      ),

                    if(notifier.detailProductStatus == DetailProductStatus.error) 
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

                    if(notifier.detailProductStatus == DetailProductStatus.loaded) 
                      SliverList(
                        delegate: SliverChildListDelegate([
                        
                          SizedBox(
                            height: 450.0,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [

                                notifier.productDetailData.product!.medias.isEmpty 
                                ? CachedNetworkImage(
                                  imageUrl: "https://dummyimage.com/300x300/000/fff",
                                  imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.contain,
                                          image: imageProvider
                                        )
                                      ),
                                    );
                                  },
                                  placeholder: (BuildContext context, String url) {
                                    return const Center(
                                      child: SizedBox(
                                        width: 32.0,
                                        height: 32.0,
                                        child: CircularProgressIndicator.adaptive()
                                      )
                                    );
                                  },
                                  errorWidget: (BuildContext context, String url, dynamic error) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.contain,
                                          image: NetworkImage("https://dummyimage.com/300x300/000/fff")
                                        )
                                      ),
                                    );
                                  },
                                )
                              : CarouselSlider(
                                  items: notifier.productDetailData.product!.medias.map((image) {
                                    return CachedNetworkImage(
                                      imageUrl: image.path,
                                      imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.contain,
                                              image: imageProvider
                                            )
                                          ),
                                        );
                                      },
                                      placeholder: (BuildContext context, String url) {
                                        return const Center(
                                          child: SizedBox(
                                            width: 32.0,
                                            height: 32.0,
                                            child: CircularProgressIndicator.adaptive()
                                          )
                                        );
                                      },
                                      errorWidget: (BuildContext context, String url, dynamic error) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.contain,
                                              image: NetworkImage("https://dummyimage.com/300x300/000/fff")
                                            )
                                          ),
                                        );
                                      },
                                    );
                                  }
                                ).toList(),
                                  options: CarouselOptions(
                                    height: double.infinity,
                                    enableInfiniteScroll: false,
                                    aspectRatio: 16 / 9,
                                    autoPlay: false,
                                    viewportFraction: 1.0,
                                    onPageChanged: (int i, CarouselPageChangedReason reason) {
                                      setState(() => current = i);
                                    }
                                  ),
                                ),
                        
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: 75.0,
                                    margin: const EdgeInsets.only(
                                      right: 16.0, 
                                      bottom: 12.0
                                    ),
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[350],
                                      borderRadius: BorderRadius.circular(6.0)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 5.0, 
                                            right: 5.0
                                          ),
                                          child: const Icon(
                                            Icons.image
                                          ),
                                        ),
                                        Text("${notifier.productDetailData.product!.medias.isNotEmpty ? current+1 : 0} / ${notifier.productDetailData.product!.medias.length}",
                                          style: robotoRegular.copyWith(
                                            color: ColorResources.black,
                                            fontSize: Dimensions.fontSizeExtraSmall
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                        
                              ],
                            )
                          ),
                          
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0,
                              bottom: 5.0, top: 5.0
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(formatCurrency(notifier.productDetailData.product!.price),
                                      textAlign: TextAlign.start,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeOverLarge, 
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                  ),

                                  Text(notifier.productDetailData.product!.title,
                                    textAlign: TextAlign.start,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraLarge
                                    )
                                  ),
                                
                                  const SizedBox(height: 8.0),

                                  // RatingBar.builder(
                                  //   initialRating: double.parse(notifier.productDetailData.product!.rating.toString()),
                                  //   minRating: 0,
                                  //   direction: Axis.horizontal,
                                  //   allowHalfRating: true,
                                  //   itemCount: 5,
                                  //   maxRating: 5.0,
                                  //   wrapAlignment: WrapAlignment.start,
                                  //   itemSize: 10.0,
                                  //   ignoreGestures: true,
                                  //   itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  //   itemBuilder: (BuildContext context, int _) => const Icon(
                                  //     Icons.star,
                                  //     color: Colors.amber,
                                  //   ),
                                  //   onRatingUpdate: (double rating) {},
                                  // ),

                                  IntrinsicHeight(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [

                                        RatingBar.builder(
                                          initialRating: double.parse(notifier.productDetailData.product!.rating.toString()),
                                          minRating: 0,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          maxRating: 5.0,
                                          wrapAlignment: WrapAlignment.start,
                                          itemSize: 10.0,
                                          ignoreGestures: true,
                                          itemBuilder: (BuildContext context, int _) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (double rating) {},
                                        ),

                                        const SizedBox(width: 5.0),

                                        notifier.productDetailData.product!.rating == 0 
                                        ? const SizedBox() 
                                        : Text(notifier.productDetailData.product!.rating.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall
                                            ),
                                          ),

                                        const SizedBox(width: 10.0),

                                        notifier.productDetailData.product!.reviews.isEmpty 
                                        ? const SizedBox() 
                                        : InkWell(
                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                          onTap: () {
                                            
                                            showModalBottomSheet(
                                              context: context,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                              ),
                                              isScrollControlled: true, 
                                              builder: (context) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        height: 5,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[300],
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 16),
                                                      ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: notifier.productDetailData.product!.reviews.length,
                                                        itemBuilder: (BuildContext context, int i) {
                                                          
                                                          final review = notifier.productDetailData.product!.reviews[i];
                                                      
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                            child: ListTile(
                                                              title: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.max,
                                                                children: [

                                                                  CachedNetworkImage(
                                                                    imageUrl: review.user.avatar.toString(),
                                                                    imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                                                      return CircleAvatar(
                                                                        maxRadius: 20.0,
                                                                        backgroundImage: imageProvider,
                                                                      );
                                                                    },
                                                                    placeholder: (BuildContext context, String url) {
                                                                      return const Center(
                                                                        child: SizedBox(
                                                                          width: 32.0,
                                                                          height: 32.0,
                                                                          child: CircularProgressIndicator.adaptive()
                                                                        )
                                                                      );
                                                                    },
                                                                    errorWidget: (BuildContext context, String url, dynamic error) {
                                                                      return const CircleAvatar(
                                                                        maxRadius: 20.0,
                                                                        backgroundImage: NetworkImage("https://dummyimage.com/300x300/000/fff"),
                                                                      );
                                                                    },  
                                                                  ),

                                                                  const SizedBox(width: 15.0),

                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [

                                                                      Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [

                                                                          Text(censorName(review.user.fullname),
                                                                            style: robotoRegular.copyWith(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: Dimensions.fontSizeDefault
                                                                            ),
                                                                          ),

                                                                          Text(formatDateDDMMYYYY(review.createdAt),
                                                                            style: robotoRegular.copyWith(
                                                                              color: ColorResources.hintColor,
                                                                              fontSize: Dimensions.fontSizeExtraSmall
                                                                            ),
                                                                          ),

                                                                        ],
                                                                      ),
                                                                                  
                                                                      const SizedBox(height: 5.0),

                                                                      Row(
                                                                        children: List.generate(5, (i) {
                                                                          return Icon(
                                                                            i < int.parse(review.rate)
                                                                            ? Icons.star
                                                                            : Icons.star_border,
                                                                            color: Colors.amber,
                                                                            size: 14,
                                                                          );
                                                                        }),
                                                                      ),
                                                                      
                                                                      const SizedBox(height: 10.0),
                                                                      
                                                                      Text(review.caption,
                                                                        style: robotoRegular.copyWith(
                                                                          color: Colors.grey[600],
                                                                          fontSize: Dimensions.fontSizeSmall
                                                                        ),
                                                                      ),
                                                                      
                                                                    ],
                                                                  )
                                                      
                                                                ],
                                                              ),
                                                              subtitle: Container(
                                                                margin: const EdgeInsets.only(
                                                                  top: 10.0
                                                                ),
                                                                height: 50.0,  
                                                                child: ListView.separated(
                                                                  padding: EdgeInsets.zero,
                                                                  scrollDirection: Axis.horizontal,
                                                                  itemCount: review.medias.length,
                                                                  separatorBuilder: (context, index) => const SizedBox(width: 8.0),
                                                                  itemBuilder: (context, i) {
                                                                    return InkWell(
                                                                      onTap: () {
                                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewReviewImageScreen(
                                                                          id: i,
                                                                          medias: review.medias,
                                                                        )));
                                                                        
                                                                      },
                                                                      child: ClipRRect(
                                                                        borderRadius: BorderRadius.circular(10.0),
                                                                        child: CachedNetworkImage(
                                                                          imageUrl: review.medias[i].path,  
                                                                          width: 50.0,
                                                                          fit: BoxFit.cover,
                                                                          placeholder: (context, url) => const Center(
                                                                            child: SizedBox(
                                                                              width: 32.0,
                                                                              height: 32.0,
                                                                              child: CircularProgressIndicator.adaptive(),
                                                                            ),
                                                                          ),
                                                                          errorWidget: (context, url, error) => const CircleAvatar(
                                                                            radius: 40.0,
                                                                            backgroundImage: NetworkImage("https://dummyimage.com/300x300/000/fff"),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text("Lihat ulasan ( ${notifier.productDetailData.product!.reviews.length.toString()} )",
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeExtraSmall,
                                                color: ColorResources.black
                                              ),
                                            ),
                                          ),
                                        )

                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8.0),

                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [

                                      Text("Stok",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          fontWeight: FontWeight.bold,
                                          color: ColorResources.black
                                        ),
                                      ),

                                      const SizedBox(width: 8.0),

                                      Text(notifier.productDetailData.product!.stock.toString(),
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: ColorResources.black
                                        ),
                                      ),

                                      notifier.productDetailData.product!.stock != 0 
                                      ? const SizedBox()
                                      : const SizedBox(width: 10.0),

                                      notifier.productDetailData.product!.stock != 0 
                                      ? const SizedBox()
                                      : Container(
                                          padding: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: ColorResources.white,
                                            borderRadius: BorderRadius.circular(8.0)
                                          ),
                                          child: Text("Stok habis",
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              fontWeight: FontWeight.bold,
                                              color: ColorResources.error
                                            ),
                                          ),
                                        ),
                                      
                                    ],
                                  ),

                                  const SizedBox(height: 8.0),

                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [

                                      Text("Berat",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          fontWeight: FontWeight.bold,
                                          color: ColorResources.black
                                        ),
                                      ),

                                      const SizedBox(width: 8.0),

                                      Text("${notifier.productDetailData.product!.weight.toString()} gram",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: ColorResources.black
                                        ),
                                      )
                                      
                                    ],
                                  ),

                              ],
                            ),
                          ),
                  
                          Divider(
                            thickness: 1.8,
                            color: ColorResources.hintColor.withOpacity(0.5),
                          ),
                          
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0,
                              bottom: 5.0, top: 5.0
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("Detail Produk",
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.black
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                ReadMoreText(
                                  notifier.productDetailData.product!.caption,
                                  trimLength: 150,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: ColorResources.black
                                  ),
                                  delimiter: " ",
                                  trimExpandedText: "Tutup",
                                  trimCollapsedText: "Selanjutnya",
                                  moreStyle: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.primary
                                  ),
                                  lessStyle: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.primary
                                  ),
                                  delimiterStyle: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.bold,
                                    color: ColorResources.black
                                  ),
                                )
                              ],
                            ),
                          ),
                  
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0,
                              bottom: 10.0, top: 10.0
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                  
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [ 
                                    
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                  
                                        CachedNetworkImage(
                                          imageUrl: notifier.productDetailData.product!.store.logo,
                                          imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                            return CircleAvatar(
                                              maxRadius: 20.0,
                                              backgroundImage: imageProvider,
                                            );
                                          },
                                          placeholder: (BuildContext context, String url) {
                                            return const Center(
                                              child: SizedBox(
                                                width: 32.0,
                                                height: 32.0,
                                                child: CircularProgressIndicator.adaptive()
                                              )
                                            );
                                          },
                                          errorWidget: (BuildContext context, String url, dynamic error) {
                                            return const CircleAvatar(
                                              maxRadius: 20.0,
                                              backgroundImage: NetworkImage("https://dummyimage.com/300x300/000/fff"),
                                            );
                                          },  
                                        ),
                  
                                        Positioned(
                                          bottom: -5.0,
                                          right: -5.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: ColorResources.primary,
                                              borderRadius: BorderRadius.circular(50.0)
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Icon(
                                                Icons.check,
                                                color: ColorResources.white,
                                                size: 10.0,
                                              ),
                                            ),
                                          )
                                        )
                  
                                      ],
                                    ),
                  
                                    const SizedBox(width: 10.0),
                                    
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                  
                                        Text(notifier.productDetailData.product!.store.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            fontWeight: FontWeight.bold,
                                            color: ColorResources.black
                                          ),
                                        ),

                                        const SizedBox(height: 3.0),

                                        Text(notifier.productDetailData.product!.store.province,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: ColorResources.hintColor
                                          ),
                                        ),
                  
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 75.0,
                          )
                        ]
                      )
                    )
                  ],
                ),
              );
            },
          ),

          Consumer<EcommerceProvider>(
            builder: (_, notifier, __) {
              if(notifier.detailProductStatus == DetailProductStatus.loading) {
                return const SizedBox();
              }

              if(notifier.detailProductStatus == DetailProductStatus.error) {
                return const SizedBox();
              }

              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: ColorResources.white,
                    boxShadow: kElevationToShadow[4]
                  ),
                  child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    
                    context.watch<EcommerceProvider>().checkStoreOwnerStatus == CheckStoreOwnerStatus.loading 
                    ? const SizedBox() 
                    : Expanded(
                        flex: 5,
                        child:  Material(
                          color: ColorResources.transparent,
                          child: Bouncing(
                          onPress: notifier.addCartLiveStatus == AddCartLiveStatus.loading 
                          ? () {} 
                          : notifier.productDetailData.product!.stock > 0 
                          ? () async {
                              if( notifier.ownerModel.data?.storeId == notifier.productDetailData.product?.store.id) {
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
                                            color: const Color(0xFFC82927), 
                                            borderRadius: BorderRadius.circular(20.0)
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                                                              
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text("Apakah kamu yakin ingin hapus Produk ?",
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
                                                           Navigator.pop(context);
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
                                                                  isLoading: notifier.deleteProductStatus == DeleteProductStatus.loading 
                                                                  ? true 
                                                                  : false,
                                                                  btnColor: ColorResources.blue,
                                                                  btnTextColor: ColorResources.white,
                                                                  onTap: () async {
                                                                    await notifier.deleteProduct(
                                                                      storeId: notifier.ownerModel.data?.storeId ?? "-", 
                                                                      productId: widget.productId
                                                                    );
                                                                    Navigator.pop(context);
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
                              } else {
                                await notifier.addToCartLive(
                                  productId: widget.productId, 
                                  note: ""
                                );
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryScreen(from: "live")));
                              }
                            } 
                          : () {},
                          child: Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: notifier.productDetailData.product!.stock > 0 
                              ? notifier.ownerModel.data?.storeId == notifier.productDetailData.product?.store.id 
                              ? ColorResources.error
                              : ColorResources.primary 
                              : ColorResources.hintColor,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: notifier.addCartLiveStatus == AddCartLiveStatus.loading 
                            ? const SpinKitCircle(
                                color: Colors.white,
                                size: 20.0,
                              ) 
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  
                                  notifier.ownerModel.data?.storeId == notifier.productDetailData.product?.store.id 
                                  ? const Icon(
                                      Icons.delete,
                                      color: ColorResources.white,  
                                    )
                                  : const Icon(
                                      Icons.shopping_bag,
                                      color: ColorResources.white,  
                                    ),
                              
                                  const SizedBox(width: 8.0),
                                  
                                  notifier.ownerModel.data?.storeId == notifier.productDetailData.product?.store.id
                                  ? Text("Hapus Produk",
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        fontWeight: FontWeight.bold,
                                        color: ColorResources.white
                                      ),
                                    )
                                  : Text("Beli langsung",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      fontWeight: FontWeight.bold,
                                      color: ColorResources.white
                                    ),
                                  )
                                                
                                ],
                              ) 
                            ),
                          )
                        ))
                      ),

                      const Expanded(
                        flex: 1,
                        child: SizedBox()
                      ),

                      context.watch<EcommerceProvider>().checkStoreOwnerStatus == CheckStoreOwnerStatus.loading 
                      ? const SizedBox() 
                      : Expanded(
                          flex: 6,
                          child: Material(
                          color: ColorResources.transparent,
                          child: Bouncing(
                            onPress: notifier.addCartStatus == AddCartStatus.loading 
                            ? () {} 
                            : notifier.productDetailData.product!.stock > 0 
                            ? () async {
                                if(notifier.ownerModel.data?.storeId == notifier.productDetailData.product?.store.id) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProductScreen(
                                    storeId: notifier.ownerModel.data?.storeId ?? "-",
                                    productId: widget.productId,
                                  )));
                                } else {
                                  await notifier.addToCart(
                                    productId: widget.productId, 
                                    qty: 1, 
                                    note: ""
                                  );
                                }
                              } 
                            : () {},
                            child: Container(
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: notifier.productDetailData.product!.stock > 0 
                                ? ColorResources.blue
                                : ColorResources.hintColor,
                                borderRadius: BorderRadius.circular(10.0)
                              ),
                              child: notifier.addCartStatus == AddCartStatus.loading 
                              ? const SpinKitCircle(
                                  color: Colors.white,
                                  size: 20.0,
                                ) 
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    
                                    notifier.ownerModel.data?.storeId == notifier.productDetailData.product?.store.id 
                                    ? const Icon(
                                        Icons.edit,
                                        color: ColorResources.white,  
                                      )
                                    : const Icon(
                                        Icons.add_shopping_cart,
                                        color: ColorResources.white,  
                                      ),
                                
                                    const SizedBox(width: 8.0),
                                    
                                    Text(notifier.ownerModel.data?.storeId == notifier.productDetailData.product?.store.id 
                                      ? "Ubah Produk" 
                                      : "Tambah Keranjang",
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        fontWeight: FontWeight.bold,
                                        color: ColorResources.white
                                      ),
                                    )
                                                  
                                  ],
                                ) 
                              ),
                            )
                          )
                        )
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      )
    );
  }
}