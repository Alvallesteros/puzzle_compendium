import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';

abstract interface class SudokuDifficulty {
  bool accepts(SudokuPuzzle puzzle);
}