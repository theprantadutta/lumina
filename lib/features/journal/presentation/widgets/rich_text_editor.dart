import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';

class RichTextEditor extends StatefulWidget {
  final String? initialContent;
  final Function(String content) onContentChanged;
  final String? hint;
  final bool isReadOnly;
  final FocusNode? focusNode;

  const RichTextEditor({
    super.key,
    this.initialContent,
    required this.onContentChanged,
    this.hint,
    this.isReadOnly = false,
    this.focusNode,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late QuillController _controller;
  late FocusNode _focusNode;
  bool _isToolbarVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    
    // Initialize controller with content
    Document doc;
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      doc = Document()..insert(0, widget.initialContent!);
    } else {
      doc = Document();
    }
    
    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Listen to text changes
    _controller.addListener(_onTextChanged);
    
    // Listen to focus changes
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final content = _controller.document.toPlainText();
    widget.onContentChanged(content);
  }

  void _onFocusChanged() {
    setState(() {
      _isToolbarVisible = _focusNode.hasFocus && !widget.isReadOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isToolbarVisible ? 60 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isToolbarVisible ? 1.0 : 0.0,
            child: _isToolbarVisible ? _buildToolbar() : const SizedBox.shrink(),
          ),
        ),
        
        // Editor
        Expanded(
          child: GlassMorphismCard(
            padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
              controller: _controller,
              focusNode: _focusNode,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return GlassMorphismCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: QuillSimpleToolbar(
        controller: _controller,
      ),
    );
  }
}

// Simplified editor widget for basic use cases
class SimpleTextEditor extends StatefulWidget {
  final String? initialContent;
  final Function(String content) onContentChanged;
  final String? hint;
  final bool isReadOnly;
  final FocusNode? focusNode;

  const SimpleTextEditor({
    super.key,
    this.initialContent,
    required this.onContentChanged,
    this.hint,
    this.isReadOnly = false,
    this.focusNode,
  });

  @override
  State<SimpleTextEditor> createState() => _SimpleTextEditorState();
}

class _SimpleTextEditorState extends State<SimpleTextEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    widget.onContentChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        readOnly: widget.isReadOnly,
        decoration: InputDecoration(
          hintText: widget.hint ?? 'Start writing your thoughts...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 16,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        cursorColor: Colors.white,
      ),
    );
  }
}