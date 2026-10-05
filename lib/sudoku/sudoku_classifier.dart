import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';

enum Technique {
  nakedSingle,
  hiddenSingle,
  nakedPair,
  hiddenPair,
  pointingPair,
  boxLineReduction;

  int get rank => switch (this) {
        Technique.nakedSingle => 1,
        Technique.hiddenSingle => 2,
        Technique.nakedPair => 3,
        Technique.hiddenPair => 4,
        Technique.pointingPair => 5,
        Technique.boxLineReduction => 6,
      };
}

typedef TechniqueApplication = ({Technique technique, int? row, int? col});
typedef SudokuClassification = ({bool solved, Technique? hardest, List<TechniqueApplication> path});

class SudokuClassifier {
  const SudokuClassifier._();

  static SudokuClassification classify(SudokuPuzzle puzzle) {
    //Build a 9x9 copy of the puzzle
    List<List<int?>> workingGrid = puzzle.grid.map((row) => List<int?>.from(row)).toList();
    List<List<int>> candidateMasks = _buildCandidates(workingGrid);
    List<TechniqueApplication> usedTechniques = [];

    while(!_isSolved(workingGrid)) {
      final nakedSingle = _applyNakedSingle(workingGrid, candidateMasks);
      if (nakedSingle != null) {
        usedTechniques.add(nakedSingle);
        continue;
      }
      final hiddenSingle = _applyHiddenSingle(workingGrid, candidateMasks);
      if (hiddenSingle != null) {
        usedTechniques.add(hiddenSingle);
        continue;
      }
      final nakedPair = _applyNakedPair(workingGrid, candidateMasks);
      if (nakedPair != null) {
        usedTechniques.add(nakedPair);
        continue;
      }
      break;
    }

    Technique? hardest;
    if (usedTechniques.isNotEmpty) {
      hardest = usedTechniques[0].technique;
      for (TechniqueApplication t in usedTechniques) {
        if (t.technique.rank > hardest!.rank) {
          hardest = t.technique;
        }
      }
    }
    
    return (solved: _isSolved(workingGrid), hardest: hardest, path: usedTechniques);
  }

  static const int _allCandidates = 511; // 0b111111111 — bits 0..8 set (digits 1..9)

  // HELPERS
  static int _bitFor(int digit) {
    return 1 << (digit -1);
  }
  static bool _hasCandidate(int mask, int d) {
    return (mask & _bitFor(d)) != 0;
  }
  static int _removeCandidate(int mask, int d) {
    return mask & ~_bitFor(d);
  }
  static int _candidateCount(int mask) {
    int count = 0;
    for (int i = 1; i <= 9; i++ ) {
      if (_hasCandidate(mask, i)) {
        count++;
      }
    }
    return count;
  }
  static List<int> _candidatesOf(int mask) {
    List<int> candidates = [];
    for (int i = 1; i <= 9; i++) {
      if (_hasCandidate(mask, i)) {
        candidates.add(i);
      }
    } 
    return candidates;
  }
  static bool _isSolved(List<List<int?>> workingGrid) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (workingGrid[i][j] == null) {
          return false;
        }
      }
    }
    return true;
  }  

  static List<List<int>> _buildCandidates(List<List<int?>> workingGrid) {
    List<List<int>> result = List.generate(9, (_) => List.filled(9, 0));
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (workingGrid[row][col] != null) {
          continue;
        }
        int mask = _allCandidates;
        for (final (peerRow, peerCol) in _peersOf((row, col))) {
          int? value =  workingGrid[peerRow][peerCol];
          if (value != null) {
            mask = _removeCandidate(mask, value);
          }
        }
        result[row][col] = mask;
      }
    }
    return result;
  }

  static Set<(int, int)> _peersOf((int row, int col) cell) {
    final (row, col) = cell;
    final peers = <(int, int)>{};

    // Add cells in the same row and column.
    for (int index = 0; index < 9; index++) {
      if (index != col) peers.add((row, index));
      if (index != row) peers.add((index, col));
    }

    // Add cells in the same 3x3 box. The set removes duplicates.
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int rowOffset = 0; rowOffset < 3; rowOffset++) {
      for (int colOffset = 0; colOffset < 3; colOffset++) {
        final peer = (boxRow + rowOffset, boxCol + colOffset);
        if (peer != cell) peers.add(peer);
      }
    }

    return peers;
  }

  static void _fill(List<List<int?>> workingGrid, List<List<int>> candidates, int row, int col, int digit) {
    workingGrid[row][col] = digit;
    candidates[row][col] = 0;
    for (final (peerRow, peerCol) in _peersOf((row, col))) {
      candidates[peerRow][peerCol] = _removeCandidate(candidates[peerRow][peerCol], digit);
    }
  }

// Create All Unit Cells in the following order: Rows, Cols, Box Cells
  static Iterable<List<(int, int)>> _allUnits() sync* {
      // Rows
      for (int r = 0; r < 9; r++) {
        yield [for (int c = 0; c < 9; c++) (r, c)];
      }
      // Columns
      for (int c = 0; c < 9; c++) {
        yield [for (int r = 0; r < 9; r++) (r, c)];
      }
      // Boxes
      for (int br in [0, 3, 6]) {
        for (int bc in [0, 3, 6]) {
          yield [
            for (int i = 0; i < 3; i++)
              for (int j = 0; j < 3; j++)
                (br + i, bc + j)
          ];
        }
      }
    }



// TECHNIQUES
  static TechniqueApplication? _applyNakedSingle(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (workingGrid[row][col] != null) {
          continue;
        }

        int count = _candidateCount(candidates[row][col]);
        if (count != 1) {
          continue;
        }
        int digit = _candidatesOf(candidates[row][col]).single;
        _fill(workingGrid, candidates, row, col, digit);
        return (technique: Technique.nakedSingle, row: row, col: col);
      }
    }
    return null;
  }

  static TechniqueApplication? _applyHiddenSingle(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final unitCells in _allUnits()) {
      for (int digit = 1; digit <= 9; digit++) {
        (int, int)? homeCell;
        for (final (int row, int col) in unitCells) {
          if (workingGrid[row][col] == null && _hasCandidate(candidates[row][col], digit)) {
            if (homeCell != null) {
              homeCell = null;
              break;
            }
            homeCell = (row, col);
          }
        }

        if (homeCell != null) {
          _fill(workingGrid, candidates, homeCell.$1, homeCell.$2, digit);
          return (technique: Technique.hiddenSingle, row: homeCell.$1, col: homeCell.$2);
        }
      }
    }
    return null;
  }

  static bool _eliminateNakedPairInUnit(List<(int, int)> cells, List<List<int?>> workingGrid, List<List<int>> candidates) {
    Map<int, List<(int, int)>> cellMap = {};
    bool changes = false;

    for (final (int row, int col) in cells) {
      if(workingGrid[row][col] == null && _candidateCount(candidates[row][col]) == 2) {
        if (!cellMap.containsKey(candidates[row][col])) {
          cellMap[candidates[row][col]] = [];
        }
        cellMap[candidates[row][col]]!.add((row, col));
      } else {
        continue;
      }
    }

    List<(int, int)>? nakedPairCoordinates;
    List<int>? nakedPair;

    for (final k in cellMap.keys) {
      if (cellMap[k]!.length == 2) {
        nakedPairCoordinates = cellMap[k];
        nakedPair = _candidatesOf(k);
        break;
      }
    }

    
    if (nakedPairCoordinates != null && nakedPair != null){
      for (final (int row, int col) in cells) {
        if (workingGrid[row][col] == null) {
          for (final (int digit) in nakedPair) {
            if (!nakedPairCoordinates.contains((row, col)) && _hasCandidate(candidates[row][col], digit)) {
              candidates[row][col] = _removeCandidate(candidates[row][col], digit);
              changes = true;
            }
          }
        }
      }
    }
    return changes;
  }
  static TechniqueApplication? _applyNakedPair(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final unitCells in _allUnits()) {
      if (_eliminateNakedPairInUnit(unitCells, workingGrid, candidates)) {
        return (technique: Technique.nakedPair, row: null, col: null); 
      }
    }
    return null;
  }
}