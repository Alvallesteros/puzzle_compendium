import 'dart:math';

class SudokuSolver {
  const SudokuSolver._();
  static const int _gridSize = 9;
  static const int _boxSize = 3;

  static List<List<int>> fillFullGrid(int seed) {
    List<List<int?>> grid = _emptyGrid();
    final (rows: usedRows, cols: usedCols, boxes: usedBoxes) = _emptyUsageSets();
    Random random = Random(seed);

    bool success = _fill(grid, usedRows, usedCols, usedBoxes, random);

    if (!success) {
      throw StateError("Unable to generate a complete Sudoku grid.");
    }

    return grid.map((row) => List<int>.from(row)).toList();
  }


  static int countSolutions(List<List<int?>> grid, int limit) {
    final usageSets = _tryUsageSetsFromGrid(grid);
    if (usageSets == null) {
      return 0;
    }

    final workGrid = _copyGrid(grid);
    final found = _SolutionCounter();

    _count(
      workGrid,
      usageSets.rows,
      usageSets.cols,
      usageSets.boxes,
      limit,
      found,
    );

    return found.value;
  }

  static List<List<int?>>_emptyGrid() {
    return List.generate(
      _gridSize,
      (_) => List<int?>.filled(_gridSize, null),
    );
  }

  static ({List<Set<int>> rows, List<Set<int>> cols, List<Set<int>> boxes}) _emptyUsageSets() {
    return (
      rows: List.generate(_gridSize, (_) => <int>{}),
      cols: List.generate(_gridSize, (_) => <int>{}),
      boxes: List.generate(_gridSize, (_) => <int>{}),
    );
  }

  static ({List<Set<int>> rows, List<Set<int>> cols, List<Set<int>> boxes})?
      _tryUsageSetsFromGrid(List<List<int?>> grid) {
    final usageSets = _emptyUsageSets();

    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        final value = grid[row][col];
        if (value == null) continue;

        final box = _boxIndex(row, col);
        if (usageSets.rows[row].contains(value) ||
            usageSets.cols[col].contains(value) ||
            usageSets.boxes[box].contains(value)) {
          return null;
        }

        usageSets.rows[row].add(value);
        usageSets.cols[col].add(value);
        usageSets.boxes[box].add(value);
      }
    }

    return usageSets;
  }

  static _place(
    List<List<int?>> grid,
    List<Set<int>> usedRows,
    List<Set<int>> usedCols,
    List<Set<int>> usedBoxes,
    int row, int col, int digit
  ) {
    grid[row][col] = digit;
    usedRows[row].add(digit);
    usedCols[col].add(digit);
    usedBoxes[_boxIndex(row, col)].add(digit);
  }

  static _undo(
    List<List<int?>> grid,
    List<Set<int>> usedRows,
    List<Set<int>> usedCols,
    List<Set<int>> usedBoxes,
    int row, int col, int digit    
  ) {
    grid[row][col] = null;
    usedRows[row].remove(digit);
    usedCols[col].remove(digit);
    usedBoxes[_boxIndex(row,col)].remove(digit);
  }

  static bool _isLegal(
    List<Set<int>> usedRows,
    List<Set<int>> usedCols,
    List<Set<int>> usedBoxes,
    int row, int col, int digit
  ) {
    if (!usedRows[row].contains(digit) && !usedCols[col].contains(digit) && !usedBoxes[_boxIndex(row,col)].contains(digit)) {
      return true;
    }
    return false;
  }

  static List<int> _shuffledCandidates(Random random) {
    List<int> candidates = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    candidates.shuffle(random);
    return candidates; 
  }

  static (int, int)? _findNextEmpty(List<List<int?>> grid) {
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (grid[row][col] == null) {
          return (row, col);
        }
      }
    }
    return null;
  }  

  static List<List<int?>> _copyGrid(List<List<int?>> grid) {
    return grid.map((row) => List<int?>.from(row)).toList();
  }

  static int _boxIndex(int row, int col) {
    return (row ~/ _boxSize * _boxSize) + (col ~/ _boxSize);
  }

  static bool _fill(
    List<List<int?>> grid,
    List<Set<int>> usedRows,
    List<Set<int>> usedCols,
    List<Set<int>> usedBoxes,
    Random random
  ) {
    final (int, int)? cell = _findNextEmpty(grid);
    if (cell == null) {
      return true;
    }

    final (int row, int col) = cell;
    List<int> candidates = _shuffledCandidates(random);

    for (int digit in candidates) {
      if (_isLegal(usedRows, usedCols, usedBoxes, row, col, digit)) {
        _place(grid, usedRows, usedCols, usedBoxes, row, col, digit);
        if (_fill(grid, usedRows, usedCols, usedBoxes, random)) {
          return true;
        } else {
          _undo(grid, usedRows, usedCols, usedBoxes, row, col, digit);
        }
      }
    }

    return false; 
  }

  static void _count(
    List<List<int?>> grid,
    List<Set<int>> usedRows,
    List<Set<int>> usedCols,
    List<Set<int>> usedBoxes,
    int limit,
    _SolutionCounter found
   ) {
    final (int, int)? cell = _findNextEmpty(grid);
  
    if (cell == null) {
      found.value += 1;
      return;
    }

    final (int row, int col) = cell;

    for (int digit = 1; digit <= 9; digit++) {
      if (_isLegal(usedRows, usedCols, usedBoxes, row, col, digit)) {
        _place(grid, usedRows, usedCols, usedBoxes, row, col, digit);
        _count(grid, usedRows, usedCols, usedBoxes, limit, found);
        _undo(grid, usedRows, usedCols, usedBoxes, row, col, digit);
        if (found.value >= limit) {
          return;
        }
      }
    }
    return; 
  }
}

class _SolutionCounter {
  int value;

  _SolutionCounter() : value = 0;
}