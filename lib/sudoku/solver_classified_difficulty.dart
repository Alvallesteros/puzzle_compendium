import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_difficulty.dart';
import 'package:puzzle_arcade/sudoku/sudoku_classifier.dart';

class SolverClassifiedDifficulty implements SudokuDifficulty {
  final Technique min;
  final Technique max;

  const SolverClassifiedDifficulty({required this.min, required this.max});

  @override
  bool accepts(SudokuPuzzle puzzle) {
    final classification = SudokuClassifier.classify(puzzle);
    final hardest = classification.hardest;
    if (hardest == null) {
      return false;
    } 
    return hardest.rank >= min.rank && hardest.rank <= max.rank;
  }
}