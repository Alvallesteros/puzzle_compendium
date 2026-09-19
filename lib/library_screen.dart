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
          childAspectRatio: 0.75,
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
    return Container(
      decoration: BoxDecoration(
        color: puzzle.color,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Color.lerp(puzzle.color, Colors.black, 0.25)!,
          width: 1.5,
        ),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12.0),
        child: Column(
          children: [
            PuzzleArtwork(puzzle: puzzle),
            Expanded(child: PuzzleLabel(puzzle: puzzle)),
          ],
        ), 
      )
    );
  }
}

class PuzzleArtwork extends StatelessWidget {
  const PuzzleArtwork({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: Container(
        color: Colors.white,
      ),
    );
  }
}

class PuzzleLabel extends StatelessWidget {
  const PuzzleLabel({super.key, required this.puzzle});
  final PuzzleDefinition puzzle;

  @override
  Widget build(BuildContext context) {
    return Container( 
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
                puzzle.displayName, 
                textAlign: TextAlign.left, 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: Color.lerp(puzzle.color, Colors.black, 0.75)!),
                ),
              Text(puzzle.descriptor),
          ],
        )
      );
  }
}