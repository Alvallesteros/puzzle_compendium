import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';

int? _valueAt(SudokuPuzzle puzzle, Map<(int, int), int> enteredValues, int row, int col) {
  (int, int) key = (row, col);
  if (enteredValues.containsKey(key)) {
    return enteredValues[key];
  } else {
    return puzzle.valueAt(row, col);
  }
}

({Set<(int, int)> invalid, bool isFull}) findConflicts (
  SudokuPuzzle puzzle,
  Map<(int, int), int> enteredValues
) {
  Set<(int, int)> invalid = {};
  int? value;
  bool isFull = true; // Initialize as True

  // Iterate through Boxes
  // 9 Boxes
  Map<(int, int), Map<int, List<(int, int)>>> boxMap = {};
  Map<(int, int), Map<int, List<(int, int)>>> rowMap = {};
  Map<(int, int), Map<int, List<(int, int)>>> colMap = {};
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      (int, int) boxOrigin = (i ~/ 3 * 3, j ~/ 3 * 3);
      (int, int) rowOrigin = (i, 0);
      (int, int) colOrigin = (0, j);

      !boxMap.containsKey(boxOrigin) ? boxMap[boxOrigin] = {} : null;
      !rowMap.containsKey(rowOrigin) ? rowMap[rowOrigin] = {} : null;
      !colMap.containsKey(colOrigin) ? colMap[colOrigin] = {} : null;

      value = _valueAt(puzzle, enteredValues, i, j);
      if (value != null) {
        // in Rows?
        rowMap[rowOrigin]!.putIfAbsent(value, () => []).add((i, j));

        // in Cols?
        colMap[colOrigin]!.putIfAbsent(value, () => []).add((i, j));

        // in Box?
        boxMap[boxOrigin]!.putIfAbsent(value, () => []).add((i, j));
      } else {
        isFull = false; // False immediately when encountering a null value.
      }
    }
  }

  // ADD CELLS with INVALID ROWS
  for (final row in rowMap.values) {
    for (final cells in row.values) {
      if (cells.length > 1) {
        invalid.addAll(cells);
      }
    }
  }

  // ADD CELLS with INVALID COLS
  for (final col in colMap.values) {
    for (final cells in col.values) {
      if (cells.length > 1) {
        invalid.addAll(cells);
      }
    }
  }

  // ADD CELLS with INVALID BOXES
  for (final box in boxMap.values) {
    for (final cells in box.values) {
      if (cells.length > 1) {
        invalid.addAll(cells);
      }
    }
  }
  
  return (invalid: invalid, isFull: isFull);
}