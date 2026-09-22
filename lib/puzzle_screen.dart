import 'package:flutter/material.dart';
import 'package:puzzle_arcade/puzzle_catalog.dart';
import 'package:puzzle_arcade/sudoku/sudoku_body.dart';

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
                  content: Text('MENU COMING SOON')
                )
              );
            },
          )
        ]),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: PuzzleArea(puzzle: puzzle),),
            InputArea()
          ]
        )
      )
    );
  }
}

// Stateless widget for now
class PuzzleArea extends StatelessWidget {
  const PuzzleArea({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;


  @override
  Widget build(BuildContext context) {
    switch (puzzle.identity) {
      case PuzzleType.Sudoku:
        return const SudokuBody();
      default:
      return Container(
          color: puzzle.color,
          child: Center(child: Text(puzzle.displayName))
        );
    }
  }
}

// Input Area stateless for now
class InputArea extends StatelessWidget {
  const InputArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: Colors.grey[200],
      child: Center(child: Text('Input Area'))
    );
  }
}