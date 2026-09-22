import 'package:flutter/material.dart';

class SudokuCell extends StatelessWidget {
  SudokuCell({
    super.key, 
    required this.value, 
    required this.isGiven, 
    required this.isSelected, 
    required this.onTap, 
    this.thickRightBorder = false, 
    this.thickBottomBorder = false});

  final int? value;
  final bool isGiven;
  final bool isSelected;
  final VoidCallback onTap;
  final bool thickRightBorder;
  final bool thickBottomBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent: Colors.white,
          border: Border(
            right: BorderSide(color: Colors.black, width: thickRightBorder ? 3.0 : 1.0),
            bottom: BorderSide(color: Colors.black, width: thickBottomBorder ? 3.0 : 1.0),
          )
        ),
        child: Center(
          child: Text(
            value?.toString() ?? '',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: isGiven ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            )
          )
        )
      )
    );
  }
}