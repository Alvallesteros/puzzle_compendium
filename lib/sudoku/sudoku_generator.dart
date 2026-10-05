import 'dart:math';
import 'package:puzzle_arcade/sudoku/sudoku_solver.dart';
import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_difficulty.dart';
import 'package:puzzle_arcade/sudoku/generated_puzzle.dart';


class SudokuGenerator {
  const SudokuGenerator._();

  static GeneratedPuzzle generate(int seed, SudokuDifficulty difficulty) {
    final List<List<int>> fill = SudokuSolver.fillFullGrid(seed);
    final List<List<int?>> working = _removeCells(fill, seed, difficulty);
    final List<List<bool>> givens = _deriveGivens(working);
    final SudokuPuzzle puzzle = SudokuPuzzle(grid: working, givens: givens);
    
    return GeneratedPuzzle(puzzle: puzzle, solution: fill);
  }


  static List<List<int?>> _removeCells(List<List<int>> fill, int seed, SudokuDifficulty difficulty) {
    List<List<int?>> workingGrid = fill.map((row) => List<int?>.from(row)).toList();
    List<(int, int)> coordinateList = [
      for (int i = 0; i < 9; i++) 
        for (int j = 0; j < 9; j++) 
          (i, j)
    ];

    coordinateList.shuffle(Random(seed));

    for (final (row, col) in coordinateList) {
      SudokuPuzzle currentPuzzle = SudokuPuzzle(grid: workingGrid, givens: _deriveGivens(workingGrid));
      if (difficulty.accepts(currentPuzzle)) {
        break;
      }

      int? save = workingGrid[row][col];
      workingGrid[row][col] = null;
      if (SudokuSolver.countSolutions(workingGrid, 2) == 1) {
        continue;
      } else {
        workingGrid[row][col] = save;
      }
    }

    return workingGrid;
  }

  static List<List<bool>> _deriveGivens(List<List<int?>> workingGrid) {
    return [
      for (int i = 0; i < 9; i++) [
        for (int j = 0; j < 9; j++)
          workingGrid[i][j] != null
      ]
    ];
  }
}