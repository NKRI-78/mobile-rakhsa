// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:timelines/timelines.dart';

// import 'package:rakhsa/common/utils/color_resources.dart';
// import 'package:rakhsa/common/utils/custom_themes.dart';
// import 'package:rakhsa/common/utils/dimensions.dart';

// import 'package:rakhsa/data/models/ecommerce/order/tracking.dart';

// import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

// class TrackingScreen extends StatelessWidget {
//   final String waybill;

//   const TrackingScreen({
//     required this.waybill,
//     super.key
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//       physics: const BouncingScrollPhysics(
//         parent: AlwaysScrollableScrollPhysics()
//       ),
//       slivers: [

//         SliverAppBar(
//           centerTitle: true,
//           title: Text("Tracking",
//             style: robotoRegular.copyWith(
//               fontSize: Dimensions.fontSizeDefault,
//               fontWeight: FontWeight.bold,
//               color: ColorResources.black
//             ),
//           ),
//           leading: CupertinoNavigationBarBackButton(
//             color: ColorResources.black,
//             onPressed: () {
//          Navigator.pop(context);
//             },
//           ),
//         ),

//         SliverFillRemaining(
//           hasScrollBody: false,
//           child: FutureBuilder<TrackingModel>(
//             future: context.read<EcommerceProvider>().trackingOrder(waybill: waybill), 
//             builder: (BuildContext context, AsyncSnapshot<TrackingModel> snapshot) {
          
//             if(snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: SizedBox(
//                   width: 32.0,
//                   height: 32.0,
//                   child: CircularProgressIndicator.adaptive()
//                 ),
//               );
//             }

//             if(snapshot.hasError) {
//               return Center(
//                 child: Text("Data belum tersedia",
//                   style: robotoRegular.copyWith(
//                     fontSize: Dimensions.fontSizeDefault
//                   ),
//                 )
//               );
//             }
          
//             TrackingModel trackingModel = snapshot.data!;
          
//             return Center(
//                 child: Container(
//                 margin: const EdgeInsets.only(
//                   top: 12.0,
//                   bottom: 12.0,
//                   left: 16.0,
//                   right: 16.0
//                 ),
//                 child: Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: FixedTimeline.tileBuilder(
//                       theme: TimelineThemeData(
//                         color: ColorResources.primary
//                       ),
//                       builder: TimelineTileBuilder.connectedFromStyle(
//                         contentsAlign: ContentsAlign.alternating,
//                         oppositeContentsBuilder: (BuildContext context, int index) => const SizedBox(),
//                         contentsBuilder: (BuildContext context, int index) => Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(trackingModel.data.histories![index].desc,
//                                 style: robotoRegular.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault
//                                 ),
//                               ),
                              
//                               const SizedBox(height: 10.0),
                      
//                               Text(trackingModel.data.histories![index].date,
//                                 style: robotoRegular.copyWith(
//                                   fontSize: Dimensions.fontSizeSmall
//                                 ),
//                               )
//                             ],  
//                           ))
//                         ),
//                         connectorStyleBuilder: (BuildContext context, int index) => ConnectorStyle.solidLine,
//                         indicatorStyleBuilder: (BuildContext context, int index) => IndicatorStyle.dot, itemCount: trackingModel.data.histories!.length)),
//                       ),
//                     ),
//                   ),
//                 );
                
//               },
//             ),
//         )
//         ],
//       )
//     );
//   }
// }