class SudokuPuzzle {
  SudokuPuzzle({ 
    required this.grid,
    required this.givens,
  });

  final List<List<int?>> grid;
  final List<List<bool>> givens;

  int? valueAt(int row, int col) => grid[row][col];
  bool isGiven(int row, int col) => givens[row][col];

}