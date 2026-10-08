import '../epos_platform_interface.dart';

class EposPrinterJob {
  EposPrinterJob({EposPlatform? platform})
    : _platform = platform ?? EposPlatform.instance;

  final EposPlatform _platform;

  final List<Map<String, dynamic>> _commands = [];

  List<Map<String, dynamic>> get commands => List.unmodifiable(_commands);

  EposPrinterJob textLang(EposTextLanguage lang) {
    _commands.add({'type': 'textLang', 'lang': lang.name});
    return this;
  }

  EposPrinterJob text(String text) {
    _commands.add({'type': 'text', 'text': text});
    return this;
  }

  EposPrinterJob textAlign(EposTextAlign align) {
    _commands.add({'type': 'textAlign', 'align': align.name});
    return this;
  }

  EposPrinterJob feed(int lines) {
    _commands.add({'type': 'feed', 'lines': lines});
    return this;
  }

  EposPrinterJob cut() {
    _commands.add({'type': 'cut'});
    return this;
  }

  Future<void> send() async {
    await _platform.sendPrintJob(_commands);
  }
}

enum EposTextAlign { left, center, right }

enum EposTextLanguage {
  enAwk, // default: English (awk)
  ja, // Japanese
  zhCh, // Simplified Chinese
  zhTw, // Traditional Chines
  ko, // Korean
  th, // Thai
  vi, // Vietnamese
  multi, // multiple languages (UTF-8)
}
