class SudokuPuzzle {
  SudokuPuzzle({ 
    required this.grid,
    required this.givens,
  });

  final List<List<int?>> grid;
  final List<List<bool>> givens;

  int? valueAt(int row, int col) => grid[row][col];
  bool isGiven(int row, int col) => givens[row][col];

  static SudokuPuzzle sample() {
    return SudokuPuzzle(
      grid: [
        [5, 3, null, null, 7, null, null, null, null],
        [6, null, null, 1, 9, 5, null, null, null],
        [null, 9, 8, null, null, null, null, 6, null],
        [8, null, null, null, 6, null, null, null, 3],
        [4, null, null, 8, null, 3, null, null, 1],
        [7, null, null, null, 2, null, null, null, 6],
        [null, 6, null, null, null, null, 2, 8, null],
        [null, null, null, 4, 1, 9, null, null, 5],
        [null,null,null,null,null,null,null,null,null]
      ],
      givens: [
        [true,true,false,false,true,false,false,false,false],
        [true,false,false,true,true,true,false,false,false],
        [false,true,true,false,false,false,false,true,false],
        [true,false,false,false,true,false,false,false,true],
        [true,false,false,true,false,true,false,false,true],
        [true,false,false,false,true,false,false,false,true],
        [false,true,false,false,false,false,true,true,false],
        [false,false,false,true,true,true,false,false,true],
        [false,false,false,false,false,false,false,false,false]
      ]
    );
  }

  static SudokuPuzzle empty() {
    return SudokuPuzzle(
      grid: List.generate(9, (_) => List.generate(9, (_) => null)),
      givens: List.generate(9, (_) => List.generate(9, (_) => false)),
    );
  }
}