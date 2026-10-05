import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_difficulty.dart';
import 'package:puzzle_arcade/sudoku/sudoku_classifier.dart';

class SolverClassifiedDifficulty implements SudokuDifficulty {
  final Technique ceiling;

  const SolverClassifiedDifficulty({required this.ceiling});

  @override
  bool accepts(SudokuPuzzle puzzle) {
    final classification = SudokuClassifier.classify(puzzle);
    final hardest = classification.hardest;
    if (hardest == null) {
      return true;
    } 
    return hardest.rank <= ceiling.rank;
  }
}