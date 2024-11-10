import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/websockets.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider(create: (_) => di.locator<WebSocketsService>()),
];