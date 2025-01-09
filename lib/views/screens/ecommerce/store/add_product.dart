import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:lecle_flutter_absolute_path/lecle_flutter_absolute_path.dart';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'package:provider/provider.dart';

import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

import 'package:rakhsa/data/models/ecommerce/product/category.dart';

import 'package:rakhsa/maps/src/utils/uuid.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

class AddProductScreen extends StatefulWidget {
  final String storeId;

  const AddProductScreen({
    super.key,
    required this.storeId
  });

  @override
  State<AddProductScreen> createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late EcommerceProvider ecommerceProvider;

  String categoryId = "";

  List<dynamic> kindStuffSelected = [];

  ImageSource? imageSource;

  List<File> files = [];
  List<File> before = [];

  late TextEditingController nameC;
  late TextEditingController categoryC;
  late TextEditingController descC;
  late TextEditingController priceC;
  late TextEditingController stockC;
  late TextEditingController weightC;

  Future<void> getData() async {
    if(!mounted) return;
      ecommerceProvider.fetchAllProductCategory(
        isFromCreateProduct: true
      );
  }

  void pickImage() async {
    var imageSource = await showDialog<ImageSource>(context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Pilih sumber gambar",
          style: robotoRegular,
        ),
        actions: [
          MaterialButton(
            child: const Text("Kamera",
              style: robotoRegular,
            ),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          MaterialButton(
            child: const Text( "Galeri",
              style: robotoRegular,
            ),
            onPressed: uploadPic,
          )
        ],
      )
    );
    if (imageSource != null) {
      XFile? file = await ImagePicker().pickImage(source: imageSource, maxHeight: 720);
      File f = File(file!.path);
      setState(() {
        before.add(f);
        files = before.toSet().toList();
      });
    }
  }
  
  void uploadPic() async {
    List<Asset> resultList = [];
    if(files.isEmpty) {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: [],
        androidOptions: const AndroidOptions(
          maxImages: 5,
          hasCameraInPickerPage: false
        )
      );
    } else if(files.length == 4) { 
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: [],
        androidOptions: const AndroidOptions(
          maxImages: 1,
          hasCameraInPickerPage: false
        )
      );
    } else if(files.length == 3) { 
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: [],
        androidOptions: const AndroidOptions(
          maxImages: 2,
          hasCameraInPickerPage: false
        )
      );
    } else if(files.length == 2) { 
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: [],
        androidOptions: const AndroidOptions(
          maxImages: 3,
          hasCameraInPickerPage: false
        )
      );
    } else { 
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: [],
        androidOptions: const AndroidOptions(
          maxImages: 4,
          hasCameraInPickerPage: false
        )
      );
    } 
    Navigator.of(context, rootNavigator: true).pop();
    for (Asset imageAsset in resultList) {
      final filePath = await LecleFlutterAbsolutePath.getAbsolutePath(uri: imageAsset.identifier);
      File tempFile = File(filePath!);
      setState(() {
        before.add(tempFile);
        files = before.toSet().toList();
      });
    }
  }

  Future<void> submit() async {
    if(categoryC.text.isEmpty) {
      ShowSnackbar.snackbarErr("Kategori wajib diisi");
      return;
    }
    
    if(nameC.text.isEmpty) {
      ShowSnackbar.snackbarErr("Nama wajib diisi");
      return;
    }
    
    if(priceC.text.isEmpty) {
      ShowSnackbar.snackbarErr("Harga wajib diisi");
      return;
    }
    
    if(stockC.text.isEmpty) {
      ShowSnackbar.snackbarErr("Stok wajib diisi");
      return;
    }
    
    if(weightC.text.isEmpty) {
      ShowSnackbar.snackbarErr("Berat wajib diisi");
      return;
    }

    if(descC.text.isEmpty) {
      ShowSnackbar.snackbarErr("Deskripsi wajib diisi", "", ColorResources.error);
      return;
    }

    if(files.isEmpty) {
      ShowSnackbar.snackbarErr("Gambar wajib diisi", "", ColorResources.error);
      return;
    }

    String cleanPrice = priceC.text.replaceAll("Rp ", "").replaceAll(".", "");

    int price = int.parse(cleanPrice);

    await ecommerceProvider.createProduct(
      id: Uuid().generateV4(), 
      title: nameC.text, 
      files: files, 
      description: descC.text,
      price: price, 
      weight: int.parse(weightC.text), 
      stock: int.parse(stockC.text), 
      isDraft: false, 
      catId: categoryId, 
      storeId: widget.storeId
    );
  }

  @override 
  void initState() {
    super.initState();

    nameC = TextEditingController();
    descC = TextEditingController();
    categoryC = TextEditingController();
    priceC = TextEditingController();
    stockC = TextEditingController();
    weightC = TextEditingController();

    ecommerceProvider = context.read<EcommerceProvider>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {

    nameC.dispose();
    descC.dispose();
    categoryC.dispose();
    priceC.dispose();
    stockC.dispose();
    weightC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppBar(
      leading: CupertinoNavigationBarBackButton(
        color: ColorResources.black,
        onPressed: () {
     Navigator.pop(context);
        },
      ),
      centerTitle: true,
      elevation: 0,
      title: Text( "Tambah Produk",
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: ColorResources.black
        ),
      ),
    ),
    body: ListView(
      physics: const BouncingScrollPhysics(),
      children: [

        Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            
              inputFieldCategory(),
              
              const SizedBox(height: 15.0),

              inputFieldName(),
              
              const SizedBox(height: 15.0),
              
              inputFieldPrice(),
              
              const SizedBox(
                height: 15.0,
              ),

              Row(
                children: [
                  SizedBox(
                    width: 120.0,
                    child: inputFieldStock()
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        inputFieldWeight(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 15.0,
              ),
              
              inputFieldDescription(),
              
              const SizedBox(
                height: 15.0,
              ),
              
              Text("Gambar*",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                )
              ),
              
              const SizedBox(
                height: 10.0,
              ),
            
              Container(
                height: 100.0,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5)
                  ),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                  child: files.isEmpty
                    ? Row(
                        children: [
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              height: 80.0,
                              width: 80.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                color: Colors.grey.withOpacity(0.5)
                              ),
                              child: Center(
                                child: files.isEmpty
                                ? Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey[600],
                                    size: 35,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: FadeInImage(
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: double.infinity,
                                      image: FileImage(files.first),
                                      placeholder: const AssetImage("assets/images/default_image.png")
                                    ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Upload Gambar",
                                style: robotoRegular.copyWith(
                                  fontSize: 12.0,
                                )
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text("Maksimum 5 gambar, ukuran minimal 300x300px berformat JPG atau PNG",
                                style: robotoRegular.copyWith(
                                  fontSize: 12.0,
                                  color: Colors.grey[600]
                                )
                              ),
                            ],
                          ))
                        ],
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: files.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < files.length) {
                            return Stack(
                              children: [
                                
                                Container(
                                  height: 80,
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey[400]!
                                    ),
                                    color: Colors.grey[350]
                                  ),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: FadeInImage(
                                        fit: BoxFit.cover,
                                        height: double.infinity,
                                        width: double.infinity,
                                        image: FileImage(files[index]),
                                        placeholder: const AssetImage("assets/images/default_image.png")
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  right: 0.0,
                                  child: InkWell(
                                    onTap: () async {
                                      int i = files.indexOf(files[index]);
                                      setState(() {
                                        before.removeAt(i);
                                        files.removeAt(i);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5.0),
                                      decoration: const BoxDecoration(
                                        color: ColorResources.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0)
                                        )
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        size: 18.0,
                                        color: ColorResources.error,
                                      ),
                                    ),
                                  ),
                                )

                              ]
                            ); 
                          } else {
                            return GestureDetector(
                              onTap: () {
                                if (files.length < 5) {
                                  pickImage();
                                } else if (files.length >= 5) {
                                  setState(() {
                                    files.clear();
                                    before.clear();
                                  });
                                }
                              },
                              child: Container(
                                height: 80,
                                width: 80,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey[400]!
                                ),
                                color: files.length < 5 ? Colors.grey[350] : Colors.red),
                                child: Center(
                                  child: Icon(
                                    files.length < 5 ? Icons.camera_alt : Icons.delete,
                                    color: files.length < 5 ? Colors.grey[600] : ColorResources.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    CustomButton(
                      isBorder: false,
                      isBoxShadow: false,
                      isBorderRadius: true,
                      isLoading: context.watch<EcommerceProvider>().createProductStatus == CreateProductStatus.loading 
                      ? true 
                      : false,
                      btnColor: ColorResources.primary,
                      btnTextColor: ColorResources.white,
                      onTap: submit, 
                      btnTxt: "Submit"
                    )
                  ],
                )
              ),
            )

        ],
      )
    );
  }

  Widget inputFieldName() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text("Nama",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
            )
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorResources.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), 
                spreadRadius: 1.0, 
                blurRadius: 3.0, 
                offset: const Offset(0.0, 1.0)
              )
            ],
          ),
          child: TextFormField(
            controller: nameC,
            cursorColor: ColorResources.black,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            style: robotoRegular,
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.0, 
                horizontal: 15.0
              ),
              isDense: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5
                ),
              ),
            ),
          ),
        )
      ]
    );
  }

  Widget inputFieldDescription() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text("Deskripsi", 
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            )
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              context: context,
              builder: (BuildContext context) {
                return Consumer(
                  builder: (BuildContext context, EcommerceProvider notifier,  Widget? child) {
                    return Container(
                    height: MediaQuery.of(context).size.height * 0.96,
                    color: Colors.transparent,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: ColorResources.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0)
                          )
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0, 
                                    top: 16.0, bottom: 8.0
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                     Navigator.pop(context);
                                        },
                                        child: const Icon(
                                          Icons.close
                                        )
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 16),
                                        child: Text("Masukan Deskripsi",
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: ColorResources.black
                                          )
                                        )
                                      ),
                                      descC.text.isNotEmpty
                                      ? InkWell(
                                          onTap: () {
                                       Navigator.pop(context);
                                          },
                                          child: const Icon(
                                            Icons.done,
                                            color: ColorResources.black
                                          )
                                        )
                                      : const SizedBox(),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  thickness: 3,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0, 
                                    top: 8.0, bottom: 16.0
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorResources.white,
                                    borderRadius: BorderRadius.circular(10.0)
                                  ),
                                  child: TextFormField(
                                    autofocus: true,
                                    maxLines: null,
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: const InputDecoration(
                                      fillColor: ColorResources.white,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                    controller: descC,
                                    keyboardType: TextInputType.multiline,
                                    style: robotoRegular
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    );
                  }, 
                );
              }
            ).then((_) {
              setState(() { });
            });
          },
          child: Consumer<EcommerceProvider>(
            builder: (BuildContext context, EcommerceProvider notifier, Widget? child) {
              return Container(
                height: 120.0,
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5
                  ),
                ),
                child: Text(descC.text == ""
                  ? "" 
                  : descC.text,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault, 
                    color: ColorResources.black 
                  )
                )
              );
            },
          )
        ),
      ],
    );             
  }

  Widget inputFieldStock() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text("Stok *",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            )
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorResources.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), 
                spreadRadius: 1.0, 
                blurRadius: 3.0, 
                offset: const Offset(0.0, 1.0)
              )
            ],
          ),
          child: TextFormField(
            controller: stockC,
            cursorColor: ColorResources.black,
            keyboardType: TextInputType.number,
            style: robotoRegular,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "0",
              isDense: true,
              hintStyle: robotoRegular.copyWith(
                color: Theme.of(context).hintColor
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5
                ),
              ),
            ),
          ),
        )
      ]
    );
  }

  Widget inputFieldPrice() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text("Harga *",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            )
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorResources.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), 
                spreadRadius: 1.0, 
                blurRadius: 3.0, 
                offset: const Offset(0.0, 1.0)
              )
            ],
          ),
          child: TextFormField(
            controller: priceC,
            cursorColor: ColorResources.black,
            keyboardType: TextInputType.number,
            style: robotoRegular,
            inputFormatters: [
              CurrencyTextInputFormatter.currency(
                locale: 'id',
                decimalDigits: 0,
                symbol: 'Rp ',
              ),
            ],
            decoration: InputDecoration(
            fillColor: ColorResources.white,
            hintText: "0",
            isDense: true,
            hintStyle: robotoRegular.copyWith(
              color: Theme.of(context).hintColor
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 0.5
              ),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 0.5
              ),
            ),
          )),
        )
      ]
    );
  }

  
  Widget inputFieldCategory() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text("Kategori",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            )
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorResources.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), 
                spreadRadius: 1.0, 
                blurRadius: 3.0, 
                offset: const Offset(0.0, 1.0)
              )
            ],
          ),
          child: TextFormField(
            readOnly: true,
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                context: context,
                builder: (BuildContext context) {
                  return Consumer(
                    builder: (BuildContext context, EcommerceProvider notifier, Widget? child) {
                      return Container(
                      height: MediaQuery.of(context).size.height * 0.96,
                      color: Colors.transparent,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: ColorResources.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0)
                            )
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                       Navigator.pop(context);
                                          },
                                          child: const Icon(
                                            Icons.close
                                          )
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(left: 16),
                                          child: Text("Kategori",
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              color: ColorResources.black
                                            )
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 3.0,
                                  ),
                                  Expanded(
                                    child: Consumer<EcommerceProvider>(
                                      builder: (BuildContext context, EcommerceProvider notifier, Widget? child) {
                                        return ListView.separated(
                                          separatorBuilder: (BuildContext context, int i) => const Divider(
                                            color: ColorResources.dimGrey,
                                            thickness: 0.1,
                                          ),
                                          shrinkWrap: true,
                                          physics: const BouncingScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          itemCount: notifier.productCategories.length,
                                          itemBuilder: (BuildContext context, int i) {
                                            
                                            ProductCategoryData category = notifier.productCategories[i];

                                            return Container(
                                              margin: const EdgeInsets.only(top: 5.0, left: 16.0, right: 16.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(category.name,
                                                    style: robotoRegular.copyWith(
                                                      fontSize: Dimensions.fontSizeDefault,
                                                      fontWeight: FontWeight.bold
                                                    )
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        categoryId = category.id;
                                                        categoryC.text = category.name;
                                                      });
                                                 Navigator.pop(context);
                                                    },
                                                    child: const Text("Pilih",
                                                      style: robotoRegular,
                                                    ),
                                                  )                                              
                                                ],
                                              ),
                                            );                                                                      
                                          },
                                        ); 
                                      },
                                    )
                                  )                                
                                ],
                              ),
                            ],
                          ),
                        )
                      );
                    }, 
                  );
                }
              );
            },
            cursorColor: ColorResources.black,
            keyboardType: TextInputType.text,
            style: robotoRegular,
            controller: categoryC,
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
              isDense: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5
                ),
              ),
            ),
          )
      
        )
        
      ]
    );
  }

  Widget inputFieldWeight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          alignment: Alignment.centerLeft,
          child: Text("Berat *",
            style: robotoRegular.copyWith(
              fontSize: 13.0,
            )
          ),
        ),
        
        const SizedBox(
          height: 10.0,
        ),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorResources.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), 
                spreadRadius: 1.0, 
                blurRadius: 3.0, 
                offset: const Offset(0.0, 1.0)
              )
            ],
          ),
          child: TextFormField(
            controller: weightC,
            cursorColor: ColorResources.black,
            keyboardType: TextInputType.number,
            style: robotoRegular,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "0",
              isDense: true,
              suffixIcon: SizedBox(
                width: 80.0,
                child: Center(
                  child: Text("Gram",
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              hintStyle: robotoRegular.copyWith(
                color: Theme.of(context).hintColor
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5
                ),
              ),
            ),
          ),
        )

        ]
      );
    }
  
}