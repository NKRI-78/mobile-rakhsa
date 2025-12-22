// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_trees.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $onBoardingRoute,
  $welcomeRoute,
  $noReferralCodeRoute,
  $activateReferralRoute,
  $dashboardRoute,
];

RouteBase get $onBoardingRoute => GoRouteData.$route(
  path: '/on-boarding',
  factory: $OnBoardingRoute._fromState,
);

mixin $OnBoardingRoute on GoRouteData {
  static OnBoardingRoute _fromState(GoRouterState state) =>
      const OnBoardingRoute();

  @override
  String get location => GoRouteData.$location('/on-boarding');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $welcomeRoute => GoRouteData.$route(
  path: '/welcome',
  factory: $WelcomeRoute._fromState,
  routes: [
    GoRouteData.$route(path: 'login', factory: $LoginRoute._fromState),
    GoRouteData.$route(path: 'register', factory: $RegisterRoute._fromState),
    GoRouteData.$route(
      path: 'forgot-password',
      factory: $ForgotPasswordRoute._fromState,
    ),
  ],
);

mixin $WelcomeRoute on GoRouteData {
  static WelcomeRoute _fromState(GoRouterState state) => const WelcomeRoute();

  @override
  String get location => GoRouteData.$location('/welcome');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/welcome/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RegisterRoute on GoRouteData {
  static RegisterRoute _fromState(GoRouterState state) => const RegisterRoute();

  @override
  String get location => GoRouteData.$location('/welcome/register');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ForgotPasswordRoute on GoRouteData {
  static ForgotPasswordRoute _fromState(GoRouterState state) =>
      const ForgotPasswordRoute();

  @override
  String get location => GoRouteData.$location('/welcome/forgot-password');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $noReferralCodeRoute => GoRouteData.$route(
  path: '/required-referral-code',
  factory: $NoReferralCodeRoute._fromState,
);

mixin $NoReferralCodeRoute on GoRouteData {
  static NoReferralCodeRoute _fromState(GoRouterState state) =>
      const NoReferralCodeRoute();

  @override
  String get location => GoRouteData.$location('/required-referral-code');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $activateReferralRoute => GoRouteData.$route(
  path: '/activate-referral-code',
  factory: $ActivateReferralRoute._fromState,
);

mixin $ActivateReferralRoute on GoRouteData {
  static ActivateReferralRoute _fromState(GoRouterState state) =>
      ActivateReferralRoute(uid: state.uri.queryParameters['uid'] ?? "-");

  ActivateReferralRoute get _self => this as ActivateReferralRoute;

  @override
  String get location => GoRouteData.$location(
    '/activate-referral-code',
    queryParams: {if (_self.uid != "-") 'uid': _self.uid},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $dashboardRoute => GoRouteData.$route(
  path: '/',
  factory: $DashboardRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'informasi-kbri',
      factory: $CurrentKBRIRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'kbri-detail',
          factory: $KBRIDetailRoute._fromState,
        ),
      ],
    ),
    GoRouteData.$route(
      path: 'panduan-hukum',
      factory: $PanduanHukumRoute._fromState,
    ),
    GoRouteData.$route(path: 'near-me', factory: $NearMeRoute._fromState),
    GoRouteData.$route(path: 'profile', factory: $ProfileRoute._fromState),
    GoRouteData.$route(
      path: 'notification',
      factory: $NotificationRoute._fromState,
    ),
    GoRouteData.$route(path: 'chat-room', factory: $ChatRoomRoute._fromState),
    GoRouteData.$route(
      path: 'news-detail',
      factory: $NewsDetailRoute._fromState,
    ),
    GoRouteData.$route(path: 'weather', factory: $WeatherRoute._fromState),
  ],
);

mixin $DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) => DashboardRoute(
    fromRegister:
        _$convertMapValue(
          'from-register',
          state.uri.queryParameters,
          _$boolConverter,
        ) ??
        false,
  );

  DashboardRoute get _self => this as DashboardRoute;

  @override
  String get location => GoRouteData.$location(
    '/',
    queryParams: {
      if (_self.fromRegister != false)
        'from-register': _self.fromRegister.toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CurrentKBRIRoute on GoRouteData {
  static CurrentKBRIRoute _fromState(GoRouterState state) =>
      const CurrentKBRIRoute();

  @override
  String get location => GoRouteData.$location('/informasi-kbri');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $KBRIDetailRoute on GoRouteData {
  static KBRIDetailRoute _fromState(GoRouterState state) => KBRIDetailRoute(
    stateId: int.parse(state.uri.queryParameters['state-id']!),
  );

  KBRIDetailRoute get _self => this as KBRIDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/informasi-kbri/kbri-detail',
    queryParams: {'state-id': _self.stateId.toString()},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PanduanHukumRoute on GoRouteData {
  static PanduanHukumRoute _fromState(GoRouterState state) =>
      const PanduanHukumRoute();

  @override
  String get location => GoRouteData.$location('/panduan-hukum');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NearMeRoute on GoRouteData {
  static NearMeRoute _fromState(GoRouterState state) =>
      NearMeRoute(type: state.uri.queryParameters['type']!);

  NearMeRoute get _self => this as NearMeRoute;

  @override
  String get location =>
      GoRouteData.$location('/near-me', queryParams: {'type': _self.type});

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NotificationRoute on GoRouteData {
  static NotificationRoute _fromState(GoRouterState state) =>
      const NotificationRoute();

  @override
  String get location => GoRouteData.$location('/notification');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ChatRoomRoute on GoRouteData {
  static ChatRoomRoute _fromState(GoRouterState state) =>
      ChatRoomRoute(state.extra as ChatRoomParams);

  ChatRoomRoute get _self => this as ChatRoomRoute;

  @override
  String get location => GoRouteData.$location('/chat-room');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin $NewsDetailRoute on GoRouteData {
  static NewsDetailRoute _fromState(GoRouterState state) =>
      NewsDetailRoute(state.extra as EwsDetailPageParams);

  NewsDetailRoute get _self => this as NewsDetailRoute;

  @override
  String get location => GoRouteData.$location('/news-detail');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin $WeatherRoute on GoRouteData {
  static WeatherRoute _fromState(GoRouterState state) =>
      WeatherRoute(state.extra as WeatherPageParams);

  WeatherRoute get _self => this as WeatherRoute;

  @override
  String get location => GoRouteData.$location('/weather');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}
