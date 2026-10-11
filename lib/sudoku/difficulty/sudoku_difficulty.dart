import 'package:puzzle_arcade/sudoku/model/sudoku_puzzle.dart';

abstract interface class SudokuDifficulty {
  bool accepts(SudokuPuzzle puzzle);
}