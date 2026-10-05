import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_difficulty.dart';

class GivenCountDifficulty implements SudokuDifficulty {
  final int targetGivens;

  const GivenCountDifficulty({ required this.targetGivens });
  
  @override
  bool accepts(SudokuPuzzle puzzle) {
    return _countGivens(puzzle) <= targetGivens;
  }

  int _countGivens(SudokuPuzzle puzzle) {
    int trueCount = 0;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if(puzzle.givens[row][col]) {
          trueCount++;
        }
      }
    }
    return trueCount;
  }
}