import 'dart:io';

void main() {
  final dir = Directory('lib/presentation');
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      if (file.path.contains('background_pattern')) continue;
      
      var content = file.readAsStringSync();
      
      content = content.replaceAll('Color(0xFF2A1515)', 'Color(0xFFFDEDED)');
      content = content.replaceAll('Color(0xFF0D1117)', 'Colors.white');
      content = content.replaceAll('Color(0xFF161B22)', 'Colors.white');
      content = content.replaceAll('Color(0xFF30363D)', 'Color(0xFFE1E4E8)');
      content = content.replaceAll('Color(0xFF8FA4BB)', 'Color(0xFF484F58)');
      content = content.replaceAll('Color(0xFF6E7681)', 'Color(0xFF484F58)');
      content = content.replaceAll('color: Colors.white,', 'color: Colors.black,');
      content = content.replaceAll('Colors.white', 'Colors.black');
      
      // Let's fix cases where we wanted actual white
      // probability_page.dart: `color: selected ? Colors.white : ...` => `color: selected ? Colors.white : Color(0xFF484F58)`
      // In probability_page: selected ? Colors.white : const Color(0xFF8FA4BB)
      // wait, the script replaces Colors.white with Colors.black. 
      // the progress indicator uses Colors.white string, which will become Colors.black, which is correct for light mode.
      file.writeAsStringSync(content);
      print('Updated \${file.path}');
    }
  }
}
