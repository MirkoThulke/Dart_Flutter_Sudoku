// inside tools/generate_plantuml.dart
import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/features.dart';

void main() {
  final libDir = Directory('lib');
  final classes = <ClassDeclaration>[];

  for (var file in libDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final result = parseFile(
        path: file.path,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final unit = result.unit;
      for (var declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          classes.add(declaration);
        }
      }
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('@startuml');

  for (var cls in classes) {
    final className = cls.name.lexeme;
    buffer.writeln('class $className {');

    for (var field in cls.members.whereType<FieldDeclaration>()) {
      final type = field.fields.type?.toSource() ?? 'var';
      for (var variable in field.fields.variables) {
        buffer.writeln('  $type ${variable.name.lexeme}');
      }
    }

    buffer.writeln('}');
  }

  // Add relationships
  for (var cls in classes) {
    final className = cls.name.lexeme;

    // Composition (fields that reference another class)
    for (var field in cls.members.whereType<FieldDeclaration>()) {
      final typeName = field.fields.type?.toSource();
      if (classes.any((c) => c.name.lexeme == typeName)) {
        buffer.writeln('$className --> $typeName');
      }
    }

    // Inheritance
    if (cls.extendsClause != null) {
      final parentName = cls.extendsClause!.superclass.name2?.lexeme;
      if (parentName != null) {
        buffer.writeln('$parentName <|-- $className');
      }
    }
  }

  buffer.writeln('@enduml');

  final outputDir = Directory('docs/diagrams');
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);
  final outFile = File('${outputDir.path}/classes.puml');
  outFile.writeAsStringSync(buffer.toString());

  print('PlantUML class diagram generated at ${outFile.path}');
}
