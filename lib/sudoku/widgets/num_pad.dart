import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key, required this.onDigit, required this.onErase});

  final void Function(int) onDigit;
  final void Function() onErase;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(10, (i) =>
        Expanded(
          child: GestureDetector(
            onTap: i != 9 ? () => onDigit(i+1) : onErase,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 2.0, color: Colors.black)
              ),
              child: Center(
                child: i != 9 
                ? Text(
                  (i+1).toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 32.0,
                  )
                )
                : Icon (
                  Icons.backspace,
                  color: Colors.black,
                  size: 32,
                )
              )
            )
          ) 
        )
      )
    );
  }
}