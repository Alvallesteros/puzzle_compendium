import 'package:flutter/material.dart';
import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_cell.dart';
import 'package:puzzle_arcade/sudoku/num_pad.dart';

class SudokuSession extends StatefulWidget {
  const SudokuSession({super.key});

  @override
  _SudokuSessionState createState() => _SudokuSessionState();
}

class _SudokuSessionState extends State<SudokuSession>{
  final SudokuPuzzle sudokuGrid = SudokuPuzzle.sample();

  (int, int)? selectedCell;
  final Map<(int, int), int> enteredValues = {};

  void _select (int row, int col) {
    setState(() {
      selectedCell = (row, col);
    });
  }

  int? _displayValueAt(int row, int col) {
    (int, int) key = (row, col);
    if (enteredValues.containsKey(key)) {
      return enteredValues[key];
    } else {
      return sudokuGrid.valueAt(row, col);
    } 
  }

  void _enterDigit(int digit) {
    if (selectedCell == null) {
      return;
    }
    final (row, col) = selectedCell!;
    if (sudokuGrid.isGiven(row, col)) {
      return;
    }
    setState(() {
      enteredValues[(row, col)] = digit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column (
      children: [
        // GRID ==============================
          Expanded ( 
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3.0),
                  ),
                  child: Column(
                    children: List.generate(9, (row) => 
                      Expanded(
                        child: Row(
                          children: List.generate(9, (col) =>
                            Expanded(
                              child: SudokuCell(
                                value: _displayValueAt(row, col), 
                                isGiven: sudokuGrid.isGiven(row, col), 
                                isSelected: selectedCell == (row, col),
                                thickRightBorder: col % 3 == 2 && col != 8,
                                thickBottomBorder: row % 3 == 2 && row != 8,
                                onTap: () => _select(row, col)
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          ),
      // NUM PAD ==============================
        NumberPad(onDigit: _enterDigit)
      ]
    );
  }
}