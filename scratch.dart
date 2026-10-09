// tool/scratch.dart
//
// Sprint 8b — Step 11 cost measurement.
//
// Three measurements:
//   1. Classify benchmark — warmed, 100 iterations, on targets 60/45/30.
//   2. Generation benchmark — one seed per target 60/45/30.
//   3. New-tier classify cost — 100 iterations on each Step 10 fixture.
//
// Run: dart run tool/scratch.dart

import 'package:puzzle_arcade/sudoku/sudoku_classifier.dart';
import 'package:puzzle_arcade/sudoku/sudoku_generator.dart';
import 'package:puzzle_arcade/sudoku/given_count_difficulty.dart';

void main() {
  print('=== Sprint 8b — Step 11 Cost Measurement ===');
  print('');

  _measureClassifyBaseline();
  print('');
  _measureGeneration();
  print('');
  _measureNewTierFixtures();
}

// ---------------------------------------------------------------------------
// 1. Classify benchmark
// ---------------------------------------------------------------------------

void _measureClassifyBaseline() {
  print('=== 1. Classify benchmark (100 iterations, warmed) ===');
  const iterations = 100;

  for (final target in [60, 45, 30]) {
    final generated = SudokuGenerator.generate(
      42,
      GivenCountDifficulty(targetGivens: target),
    );
    final puzzle = generated.puzzle;

    // Warm-up.
    for (var i = 0; i < 5; i++) {
      SudokuClassifier.classify(puzzle);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      SudokuClassifier.classify(puzzle);
    }
    sw.stop();

    final usPerCall = sw.elapsedMicroseconds / iterations;
    print(
      '  seed=42  target=$target  '
      'total=${sw.elapsedMilliseconds}ms  '
      'perCall=${usPerCall.toStringAsFixed(0)}us',
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Generation benchmark
// ---------------------------------------------------------------------------

void _measureGeneration() {
  print('=== 2. Generation benchmark (one seed per target) ===');

  for (final target in [60, 45, 30]) {
    for (final seed in [42, 100, 7]) {
      final sw = Stopwatch()..start();
      SudokuGenerator.generate(
        seed,
        GivenCountDifficulty(targetGivens: target),
      );
      sw.stop();
      print(
        '  seed=$seed  target=$target  '
        'elapsed=${sw.elapsedMilliseconds}ms',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 3. New-tier classify cost
// ---------------------------------------------------------------------------

void _measureNewTierFixtures() {
  print('=== 3. New-tier classify cost (Step 10 fixtures) ===');
  const iterations = 100;

  // (technique name, seed, target) — from Step 10's search.
  const fixtures = [
    ('pointingPair', 71, 30),
    ('pointingTriple', 211, 25),
    ('boxLineReduction', 25, 30),
    ('xWing', 111, 30),
  ];

  for (final (name, seed, target) in fixtures) {
    final generated = SudokuGenerator.generate(
      seed,
      GivenCountDifficulty(targetGivens: target),
    );
    final puzzle = generated.puzzle;

    // Verify the fixture actually reports the expected technique.
    final sanity = SudokuClassifier.classify(puzzle).hardest;
    final sanityName = sanity?.name ?? 'null';

    // Warm-up.
    for (var i = 0; i < 5; i++) {
      SudokuClassifier.classify(puzzle);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      SudokuClassifier.classify(puzzle);
    }
    sw.stop();

    final usPerCall = sw.elapsedMicroseconds / iterations;
    print(
      '  $name  seed=$seed  target=$target  '
      'hardest=$sanityName  '
      'perCall=${usPerCall.toStringAsFixed(0)}us',
    );
  }
}