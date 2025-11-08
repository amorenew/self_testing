import 'package:self_testing/src/templates/styles_base.dart';
import 'package:self_testing/src/templates/styles_golden.dart';
import 'package:self_testing/src/templates/styles_scenario.dart';
import 'package:self_testing/src/templates/styles_test.dart';

String reportStyles() => '''
${baseStyles()}
${scenarioStyles()}
${testStyles()}
${goldenStyles()}
''';
