import 'package:flutter/material.dart';
import 'package:puzzle_arcade/puzzle_catalog.dart';
import 'package:puzzle_arcade/sudoku/sudoku_session.dart';

class PuzzleScreen extends StatelessWidget {
  const PuzzleScreen({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('MENU COMING SOON')
                )
              );
            },
          )
        ]),
      body: PuzzleArea(puzzle: puzzle)
    );
  }
}

// Stateless widget for now
class PuzzleArea extends StatelessWidget {
  const PuzzleArea({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;


  @override
  Widget build(BuildContext context) {
    return switch (puzzle.identity) {
      PuzzleType.Sudoku => const SudokuSession(),
      PuzzleType.Shikaku => PlaceholderBody(puzzle: puzzle),
      PuzzleType.Queens => PlaceholderBody(puzzle: puzzle),   
    };
  }
}

class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) {
    return Container(
       color: puzzle.color,
       child: Center(child: Text(puzzle.displayName))
     );
  }
}