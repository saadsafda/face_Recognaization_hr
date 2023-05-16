import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/theme.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';

class TextFieldCircular extends StatefulWidget {
  final controller;
  final String hintText;
  Color color;
  int maxLines;
  bool enabled;
  TextFieldCircular(
      {Key? key,
      this.controller,
      required this.hintText,
      required this.color,
      this.maxLines = 1,
      this.enabled = true})
      : super(key: key);

  @override
  _TextFieldCircularState createState() => _TextFieldCircularState();
}

class _TextFieldCircularState extends State<TextFieldCircular> {


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        onSaved: (value) {
          setState(() {
            widget.controller.text = value;
          });
        },
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: heading6.copyWith(color: AppColors.textGrey),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
    ;
  }
}