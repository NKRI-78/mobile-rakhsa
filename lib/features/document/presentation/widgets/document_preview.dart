import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
              ? () async => await provider.updateDocument(type)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : hasDocument
                  ? _buildPreviewDocument(type)
                  : _buildUnAvailableDocument(),
        ),
      ),
    );
  }

  Widget _buildPreviewDocument(DocumentType type) {
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
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildUnAvailableDocument() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // icon
        Icon(Icons.document_scanner_outlined),
        SizedBox(height: 16),

        // text
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