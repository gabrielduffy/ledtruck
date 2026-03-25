import 'dart:io';

void main() {
  final libDir = Directory(r'c:\Users\Acer\Desktop\Led Truck\ledtruck\lib');
  
  for (final file in libDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      String content = file.readAsStringSync();
      String newContent = content;
      
      final regex = RegExp(r'\.withOpacity\(([^)]+)\)');
      newContent = newContent.replaceAllMapped(regex, (match) {
        return '.withValues(alpha: ${match.group(1)})';
      });
      
      final fileName = file.uri.pathSegments.last;
      
      if (fileName == 'modal_editar_dispositivo.dart' || fileName == 'modal_vincular_carro.dart') {
        final valReg = RegExp(r'(\s+)value: (selected[A-Za-z0-9_]+),');
        newContent = newContent.replaceAllMapped(valReg, (match) {
          return '${match.group(1)}initialValue: ${match.group(2)},';
        });
      }
      
      if (fileName == 'franqueado_campanhas_screen.dart') {
        newContent = newContent.replaceAll(RegExp(r"import 'package:go_router/go_router\.dart';\r?\n?"), "");
      }
      
      if (fileName == 'base_components.dart') {
        newContent = newContent.replaceAll('dialogBackgroundColor', 'dialogTheme.backgroundColor');
      }
      
      if (content != newContent) {
        file.writeAsStringSync(newContent);
        print('Fixed: ${file.path}');
      }
    }
  }
}
