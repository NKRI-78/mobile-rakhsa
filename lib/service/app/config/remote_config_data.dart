import 'package:equatable/equatable.dart';

class RemoteConfigData extends Equatable {
  final bool underReview;
  final RemoteConfigAppVersion appVersion;
  final List<String> sosSupportedCountries;

  const RemoteConfigData({
    required this.underReview,
    required this.appVersion,
    required this.sosSupportedCountries,
  });

  @override
  List<Object?> get props => [underReview, appVersion, sosSupportedCountries];

  RemoteConfigData copyWith({
    bool? underReview,
    RemoteConfigAppVersion? appVersion,
    List<String>? sosSupportedCountries,
  }) {
    return RemoteConfigData(
      underReview: underReview ?? this.underReview,
      appVersion: appVersion ?? this.appVersion,
      sosSupportedCountries:
          sosSupportedCountries ?? this.sosSupportedCountries,
    );
  }

  factory RemoteConfigData.fromJson(Map<String, dynamic> json) {
    return RemoteConfigData(
      underReview: json['under_review'],
      appVersion: RemoteConfigAppVersion.fromJson(json['app_version']),
      sosSupportedCountries: (json['sos_supported_countries'] is List)
          ? (json['sos_supported_countries'] as List)
                .map((e) => e.toString())
                .toList()
          : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "under_review": underReview,
      "app_version": appVersion.toJson(),
      "sos_supported_countries": sosSupportedCountries,
    };
  }
}

class RemoteConfigAppVersion extends Equatable {
  final String ios;
  final String android;

  const RemoteConfigAppVersion({required this.ios, required this.android});

  @override
  List<Object> get props => [ios, android];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'ios': ios, 'android': android};
  }

  factory RemoteConfigAppVersion.fromJson(Map<String, dynamic> map) {
    return RemoteConfigAppVersion(ios: map['ios'], android: map['android']);
  }

  RemoteConfigAppVersion copyWith({String? ios, String? android}) {
    return RemoteConfigAppVersion(
      ios: ios ?? this.ios,
      android: android ?? this.android,
    );
  }
}
