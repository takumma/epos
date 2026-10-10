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

  EposPrinterJob textFont(EposTextFont font) {
    _commands.add({'type': 'textFont', 'font': font.name});
    return this;
  }

  EposPrinterJob textSize(int width, int height) {
    assert(width > 0 && width <= 8, 'Text width must be between 1 and 8');
    assert(height > 0 && height <= 8, 'Text height must be between 1 and 8');
    _commands.add({'type': 'textSize', 'width': width, 'height': height});
    return this;
  }

  EposPrinterJob textStyle(EposTextStyle style) {
    _commands.add({
      'type': 'textStyle',
      'reverse': style.reverse,
      'ul': style.ul,
      'em': style.em,
      'color': style.color.name,
    });
    return this;
  }

  EposPrinterJob textSmooth(bool smooth) {
    _commands.add({'type': 'textSmooth', 'smooth': smooth});
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

  EposPrinterJob cut({EposCutType type = EposCutType.cutFeed}) {
    _commands.add({'type': 'cut', 'cutType': type.name});
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

enum EposTextFont { fontA, fontB }

class EposTextStyle {
  EposTextStyle({
    this.reverse = false,
    this.ul = false,
    this.em = false,
    this.color = EposTextColor.color1,
  });
  final bool reverse;
  final bool ul; // underline
  final bool em; // emphasis (bold)
  final EposTextColor color;

  Map<String, dynamic> toMap() {
    return {'reverse': reverse, 'ul': ul, 'em': em, 'color': color.name};
  }
}

enum EposTextColor { color1, color2, color3, color4 }

enum EposCutType {
  cutFeed,
  cutNoFeed,
  cutReserve,
  fullCutFeed,
  fullCutNoFeed,
  fullCutReserve,
}
