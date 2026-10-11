import 'package:epos/epos.dart';
import 'package:flutter/material.dart';

import 'receipt_block.dart';

class ReceiptEditorScreen extends StatefulWidget {
  const ReceiptEditorScreen({super.key, required this.printer});

  final EposPrinter printer;

  @override
  State<ReceiptEditorScreen> createState() => _ReceiptEditorScreenState();
}

class _ReceiptEditorScreenState extends State<ReceiptEditorScreen> {
  final List<ReceiptBlock> _blocks = [];

  void _addTextBlock() {
    setState(() {
      _blocks.add(ReceiptTextBlock());
    });
  }

  void _removeBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
    });
  }

  Future<void> _print() async {
    final job = widget.printer.createPrintJob(textLang: EposTextLanguage.ja);

    for (final block in _blocks) {
      if (block is ReceiptTextBlock) {
        job
          ..textAlign(block.alignment)
          ..textSize(block.fontSize.value, block.fontSize.value)
          ..text(block.text);
      }
    }
    job.cut(type: EposCutType.fullCutFeed);

    await widget.printer.print(job);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Receipt'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addTextBlock),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _blocks.length,
              itemBuilder: (context, index) {
                final block = _blocks[index];
                if (block is ReceiptTextBlock) {
                  return _buildTextBlock(block, index);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _blocks.isEmpty ? null : () async => await _print(),
                icon: const Icon(Icons.print),
                label: const Text('Print Receipt'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBlock(ReceiptTextBlock block, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Text"),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeBlock(index),
                ),
              ],
            ),
            TextFormField(
              initialValue: block.text,
              decoration: const InputDecoration(
                hintText: 'Enter text',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  block.text = value;
                });
              },
            ),
            const SizedBox(height: 8),
            SegmentedButton<EposTextAlign>(
              segments: EposTextAlign.values.map((alignment) {
                return ButtonSegment<EposTextAlign>(
                  value: alignment,
                  label: Text(alignment.name),
                );
              }).toList(),
              selected: <EposTextAlign>{block.alignment},
              onSelectionChanged: (newSelection) {
                setState(() {
                  block.alignment = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ReceiptFontSize>(
              initialValue: block.fontSize,
              items: ReceiptFontSize.values.map((fontSize) {
                return DropdownMenuItem(
                  value: fontSize,
                  child: Text(fontSize.name),
                );
              }).toList(),
              onChanged: (newFontSize) {
                if (newFontSize == null) return;
                setState(() {
                  block.fontSize = newFontSize;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
