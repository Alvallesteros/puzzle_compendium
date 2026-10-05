import 'dart:math';
import 'package:puzzle_arcade/sudoku/sudoku_solver.dart';
import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_difficulty.dart';
import 'package:puzzle_arcade/sudoku/generated_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_classifier.dart';
import 'package:puzzle_arcade/sudoku/solver_classified_difficulty.dart';


class SudokuGenerator {
  const SudokuGenerator._();

  static ({GeneratedPuzzle puzzle, bool wasFallback}) generateWithRetry(int seed, Technique min, Technique max) {
    final difficulty = SolverClassifiedDifficulty(min: min, max: max);
    GeneratedPuzzle? best;
    int bestDistance = 9999999;
    for(int attempt = 0; attempt < 5; attempt++) {
      int attemptSeed = seed + attempt;
      GeneratedPuzzle attemptPuzzle = SudokuGenerator.generate(attemptSeed, difficulty);
      if(difficulty.accepts(attemptPuzzle.puzzle)) {
        return (puzzle: attemptPuzzle, wasFallback: false); 
      } 
      Technique? hardest = SudokuClassifier.classify(attemptPuzzle.puzzle).hardest;
      int distance = _distanceToRange(hardest, min, max);
      if (distance < bestDistance) {
        best = attemptPuzzle;
        bestDistance = distance;
      }
    }
    return (puzzle: best!, wasFallback: true);
  }

  static int _distanceToRange(Technique? hardest,Technique min,Technique max) {
    if(hardest == null) {
      return min.rank;
    }
    if(hardest.rank < min.rank) {
      return min.rank - hardest.rank;
    }
    if(hardest.rank > max.rank) {
      return hardest.rank - max.rank;
    }
    return 0;
  }

  static GeneratedPuzzle generate(int seed, SudokuDifficulty difficulty) {
    final List<List<int>> fill = SudokuSolver.fillFullGrid(seed);
    final List<List<int?>> working = _removeCells(fill, seed, difficulty);
    final List<List<bool>> givens = _deriveGivens(working);
    final SudokuPuzzle puzzle = SudokuPuzzle(grid: working, givens: givens);
    
    return GeneratedPuzzle(puzzle: puzzle, solution: fill);
  }

  static List<List<int?>> _removeCells(List<List<int>> fill, int seed, SudokuDifficulty difficulty) {
    List<List<int?>> workingGrid = fill.map((row) => List<int?>.from(row)).toList();
    List<List<int?>>? lastInRange;
    List<(int, int)> coordinateList = [
      for (int i = 0; i < 9; i++) 
        for (int j = 0; j < 9; j++) 
          (i, j)
    ];

    coordinateList.shuffle(Random(seed));

    for (final (row, col) in coordinateList) {
      SudokuPuzzle currentPuzzle = SudokuPuzzle(grid: workingGrid, givens: _deriveGivens(workingGrid));
      if (difficulty.accepts(currentPuzzle)) {
        lastInRange = workingGrid.map((row) => List<int?>.from(row)).toList();
      } else if (lastInRange != null) {
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

    return lastInRange ?? workingGrid;
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