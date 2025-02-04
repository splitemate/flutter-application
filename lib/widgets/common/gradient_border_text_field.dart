import 'package:flutter/material.dart';
import 'package:gradient_borders/input_borders/gradient_outline_input_border.dart';
import 'package:splitemate/colors.dart';

class GradientBorderTextField extends StatefulWidget {
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChange;
  final TextEditingController? controller;

  const GradientBorderTextField({
    super.key,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChange,
  });

  @override
  GradientBorderTextFieldState createState() => GradientBorderTextFieldState();
}

class GradientBorderTextFieldState extends State<GradientBorderTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.width * 0.02105),
        TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.keyboardType == TextInputType.visiblePassword,
          validator: widget.validator,
          onChanged: widget.onChange,
          decoration: InputDecoration(
            labelText: widget.labelText,
            filled: true,
            fillColor: kStockColor,
            border: _isFocused
                ? GradientOutlineInputBorder(
                    gradient: const LinearGradient(colors: kGradColors),
                    width: 1,
                    gapPadding: 0.5,
                    borderRadius:
                        BorderRadius.all(Radius.circular(size.width * 0.0316)))
                : OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.all(Radius.circular(size.width * 0.0316)),
                  ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: size.width * 0.0333, vertical: size.width * 0.0333),
          ),
        ),
      ],
    );
  }
}
