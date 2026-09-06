import 'package:flutter/material.dart';

enum PuzzleType {
  Sudoku,
  Shikaku,
  Queens,
}


class PuzzleDefinition {
  final PuzzleType identity;
  final String displayName;
  final String descriptor;
  final Color color;

  PuzzleDefinition({
    required this.identity,
    required this.displayName,
    required this.descriptor,
    required this.color,
  });
}

final PuzzleDefinition sudokuDefinition = PuzzleDefinition(
  identity: PuzzleType.Sudoku,
  displayName: 'Sudoku',
  descriptor: 'A logic-based number placement puzzle.',
  color: const Color.fromARGB(255, 210, 210, 255),
);

final PuzzleDefinition shikakuDefinition = PuzzleDefinition(
  identity: PuzzleType.Shikaku,
  displayName: 'Shikaku',
  descriptor: 'Divide the Grid into Rectangles.',
  color: const Color.fromARGB(255, 217, 255, 217),
);

final PuzzleDefinition queensDefinition = PuzzleDefinition(
  identity: PuzzleType.Queens,
  displayName: 'Queens',
  descriptor: 'Place Queens on a NxN Grid',
  color: const Color.fromARGB(255, 246, 216, 246),
);

final List<PuzzleDefinition> puzzleCatalog = [
  sudokuDefinition,
  shikakuDefinition,
  queensDefinition,
];