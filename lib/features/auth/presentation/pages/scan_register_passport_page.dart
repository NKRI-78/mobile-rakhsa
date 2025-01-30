import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as p;
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/auth/presentation/provider/register_notifier.dart';
import 'package:rakhsa/features/auth/presentation/widget/scanning_effect.dart';
import 'package:rakhsa/maps/src/utils/uuid.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ScanRegisterPassportPage extends StatefulWidget {
  const ScanRegisterPassportPage({super.key});

  @override
  State<ScanRegisterPassportPage> createState() =>
      _ScanRegisterPassportPageState();
}

class _ScanRegisterPassportPageState extends State<ScanRegisterPassportPage> {

  final userId = Uuid().generateV4();
  late RegisterNotifier registerNotifier;

  @override
  void initState() {
    super.initState();

    registerNotifier = context.read<RegisterNotifier>();
    registerNotifier.registerPanelController(
          PanelController(),
        );

    // redirect to document scanner
    registerNotifier.deleteData();
    if (!registerNotifier.hasPath) {
      registerNotifier.startScan(context, userId);
    }
  }
  
  @override
  void dispose() {
    registerNotifier.deleteData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final actionButtonHeight =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 16;
    final appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        flexibleSpace: Image.asset(
          AssetSource.loginOrnament,
          fit: BoxFit.cover,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: p.Consumer<RegisterNotifier>(
              builder: (context, provider, _) => SlidingUpPanel(
                isDraggable: true,
                panelSnapping: true,
                parallaxEnabled: true,
                backdropEnabled: true,
                backdropColor: primaryColor,
                collapsed: _NameHeader(provider),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                controller: provider.panelController,
                maxHeight: deviceHeight - actionButtonHeight - appBarHeight,
                minHeight: context.watch<RegisterNotifier>().panelMinHeight,
                body: _ScanningViewState(
                  paddingBottom: actionButtonHeight + appBarHeight,
                ),
                panelBuilder: (sc) => _ScanningResultState(provider, sc),
              ),
            ),
          ),
    
          // FR button
          p.Consumer<RegisterNotifier>(
            builder: (context, provider, child) {
              return Container(
                width: double.infinity,
                height: actionButtonHeight,
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: provider.hasPassport
                      ? () => Navigator.pushNamed(
                            context,
                            RoutesNavigation.registerFr,
                            arguments: {
                              "user_id": userId,
                              "media":provider.media,
                              "passport":  provider.passport
                            },
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: whiteColor,
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lanjut Untuk Pemindaian Wajah'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NameHeader extends StatelessWidget {
  const _NameHeader(this.provider);

  final RegisterNotifier provider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: whiteColor,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      child: Center(
        child: Text(
          provider.passport?.fullName ?? '',
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ScanningResultState extends StatelessWidget {
  const _ScanningResultState(this.provider, this.sc);

  final RegisterNotifier provider;
  final ScrollController sc;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      controller: sc,
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 16,
      ),
      children: [
        /// country code
        _PassportField(
          'Kode Negara',
          provider.passport?.countryCode ?? '-',
        ),
        // passport number
        _PassportField(
          'No. Paspor',
          provider.passport?.passportNumber ?? '-',
        ),
        // nama
        _PassportField(
          'Nama Lengkap',
          provider.passport?.fullName ?? '-',
        ),
        // nationality
        _PassportField(
          'Kewarganegaraan',
          provider.passport?.nationality ?? '-',
        ),
        // place of birth
        _PassportField(
          'Tempat Lahir',
          provider.passport?.placeOfBirth ?? '-',
        ),
        // date of birth
        _PassportField(
          'Tanggal Lahir',
          provider.passport?.dateOfBirth ?? '-',
        ),
        // gender
        _PassportField(
          'Jenis Kelamin',
          provider.passport?.gender ?? '-',
        ),
        // date of issue
        _PassportField(
          'Tanggal Penerbitan',
          provider.passport?.dateOfIssue ?? '-',
        ),
        // date of expiry
        _PassportField(
          'Tanggal Habis Berlaku',
          provider.passport?.dateOfExpiry ?? '-',
        ),
        // period
        _PassportField(
          'Sisa Masa Berlaku',
          provider.passport?.period ?? '-',
        ),
        // registration number
        _PassportField(
          'No. Registrasi',
          provider.passport?.registrationNumber ?? '-',
        ),
        // issuing authority
        _PassportField(
          'Kantor yang Mengeluarkan',
          provider.passport?.issuingAuthority ?? '-',
        ),
        // mrz code
        _PassportField(
          'Kode MRZ',
          provider.passport?.mrzCode ?? '-',
        ),
      ],
    );
  }
}

class _PassportField extends StatelessWidget {
  const _PassportField(this.title, this.content);

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        Text(
          title,
          style: robotoRegular.copyWith(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),

        // text field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: robotoRegular.copyWith(
              color: blackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ScanningViewState extends StatelessWidget {
  const _ScanningViewState({required this.paddingBottom});

  final double paddingBottom;

  @override
  Widget build(BuildContext context) {
    const paddingAll = 16.0;
    return Padding(
      padding: EdgeInsets.only(
        top: paddingAll,
        right: paddingAll,
        left: paddingAll,
        bottom: paddingBottom + paddingAll,
      ),
      child: Material(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: p.Consumer<RegisterNotifier>(
          builder: (context, provider, child) {
            if (provider.hasPath) {
              return ScanningEffect(
                endScan: provider.hasPassport,
                child: Image.file(
                  File(provider.passportPath),
                ),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Memulai Pemindaian Paspor',
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(color: redColor),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
