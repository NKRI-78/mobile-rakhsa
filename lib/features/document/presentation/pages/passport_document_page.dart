import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/document/presentation/provider/document_notifier.dart';
import 'package:rakhsa/features/document/presentation/widgets/document_button.dart';
import 'package:rakhsa/features/document/presentation/widgets/document_preview.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class PassportDocumentPage extends StatefulWidget {
  const PassportDocumentPage({super.key});

  @override
  State<PassportDocumentPage> createState() => _PassportDocumentPageState();
}

class _PassportDocumentPageState extends State<PassportDocumentPage> {
  late DocumentNotifier documentNotifier;

  @override
  void initState() {
    super.initState();
    documentNotifier = context.read<DocumentNotifier>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      documentNotifier.getPassportUrlFromProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // app bar
          SliverAppBar(
            backgroundColor: ColorResources.backgroundColor,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).pop(),
              color: ColorResources.black,
            ),
          ),

          // title kategori
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Text(
                "Passport digital anda...",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // passport view
          SliverFillRemaining(
            hasScrollBody: false,
            child: Consumer<DocumentNotifier>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    // view passport
                    Expanded(
                      child: DocumentPreview(
                        provider,
                        type: DocumentType.passport,
                        hasDocument: provider.hasPassport,
                        loading: provider.passportIsLoading,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // view passport
                    Container(
                      height: 250,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: SfBarcodeGenerator(
                        value: 'https://www.imigrasi.go.id/',
                        symbology: QRCode(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // button update document
                    // tombol update dokumen hanya muncul ketika dokumen sudah terpilih
                    // document path != null
                    Visibility(
                      maintainAnimation: true,
                      maintainState: true,
                      visible: provider.hasPassport,
                      child: DocumentButton(
                        label: 'Update Passport',
                        onTap: () async => await provider.updateDocument(
                            context, DocumentType.passport),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
