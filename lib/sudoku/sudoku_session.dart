import 'package:flutter/material.dart';
import 'package:puzzle_arcade/sudoku/sudoku_cell.dart';
import 'package:puzzle_arcade/sudoku/num_pad.dart';
import 'package:puzzle_arcade/sudoku/sudoku_validator.dart';
import 'package:puzzle_arcade/sudoku/sudoku_generator.dart';
import 'package:puzzle_arcade/sudoku/sudoku_difficulty.dart';
import 'package:puzzle_arcade/sudoku/generated_puzzle.dart';
import 'package:puzzle_arcade/env.dart';

class SudokuSession extends StatefulWidget {
  const SudokuSession({super.key});

  @override
  _SudokuSessionState createState() => _SudokuSessionState();
}

class _SudokuSessionState extends State<SudokuSession>{
  final GeneratedPuzzle generated = SudokuGenerator.generate(currentSeed(), SudokuDifficulty(targetGivens: 79));
  (int, int)? selectedCell;
  final Map<(int, int), int> enteredValues = {};

  void _select (int row, int col) {
    if (selectedCell != (row, col)) {
      setState(() {
        selectedCell = (row, col);
      });
    } else {
      setState(() {
        selectedCell = null;
      });
    } 
  }

  Set<(int, int)> _peersOf((int row, int col) cell) {
    final (row, col) = cell;
    Set<(int, int)> peers = {};

    // Iterator of Cells (Row-Col)
    for (int i = 0; i < 9; i++) {
      if (col != i) {
        peers.add((row, i));
      } // Row Peers
      if (row != i) {
        peers.add((i, col));
      } // Col Peers
    }

    // Iterator of Cells (Box)

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final peer = (((row ~/ 3) * 3) + i,((col ~/ 3) * 3) + j);
        if (cell != peer) {
          peers.add(peer);
        }
      }
    }

    return peers;
  }

  int? _displayValueAt(int row, int col) {
    (int, int) key = (row, col);
    if (enteredValues.containsKey(key)) {
      return enteredValues[key];
    } else {
      return generated.puzzle.valueAt(row, col);
    } 
  }

  void _enterDigit(int digit) {
    if (selectedCell == null) {
      return;
    }
    final (row, col) = selectedCell!;
    if (generated.puzzle.isGiven(row, col)) {
      return;
    }
    setState(() {
      enteredValues[(row, col)] = digit;
    });

    final result = findConflicts(generated.puzzle, enteredValues);
    if (result.isFull && result.invalid.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Puzzle complete'),
          content: const Text('You solved the Sudoku puzzle.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _eraseSelected() {
    if (selectedCell == null) {
      return;
    }
    final (row, col) = selectedCell!;
    if (generated.puzzle.isGiven(row, col)) {
      return;
    }
    if (!enteredValues.containsKey(selectedCell)) {
      return;
    }
    setState(() {
      enteredValues.remove(selectedCell);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = findConflicts(generated.puzzle, enteredValues);
    Set<(int, int)> peers = selectedCell == null ? {} : _peersOf(selectedCell!);

    return Column (
      children: [
        // GRID ==============================
          Expanded ( 
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3.0),
                  ),
                  child: Column(
                    children: List.generate(9, (row) => 
                      Expanded(
                        child: Row(
                          children: List.generate(9, (col) =>
                            Expanded(
                              child: SudokuCell(
                                value: _displayValueAt(row, col), 
                                isGiven: generated.puzzle.isGiven(row, col), 
                                isSelected: selectedCell == (row, col),
                                isInvalid: result.invalid.contains((row, col)),
                                isPeer: peers.contains((row, col)),
                                thickRightBorder: col % 3 == 2 && col != 8,
                                thickBottomBorder: row % 3 == 2 && row != 8,
                                onTap: () => _select(row, col)
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          ),
      // NUM PAD ==============================
        NumberPad(
          onDigit: _enterDigit,
          onErase: _eraseSelected,
        )
      ]
    );
  }
}