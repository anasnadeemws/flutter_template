import 'package:flutter_template/flavors/flavor.dart';
import 'package:flutter_template/flavors/flavor_config.dart';
import 'package:flutter_template/flavors/flavor_values.dart';
import 'package:flutter_template/app.dart';

void main() {
  FlavorConfig.initialize(
    flavor: Flavor.dev,
    values: FlavorValues(
        apiBaseUrl: "https://www.metaweather.com/", logSqlStatements: true),
  );
  startApp();
}
