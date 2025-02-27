import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' as error;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _MvvmLinter();

class _MvvmLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        PropertyNameMismatchLint()
      ];
}

/// Lint rule that checks if property names in method calls match their accessor names.
class PropertyNameMismatchLint extends DartLintRule {
  PropertyNameMismatchLint() : super(code: _code);

  static const _code = LintCode(
    name: 'property_name_mismatch',
    problemMessage: 'Property name in method call does not match the accessor name',
    errorSeverity: error.ErrorSeverity.ERROR,
  );

  bool _isPropertyNameMethod(MethodInvocation node) {
    final method = node.methodName.staticElement;
    if (method is! MethodElement) return false;

    final parameters = method.parameters;
    if (parameters.isEmpty) return false;

    // Check if first parameter is named 'propertyName'
    return parameters.first.name == 'propertyName';
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (!node.isGetter && !node.isSetter) return;

      final body = node.body;
      if (body is! ExpressionFunctionBody) return;

      final expression = body.expression;
      if (expression is! MethodInvocation) return;

      // Check if the method expects a propertyName parameter
      if (!_isPropertyNameMethod(expression)) return;

      final arguments = expression.argumentList.arguments;
      if (arguments.isEmpty) return;
      
      final firstArg = arguments.first;
      if (firstArg is! SimpleStringLiteral) return;

      final propertyName = firstArg.value;
      final memberName = node.name.lexeme;

      if (propertyName != memberName) {
        reporter.atNode(firstArg, code);
      }
    });
  }
}