import 'package:flutter/material.dart';
import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_cell.dart';

class SudokuBody extends StatefulWidget {
  const SudokuBody({super.key});

  @override
  _SudokuBodyState createState() => _SudokuBodyState();
}

class _SudokuBodyState extends State<SudokuBody>{
  final SudokuPuzzle sudokuGrid = SudokuPuzzle.sample();
  (int, int)? selectedCell;

  void _select (int row, int col) {
    setState(() {
      selectedCell = (row, col);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                        value: sudokuGrid.valueAt(row, col), 
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
    );
  }
}