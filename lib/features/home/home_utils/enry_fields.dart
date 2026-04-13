import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/location_service.dart';

enum FieldType { text, date, time }

class SearchInputField extends StatefulWidget {
  final String? label;
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
     this.label,
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
  late FocusNode _focusNode;

  List<Map<String, dynamic>> suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }
    final result = await LocationService.searchCity(query);
    setState(() {
      suggestions = result;
    });
  }
  
void _selectSuggestion(Map<String, dynamic> place) {
  final lat = place["lat"];
  final lon = place["lon"];

  final value = "$lat,$lon"; 

  _controller.text = place["display_name"] ?? '';

  widget.onChanged?.call(value);

  _focusNode.unfocus();

  setState(() {
    suggestions = [];
  });
}
  void _clearField() {
    _controller.clear();
    widget.onChanged?.call('');
    setState(() {
      suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    readOnly: widget.fieldType != FieldType.text,
                    onTap: () {
                      if (widget.fieldType != FieldType.text) {
                        widget.onTap?.call();
                      } else {
                        _focusNode.requestFocus();
                      }
                    },
                    onChanged: (value) {
                      if (widget.fieldType == FieldType.text) {
                        widget.onChanged?.call(value);
                        _search(value);
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
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ),
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
        if (suggestions.isNotEmpty && widget.fieldType == FieldType.text)
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
                    place["display_name"] ?? '',
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