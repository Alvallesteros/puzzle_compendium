import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_validator.dart';

void main() {
  SudokuPuzzle puzzle = SudokuPuzzle.sample(); 
  SudokuPuzzle full = SudokuPuzzle.solvedSample();
  Map<(int, int), int> enteredValues = {
    (0, 6): 7, // Row Conflict
    (6, 3): 8, // Column Conflict
    (2, 6): 3, // Given Conflict
    (2, 8): 3, // Given Conflict
    (1, 1): 3, // Box Conflict
  };

  final (:invalid, :isFull) = findConflicts(puzzle, enteredValues);
  print("ENTERED VALUES: $enteredValues");
  print("INVALIDS: $invalid");
  print("FULL?: $isFull");
  return;
}

