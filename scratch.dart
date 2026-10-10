// tool/scratch.dart
import 'package:puzzle_arcade/sudoku/given_count_difficulty.dart';
import 'package:puzzle_arcade/sudoku/generated_puzzle.dart';
import 'package:puzzle_arcade/sudoku/sudoku_classifier.dart';
import 'package:puzzle_arcade/sudoku/sudoku_generator.dart';

const int kPuzzleCount = 1000;
const int kTarget = 25;

const List<Technique> kCheckSoundness = [
  Technique.swordfish,
  Technique.yWing,
  Technique.singlesChain,
  Technique.uniqueRectangle,
];

void main() {
  final occurrences = <Technique, int>{for (final t in Technique.values) t: 0};
  final hardest = <Technique, int>{for (final t in Technique.values) t: 0};
  final seedsByTechnique = <Technique, List<int>>{
    for (final t in Technique.values) t: [],
  };
  int solved = 0;

  final sw = Stopwatch()..start();

  for (int seed = 0; seed < kPuzzleCount; seed++) {
    final generated = SudokuGenerator.generate(
      seed,
      GivenCountDifficulty(targetGivens: kTarget),
    );
    final r = SudokuClassifier.classify(generated.puzzle);

    if (r.solved) solved++;
    for (final app in r.path) {
      occurrences[app.technique] = occurrences[app.technique]! + 1;
    }
    final h = r.hardest;
    if (h != null) {
      hardest[h] = hardest[h]! + 1;
      seedsByTechnique[h]!.add(seed);
    }

    if ((seed + 1) % 250 == 0) {
      print('  ... ${seed + 1} / $kPuzzleCount  '
            '(${sw.elapsedMilliseconds} ms)');
    }
  }

  sw.stop();

  print('');
  print('=== Sweep complete ===');
  print('solved:  $solved / $kPuzzleCount  '
        '(${(solved / kPuzzleCount * 100).toStringAsFixed(2)}%)');
  print('elapsed: ${sw.elapsedMilliseconds} ms');

  _table('Occurrences', occurrences, kPuzzleCount);
  _table('Hardest', hardest, kPuzzleCount);

  print('');
  print('=== Fixture seeds ===');
  for (final t in [Technique.nakedQuad, Technique.hiddenQuad, ...kCheckSoundness]) {
    final seeds = seedsByTechnique[t]!;
    print('  ${t.name.padRight(20)} ${seeds.length}  '
          '${seeds.take(20).join(', ')}${seeds.length > 20 ? ', ...' : ''}');
  }

  // ---- Batch soundness across 8c techniques ----
  print('');
  print('=== Soundness check ===');
  int totalChecked = 0;
  int totalViolations = 0;
  final sw2 = Stopwatch()..start();

  for (final technique in kCheckSoundness) {
    final seeds = seedsByTechnique[technique]!;
    int techChecked = 0;
    int techViolations = 0;
    for (final seed in seeds) {
      final generated = SudokuGenerator.generate(
        seed,
        GivenCountDifficulty(targetGivens: kTarget),
      );
      final solution = generated.solution;
      SudokuClassifier.debugCapture = [];
      SudokuClassifier.classify(generated.puzzle);
      final captures = List<ClassifierElimination>.from(
        SudokuClassifier.debugCapture!,
      );
      SudokuClassifier.debugCapture = null;
      for (final e in captures) {
        if (e.technique != technique) continue;
        techChecked++;
        if (solution[e.row][e.col] == e.digit) techViolations++;
      }
    }
    totalChecked += techChecked;
    totalViolations += techViolations;
    print('  ${technique.name.padRight(20)} '
          '$techChecked eliminations, $techViolations violations');
  }

  sw2.stop();

  print('');
  print('total eliminations checked: $totalChecked');
  print('total violations:           $totalViolations');
  print('elapsed:                    ${sw2.elapsedMilliseconds} ms');
  print('');
  print(totalViolations == 0
      ? 'PASS — $totalChecked eliminations, 0 violations'
      : 'FAIL — $totalViolations violations');
}

void _table(String title, Map<Technique, int> counts, int total) {
  print('');
  print('--- $title ---');
  final entries = counts.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  print('  ${'technique'.padRight(20)}'
        '${'count'.padLeft(10)}'
        '${'pct'.padLeft(12)}');
  print('  ${'-' * 20}${'-' * 10}${'-' * 12}');
  for (final e in entries) {
    final pct = e.value / total * 100;
    print('  ${e.key.name.padRight(20)}'
          '${e.value.toString().padLeft(10)}'
          '${'${pct.toStringAsFixed(4)}%'.padLeft(12)}');
  }
}