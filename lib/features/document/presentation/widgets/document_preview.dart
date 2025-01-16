import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/features/document/presentation/provider/document_notifier.dart';

class DocumentPreview extends StatelessWidget {
  const DocumentPreview(
    this.provider, {
    super.key,
    required this.type,
    required this.loading,
    required this.hasDocument,
  });

  final bool loading;
  final bool hasDocument;
  final DocumentType type;
  final DocumentNotifier provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: (!hasDocument) // jika dokumen belum ada
              ? () async => await provider.updateDocument(context, type)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : hasDocument
                  ? buildPreviewDocument(type)
                  : buildUnAvailableDocument(),
        ),
      ),
    );
  }

  Widget buildPreviewDocument(DocumentType type) {
    String documentUrl;

    if (type == DocumentType.visa) {
      documentUrl = provider.visaPath;
    } else {
      documentUrl = provider.passportPath;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: documentUrl,
        errorWidget: (BuildContext context, String url, dynamic error) {
          return Image.asset(AssetSource.iconDefaultImg);
        },
        placeholder: (BuildContext context, String url) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildUnAvailableDocument() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.document_scanner_outlined),
        SizedBox(height: 16),
        Text(
          'Upload dokumen Anda disini',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}