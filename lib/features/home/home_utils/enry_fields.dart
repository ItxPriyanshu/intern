import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/location_service.dart';

enum FieldType { text, date, time }

class SearchInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Color backgroundColor;
  final double height;
  final FieldType fieldType;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onTap;

  const SearchInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.backgroundColor = const Color(0xFFC8E6C9),
    this.height = 60,
    this.fieldType = FieldType.text,
    this.onChanged,
    this.controller,
    this.onTap,
  });

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  late TextEditingController _controller;
  bool _isExpanded = false;
  late FocusNode _focusNode;

  List<Map<String, dynamic>> suggestions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(SearchInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the controller was changed, update the listener
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onTextChanged);
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _clearField() {
    _controller.clear();
    widget.onChanged?.call('');
    setState(() {
      suggestions = [];
    });
  }

  void _handleTap() {
    if (widget.fieldType == FieldType.text) {
      setState(() {
        _isExpanded = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _focusNode.requestFocus();
      });
    } else {
      // Call the onTap callback and ensure state updates after
      widget.onTap?.call();
      // Rebuild widget to show new value
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {});
      });
    }
  }

  Future<void> _search(String query) async {
    setState(() {
      isLoading = true;
    });

    final result = await LocationService.searchCity(query);

    setState(() {
      suggestions = result;
      isLoading = false;
    });
  }

  void _selectSuggestion(Map<String, dynamic> place) {
    final name = place["display_name"];

    _controller.text = name;
    widget.onChanged?.call(name);
    
    // Unfocus the text field to close keyboard
    _focusNode.unfocus();

    setState(() {
      suggestions = [];
      _isExpanded = false;
    });
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Icon(widget.icon, color: Colors.redAccent, size: 28),
                ),
                Expanded(
                  child: _isExpanded && widget.fieldType == FieldType.text
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: (value) {
                              widget.onChanged?.call(value);
                              if (value.isNotEmpty) {
                                _search(value);
                              } else {
                                setState(() {
                                  suggestions = [];
                                });
                              }
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: widget.hint,
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.label,
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _truncateText(
                                  _controller.text.isEmpty
                                      ? widget.hint
                                      : _controller.text,
                                  25,
                                ),
                                style: GoogleFonts.poppins(
                                  color: _controller.text.isEmpty
                                      ? Colors.grey[600]
                                      : Colors.black,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clearField,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.close),
                    ),
                  )
                else
                  const SizedBox(width: 16),
              ],
            ),
          ),
        ),

        if (suggestions.isNotEmpty && _isExpanded && widget.fieldType == FieldType.text)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final place = suggestions[index];

                return ListTile(
                  title: Text(
                    place["display_name"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectSuggestion(place),
                );
              },
            ),
          ),
      ],
    );
  }
  }
