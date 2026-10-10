// tool/scratch.dart
//
// Step 6 verification — Y-Wing, with soundness.
//
// Part A: structural — Y-Wing fires on seed 2, records eliminations
//         with null coords, classifies deterministically.
//
// Part B: soundness — for a set of Y-Wing-hardest fixtures, capture
//         every Y-Wing elimination via the debug hook, and check
//         that the removed digit is NOT the solution value at the
//         removed cell. Zero violations = sound on this fixture set.

import 'package:puzzle_arcade/sudoku/given_count_difficulty.dart';
import 'package:puzzle_arcade/sudoku/generated_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_classifier.dart';
import 'package:puzzle_arcade/sudoku/sudoku_generator.dart';

void main() {
  print('=============================================');
  print('Step 6 verification — Y-Wing');
  print('=============================================');
  print('');
  _partA(seed: 2, target: 25);
  print('');
  _partB(target: 25, seeds: _fixtureSeeds);
}

const List<int> _fixtureSeeds = [
  2, 6, 9, 30, 71, 105, 128, 133, 158, 171,
  195, 204, 210, 238, 241, 268, 297, 298, 304, 308,
];

// ---------------------------------------------------------------- Part A

void _partA({required int seed, required int target}) {
  print('--- Part A: Structural (seed $seed, target $target) ---');
  print('');

  final generated = SudokuGenerator.generate(
    seed,
    GivenCountDifficulty(targetGivens: target),
  );

  SudokuClassifier.debugCapture = [];
  final r1 = SudokuClassifier.classify(generated.puzzle);
  final captures1 = List<ClassifierElimination>.from(
    SudokuClassifier.debugCapture!,
  );
  SudokuClassifier.debugCapture = null;

  final r2 = SudokuClassifier.classify(generated.puzzle);

  int yWingInPath = 0;
  bool allNullCoords = true;
  for (final app in r1.path) {
    if (app.technique == Technique.yWing) {
      yWingInPath++;
      if (app.row != null || app.col != null) allNullCoords = false;
    }
  }
  final yWingCaptured =
      captures1.where((e) => e.technique == Technique.yWing).length;

  final deterministic = r1.path.length == r2.path.length &&
      r1.hardest == r2.hardest &&
      r1.solved == r2.solved;

  print('solved:                       ${r1.solved}');
  print('hardest:                      ${r1.hardest?.name} '
        '(rank ${r1.hardest?.rank})');
  print('pathLen:                      ${r1.path.length}');
  print('yWing entries in path:        $yWingInPath');
  print('yWing entries captured:       $yWingCaptured');
  print('all yWing coords null:        $allNullCoords');
  print('deterministic:                $deterministic');
  print('');
  print('path:');
  for (final app in r1.path) {
    final coord = app.row != null ? '(${app.row},${app.col})' : 'elimination';
    print('  ${app.technique.name.padRight(20)} $coord');
  }

  print('');
  final pass = r1.hardest == Technique.yWing &&
      yWingInPath > 0 &&
      yWingCaptured == yWingInPath &&
      allNullCoords &&
      deterministic;
  print(pass ? 'Part A: PASS' : 'Part A: FAIL');
}

// ---------------------------------------------------------------- Part B

void _partB({required int target, required List<int> seeds}) {
  print('--- Part B: Soundness (${seeds.length} fixtures, target $target) ---');
  print('');

  int fixturesWithYWing = 0;
  int totalEliminations = 0;
  int violations = 0;
  int? firstViolationSeed;
  int? firstViolationRow;
  int? firstViolationCol;
  int? firstViolationDigit;

  final sw = Stopwatch()..start();

  for (final seed in seeds) {
    final generated = SudokuGenerator.generate(
      seed,
      GivenCountDifficulty(targetGivens: target),
    );
    final solution = generated.solution;

    SudokuClassifier.debugCapture = [];
    SudokuClassifier.classify(generated.puzzle);
    final captures = List<ClassifierElimination>.from(
      SudokuClassifier.debugCapture!,
    );
    SudokuClassifier.debugCapture = null;

    final yWingCaptures =
        captures.where((e) => e.technique == Technique.yWing).toList();

    if (yWingCaptures.isNotEmpty) fixturesWithYWing++;

    for (final e in yWingCaptures) {
      totalEliminations++;
      final solutionValue = solution[e.row][e.col];
      if (solutionValue == e.digit) {
        violations++;
        if (firstViolationSeed == null) {
          firstViolationSeed = seed;
          firstViolationRow = e.row;
          firstViolationCol = e.col;
          firstViolationDigit = e.digit;
        }
      }
    }
  }

  sw.stop();

  print('fixtures scanned:             ${seeds.length}');
  print('fixtures with Y-Wing fires:   $fixturesWithYWing');
  print('total Y-Wing eliminations:    $totalEliminations');
  print('soundness violations:         $violations');
  print('elapsed:                      ${sw.elapsedMilliseconds} ms');
  if (violations > 0) {
    print('');
    print('First violation:');
    print('  seed:    $firstViolationSeed');
    print('  cell:    ($firstViolationRow, $firstViolationCol)');
    print('  digit:   $firstViolationDigit (this IS the solution value)');
  }

  print('');
  if (violations == 0 && totalEliminations > 0) {
    print('Part B: PASS — $totalEliminations eliminations, 0 violations');
  } else if (totalEliminations == 0) {
    print('Part B: INCONCLUSIVE — no Y-Wing eliminations captured. '
          'Debug hook likely not wired.');
  } else {
    print('Part B: FAIL — $violations soundness violations');
  }
}