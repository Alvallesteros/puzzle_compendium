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

  static SudokuPuzzle solvedSample() {
    return SudokuPuzzle(
      grid: [
        [5, 3, 4, 6, 7, 8, 9, 1, null],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
      ],
      givens: List.generate(
        9,
        (row) => List.generate(
          9,
          (col) => !(row == 0 && col == 8),
        ),
      ),
    );
  } 
}