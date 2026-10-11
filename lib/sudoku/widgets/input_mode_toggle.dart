import 'package:flutter/material.dart';
import 'package:puzzle_arcade/sudoku/widgets/sudoku_session.dart';

class InputModeToggle extends StatelessWidget {
  const InputModeToggle({super.key, required this.inputMode, required this.onToggle});
  final InputMode inputMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container (
        decoration: BoxDecoration (
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2.0),
        ),
        child: Text (
          switch (inputMode) {
            InputMode.value => 'Notes',
            InputMode.notes => 'Write',
          },
          style: TextStyle(
            fontSize: 24.0,
            color: Colors.black,
          )
        )
      )
    );
  }
}