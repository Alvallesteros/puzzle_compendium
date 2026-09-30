import 'dart:io';
import 'package:puzzle_arcade/sudoku/sudoku_generator.dart';
import 'package:puzzle_arcade/sudoku/sudoku_difficulty.dart';
import 'package:puzzle_arcade/sudoku/sudoku_solver.dart';


// THROWAWAY TESTING FUNCTIONS
void printGrid(List<List<int?>> grid) {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      stdout.write('${grid[i][j] ?? '_'} ');
    }
    stdout.writeln();
  }
}

bool deepEqual(List<List<int?>> a, List<List<int?>> b) {
  if (a.length != 9 || b.length != 9) return false;

  for (int row = 0; row < 9; row++) {
    if (a[row].length != 9 || b[row].length != 9) return false;
    for (int column = 0; column < 9; column++) {
      if (a[row][column] != b[row][column]) return false;
    }
  }
  return true;
}

void printPassFail(String check, bool passed) {
  stdout.writeln('$check: ${passed ? 'PASS' : 'FAIL'}');
}

void main () {
  const difficulty = SudokuDifficulty(targetGivens: 60);
  int passed = 0;

  final first = SudokuGenerator.generate(42, difficulty);
  final second = SudokuGenerator.generate(42, difficulty);
  final reproducible = deepEqual(first.puzzle.grid, second.puzzle.grid) &&
      deepEqual(first.solution, second.solution);
  printPassFail('CHECK 1 - REPRODUCIBILITY', reproducible);
  if (reproducible) passed++;

  final third = SudokuGenerator.generate(43, difficulty);
  final seedsDiffer = !deepEqual(first.puzzle.grid, third.puzzle.grid);
  if (seedsDiffer) {
    printPassFail('CHECK 2 - SEED VARIATION', true);
    passed++;
  } else {
    stdout.writeln('CHECK 2 - SEED VARIATION: NOTE (grids are identical)');
  }

  final unique = SudokuSolver.countSolutions(first.puzzle.grid, 2) == 1;
  printPassFail('CHECK 3 - UNIQUENESS', unique);
  if (unique) passed++;

  bool givensMatch = true;
  for (int row = 0; row < 9; row++) {
    for (int column = 0; column < 9; column++) {
      final given = first.puzzle.grid[row][column];
      if (given != null && given != first.solution[row][column]) {
        givensMatch = false;
      }
    }
  }
  printPassFail('CHECK 4 - GIVENS MATCH SOLUTION', givensMatch);
  if (givensMatch) passed++;

  int givens = 0;
  for (final row in first.puzzle.grid) {
    for (final cell in row) {
      if (cell != null) givens++;
    }
  }
  final withinTarget = givens <= 60;
  printPassFail('CHECK 5 - GIVENS COUNT (actual: $givens)', withinTarget);
  if (withinTarget) passed++;

  stdout.writeln('$passed of 5 checks passed.');

  stdout.writeln('\nMeasurements:');
  for (final target in [60, 45, 30, 22]) {
    final stopwatch = Stopwatch()..start();
    final result = SudokuGenerator.generate(
      42,
      SudokuDifficulty(targetGivens: target),
    );
    stopwatch.stop();

    int actualGivens = 0;
    for (final row in result.puzzle.grid) {
      for (final cell in row) {
        if (cell != null) actualGivens++;
      }
    }

    stdout.writeln(
      'target: $target, actual givens: $actualGivens, elapsed ms: ${stopwatch.elapsedMilliseconds}',
    );
  }

  if (passed != 5) exitCode = 1;
}