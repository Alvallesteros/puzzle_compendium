// tool/scratch.dart
import 'package:puzzle_arcade/sudoku/given_count_difficulty.dart';
import 'package:puzzle_arcade/sudoku/generated_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_classifier.dart';
import 'package:puzzle_arcade/sudoku/sudoku_generator.dart';
import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';

int _countGivens(SudokuPuzzle puzzle) {
  int count = 0;
  for (final row in puzzle.givens) {
    for (final g in row) {
      if (g) count++;
    }
  }
  return count;
}

void main() {
  const seeds = [42, 71, 100];
  const targets = [79, 60, 45, 30];

  print('seed | target | givens | solved | hardest       | rank | pathLen');
  print('-----+--------+--------+--------+---------------+------+--------');

  for (final seed in seeds) {
    for (final target in targets) {
      final difficulty = GivenCountDifficulty(targetGivens: target);
      final GeneratedPuzzle generated =
          SudokuGenerator.generate(seed, difficulty);
      final SudokuPuzzle puzzle = generated.puzzle;

      final SudokuClassification classification =
          SudokuClassifier.classify(puzzle);

      final int givens = _countGivens(puzzle);
      final String hardestName = classification.hardest?.name ?? 'null';
      final int rank = classification.hardest?.rank ?? 0;
      final int pathLen = classification.path.length;

      print(
        '$seed | $target | $givens | ${classification.solved} | '
        '$hardestName | $rank | $pathLen',
      );
    }
  }
}