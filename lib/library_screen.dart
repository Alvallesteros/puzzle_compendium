import "package:flutter/material.dart";
import "package:puzzle_arcade/puzzle_catalog.dart";



//Library Screen UI
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Puzzle Compendium'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: puzzleCatalog.length,
        itemBuilder: (context, index) {
          final puzzle = puzzleCatalog[index];
          return PuzzleCard(
            puzzle: puzzle,
          );
        },
      ),
    );
  }
}

class PuzzleCard extends StatelessWidget {
  const PuzzleCard({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children:[
          Positioned.fill(child: PuzzleArtwork(puzzle: puzzle),),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: PuzzleLabel(puzzle: puzzle),
          )
        ]
      )
    );
  }
}

class PuzzleArtwork extends StatelessWidget {
  const PuzzleArtwork({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: puzzle.color,
    );
  }
}

class PuzzleLabel extends StatelessWidget {
  const PuzzleLabel({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(puzzle.displayName, textAlign: TextAlign.left, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          Text(puzzle.descriptor),
      ],
    );
  }
}