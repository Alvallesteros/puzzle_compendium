import 'package:puzzle_arcade/sudoku/sudoku_solver.dart';
import 'dart:io';

void printGrid(List<List<int?>> grid) {
  for (int row = 0; row < 9; row++) {
    for (int col = 0; col < 9; col++) {
      stdout.write('${grid[row][col] ?? '_'} ');
    }
    stdout.writeln();
  }
}

void main() {
  stdout.write("SCENARIO 1 ===================\n");
  List<List<int?>> fullGrid = SudokuSolver.fillFullGrid(42);
  printGrid(fullGrid);
  stdout.write("SCENARIO 2 ===================\n");
  fullGrid = SudokuSolver.fillFullGrid(42);
  printGrid(fullGrid);
  stdout.write("SCENARIO 3 ===================\n");
  fullGrid = SudokuSolver.fillFullGrid(43);
  printGrid(fullGrid);
  stdout.write("SCENARIO 4 ===================\n");
  int countGrid = SudokuSolver.countSolutions(SudokuSolver.fillFullGrid(42), 2);
  print(countGrid);
  stdout.write("SCENARIO 5 ===================\n");
  countGrid = SudokuSolver.countSolutions(
    List.generate(9, (_) => List<int?>.filled(9, null)),
    2,
  );
  print(countGrid);
  stdout.write("SCENARIO 6 ===================\n");
  countGrid = SudokuSolver.countSolutions(
    [
      [5, null, null, null, 5, null, null, null, null],
      ...List.generate(8, (_) => List<int?>.filled(9, null)),
    ],
    2,
  );
  print(countGrid);
  stdout.write("SCENARIO 7 ===================\n");
  final grid = SudokuSolver.fillFullGrid(42);
  final originalGrid = [
    for (final row in grid) List<int?>.from(row),
  ];
  SudokuSolver.countSolutions(grid, 2);
  final unchanged = List.generate(9, (row) => List.generate(9, (col) => grid[row][col] == originalGrid[row][col]))
      .expand((row) => row)
      .every((cell) => cell);
  print('Input unchanged: $unchanged');
}