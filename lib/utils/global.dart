import 'package:dox_core/dox_core.dart';

IocContainer _ioc = IocContainer();

class Global {
  /// get global ioc container
  /// ```
  /// ioc.register<ABC>((i) => ABC());
  /// ```
  static IocContainer get ioc => _ioc;
}
