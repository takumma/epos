import 'dart:typed_data';

import 'package:epos/epos.dart';

enum ReceiptAlignment { left, center, right }

enum ReceiptFontSize(final int value) {
  small(16),
  normal(24),
  large(48),
}

sealed class ReceiptBlock {}

class ReceiptTextBlock extends ReceiptBlock {
  String text;
  EposTextAlign alignment;
  ReceiptFontSize fontSize;

  ReceiptTextBlock({
    this.text = '',
    this.alignment = EposTextAlign.left,
    this.fontSize = ReceiptFontSize.normal,
  });
}

class ReceiptImageBlock extends ReceiptBlock {
  Uint8List bytes;
  ReceiptAlignment alignment;

  ReceiptImageBlock({
    required this.bytes,
    this.alignment = ReceiptAlignment.center,
  });
}
