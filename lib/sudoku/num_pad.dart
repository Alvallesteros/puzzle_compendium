import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key, required this.onDigit});

  final void Function(int) onDigit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(9, (i) =>
        Expanded(
          child: GestureDetector(
            onTap: () => onDigit(i+1),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 2.0, color: Colors.black)
              ),
              child: Center(
                child: Text(
                  (i+1).toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 32.0,
                  )
                ),
              )
            )
          ) 
        )
      )
    );
  }
}