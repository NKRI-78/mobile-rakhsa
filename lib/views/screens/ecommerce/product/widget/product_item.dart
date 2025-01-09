import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rakhsa/common/helpers/format_currency.dart';

import 'package:rakhsa/data/models/ecommerce/product/all.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

import 'package:rakhsa/views/screens/ecommerce/product/product_detail.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  
  const ProductItem({
    required this.product,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 3;
    
    return SizedBox(
      width: width,
      child: Bouncing(
        onPress: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product.id) ));
        },  
        child: Card(
          elevation: 0.80,
          color:const Color(0xffF1F1F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
                                                      
              SizedBox(
                height: 120.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
      
                    CachedNetworkImage(
                      imageUrl: product.medias.isNotEmpty 
                      ? product.medias.first.path 
                      : 'https://dummyimage.com/300x300/000/fff',
                      imageBuilder: (_, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0)
                            ),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fitWidth
                            )
                          ),
                        );
                      },
                      placeholder: (_, __) {
                        return const Center(
                          child: SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: CircularProgressIndicator.adaptive()
                          )
                        );
                      },
                      errorWidget: (_, __, ___) {
                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0)
                            ),
                            image: DecorationImage(
                              image: NetworkImage('https://dummyimage.com/300x300/000/fff'),
                              fit: BoxFit.fitHeight
                            )
                          ),
                        ); 
                      },
                    ),
              
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 8.0, 
                  right: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(product.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(formatCurrency(product.price),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: robotoRegular.copyWith(
                        color: ColorResources.black,
                        fontSize: Dimensions.fontSizeSmall,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
      
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10.0
                ),
                child: Text(product.store.province,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall
                  ),
                ),
              ),
      
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [

                      RatingBar.builder(
                        initialRating: double.parse(product.rating.toString()),
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

                      product.rating == 0 
                        ? const SizedBox() 
                        : Text(product.rating.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall
                        ),
                      ),

                    ],
                  ),
                ) 
              ),  

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [

                    Text("Stok ${product.stock}",
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: ColorResources.black
                      ),
                    ),

                    product.stock != 0 
                    ? const SizedBox()
                    : const SizedBox(width: 10.0),

                    product.stock != 0 
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
                      )

                  ],
                ) 
              ),

              SizedBox(
                width: double.infinity,
                height: 38.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                  
                      const Icon(
                        Icons.store,
                        size: 10.0,
                      ),
                  
                      const SizedBox(width: 4.0),
                  
                      Flexible(
                        child: Text(product.store.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: ColorResources.black
                          ),
                        ),
                      )
                  
                    ],
                  ),
                ),
              )
      
            ],
          )
        ),
      ),
    ); 
  }
}