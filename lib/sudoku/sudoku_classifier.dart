import 'dart:collection';
import 'package:puzzle_arcade/sudoku/sudoku_puzzle.dart';

enum Technique {
  nakedSingle,
  hiddenSingle,
  nakedPair,
  hiddenPair,
  nakedTriple,
  hiddenTriple,
  nakedQuad,
  hiddenQuad,
  pointingPair,
  pointingTriple,
  boxLineReduction,
  xWing,
  uniqueRectangle,
  swordfish,
  singlesChain,
  yWing;

  int get rank => switch (this) {
    // Tier 1: Easy
    Technique.nakedSingle       => 1,
    Technique.hiddenSingle      => 2,

    // Tier 2: Medium
    Technique.pointingPair      => 3,
    Technique.pointingTriple    => 4,
    Technique.boxLineReduction  => 5,
    Technique.nakedPair         => 6,
    Technique.hiddenPair        => 7,

    // Tier 4: Hard
    Technique.nakedTriple       => 8,
    Technique.hiddenTriple      => 9,
    Technique.uniqueRectangle   => 10,
    Technique.nakedQuad         => 11,
    Technique.xWing             => 12,
    Technique.swordfish         => 13,
    Technique.hiddenQuad        => 14,
    Technique.singlesChain      => 15,
    Technique.yWing             => 16,
  };
}

typedef ClassifierElimination = ({Technique technique, int row, int col, int digit});
typedef TechniqueApplication = ({Technique technique, int? row, int? col});
typedef SudokuClassification = ({bool solved, Technique? hardest, List<TechniqueApplication> path});

class SudokuClassifier {
  static List<ClassifierElimination>? debugCapture;
  const SudokuClassifier._();

  static void _recordElimination(Technique technique, int row, int col, int digit) {
    debugCapture?.add((technique: technique, row: row, col: col, digit: digit));
  }

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
      final pointingPair = _applyPointingPair(workingGrid, candidateMasks);
      if (pointingPair != null) {
        usedTechniques.add(pointingPair);
        continue;
      }
      final pointingTriple = _applyPointingTriple(workingGrid, candidateMasks);
      if (pointingTriple != null) {
        usedTechniques.add(pointingTriple);
        continue;
      }
      final boxLineReduction = _applyBoxLineReduction(workingGrid, candidateMasks);
      if (boxLineReduction != null) {
        usedTechniques.add(boxLineReduction);
        continue;
      }
      final nakedPair = _applyNakedPair(workingGrid, candidateMasks);
      if (nakedPair != null) {
        usedTechniques.add(nakedPair);
        continue;
      }
      final hiddenPair = _applyHiddenPair(workingGrid, candidateMasks);
      if (hiddenPair != null) {
        usedTechniques.add(hiddenPair);
        continue;
      }
      final nakedTriple = _applyNakedTriple(workingGrid, candidateMasks);
      if (nakedTriple != null) {
        usedTechniques.add(nakedTriple);
        continue;
      }
      final hiddenTriple = _applyHiddenTriple(workingGrid, candidateMasks);
      if (hiddenTriple != null) {
        usedTechniques.add(hiddenTriple);
        continue;
      }
      final uniqueRectangle = _applyUniqueRectangle(workingGrid, candidateMasks);
      if (uniqueRectangle != null) {
        usedTechniques.add(uniqueRectangle);
        continue;
      }
      final nakedQuad = _applyNakedQuad(workingGrid, candidateMasks);
      if (nakedQuad != null) {
        usedTechniques.add(nakedQuad);
        continue;
      }
      final xWing = _applyXWing(workingGrid, candidateMasks);
      if (xWing != null) {
        usedTechniques.add(xWing);
        continue;
      }
      final swordfish = _applySwordfish(workingGrid, candidateMasks);
      if (swordfish != null) {
        usedTechniques.add(swordfish);
        continue;
      }
      final hiddenQuad = _applyHiddenQuad(workingGrid, candidateMasks);
      if (hiddenQuad != null) {
        usedTechniques.add(hiddenQuad);
        continue;
      }
      final singlesChain = _applySinglesChain(workingGrid, candidateMasks);
      if (singlesChain != null) {
        usedTechniques.add(singlesChain);
        continue;
      }
      final yWing = _applyYWing(workingGrid, candidateMasks);
      if (yWing != null) {
        usedTechniques.add(yWing);
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
  static int _popCount(int x) {
    int count = 0;
    while (x != 0) {
      x &= x - 1;
      count++;
    }
    return count;
  }
  static List<int> _indicesFromBitmask(int mask) {
    List<int> result = [];
    int digit = 0;
    while (mask != 0) {
      if((mask & 1) != 0) {
        result.add(digit);
      }
      mask >>= 1;
      digit++;
    }
    return result;
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
  static Iterable<List<(int, int)>> _allBoxes() sync* {
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
  static Iterable<List<(int, int)>> _allLines() sync* {
      // Rows
      for (int r = 0; r < 9; r++) {
        yield [for (int c = 0; c < 9; c++) (r, c)];
      }
      // Columns
      for (int c = 0; c < 9; c++) {
        yield [for (int r = 0; r < 9; r++) (r, c)];
      }
  }

// TECHNIQUES
// FILL TECHNIQUES
  static TechniqueApplication? _applyNakedSingle(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (workingGrid[row][col] != null) {
          continue;
        }

        int count = _popCount(candidates[row][col]);
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

// NAKED SUBSETS
  static bool _eliminateNakedSubsetInUnit(List<(int, int)> cells, List<List<int?>> workingGrid, List<List<int>> candidates, int N) {
    List<(int, int)> eligible = [
      for (final (int row, int col) in cells)
        if (workingGrid[row][col] == null && _popCount(candidates[row][col]) <= N && _popCount(candidates[row][col]) >= 2) (row, col),
    ];

    if (eligible.length < N) {return false;}

    for (int mask = 0; mask < (1 << eligible.length); mask++) {
      List<(int, int)> eligibleSubset = [];
      if(_popCount(mask) == N) {
        List<int> eligibleIndices = _indicesFromBitmask(mask);
        int union = 0;
        for (final index in eligibleIndices) {
          int r = eligible[index].$1;
          int c = eligible[index].$2;
          eligibleSubset.add((r, c));
          union |= candidates[r][c];
        } 

        bool removed = false;
        List<int> unionCandidates = _candidatesOf(union);
        if (_popCount(union) == N) {
          for (final (int row, int col) in cells) {
            if (workingGrid[row][col] == null && !eligibleSubset.contains((row, col))) {
              for (final digit in unionCandidates) {
                int oldMask = candidates[row][col];
                candidates[row][col] = _removeCandidate(candidates[row][col], digit);
                if (oldMask != candidates[row][col]) removed = true;
              }
            }
          }
          if (removed) return removed;
        }
      }
    }
    return false;
  }
  static TechniqueApplication? _applyNakedPair(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final unitCells in _allUnits()) {
      if (_eliminateNakedSubsetInUnit(unitCells, workingGrid, candidates, 2)) {
        return (technique: Technique.nakedPair, row: null, col: null); 
      }
    }
    return null;
  }
  static TechniqueApplication? _applyNakedTriple(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final unitCells in _allUnits()) {
      if (_eliminateNakedSubsetInUnit(unitCells, workingGrid, candidates, 3)) {
        return (technique: Technique.nakedTriple, row: null, col: null); 
      }
    }
    return null;
  }
  static TechniqueApplication? _applyNakedQuad(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final unitCells in _allUnits()) {
      if (_eliminateNakedSubsetInUnit(unitCells, workingGrid, candidates, 4)) {
        return (technique: Technique.nakedQuad, row: null, col: null); 
      }
    }
    return null;
  }

// HIDDEN SUBSETS
  static bool _eliminateHiddenSubsetInUnit(List<(int, int)> cells, List<List<int?>> workingGrid, List<List<int>> candidates, int N) {
    Map<int, List<(int, int)>> positionMap = {};
    for (int d = 1; d <= 9; d++) {
      for (final (int row, int col) in cells) {
        if (workingGrid[row][col] == null && _hasCandidate(candidates[row][col], d)) {
          positionMap.putIfAbsent(d, () => []).add((row, col));
        }
      }
    }

    // Skip digits with zero or one position:
    positionMap.removeWhere((_, positions) => positions.length <= 1);
    List<int> digits = positionMap.keys.toList();

    for (int subset = 0; subset < (1 << digits.length); subset++) { // Num of Subsets of eligible digits
      if (_popCount(subset) == N) {
        Set<(int, int)> unionPositions = {};
        List<int> digitIndices = _indicesFromBitmask(subset);
        Set<int> subsetDigits = {};
        for (int index in digitIndices) {
          unionPositions.addAll(positionMap[digits[index]]!);
          subsetDigits.add(digits[index]);
        }

        bool removed = false;
        if (unionPositions.length == N) {
          for (int d = 1; d <= 9; d++) {
            if (!subsetDigits.contains(d)) {
              for (final (int row, int col) in unionPositions) {
                if (workingGrid[row][col] == null && _hasCandidate(candidates[row][col], d)) {
                  int oldMask = candidates[row][col];
                  candidates[row][col] = _removeCandidate(candidates[row][col], d);
                  if (oldMask != candidates[row][col]) removed = true;
                }
              }
            }
          }
          if (removed) return removed;
        }
      }
    }
    return false;
  }
  static TechniqueApplication? _applyHiddenPair(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final unitCells in _allUnits()) {
      if (_eliminateHiddenSubsetInUnit(unitCells, workingGrid, candidates, 2)) {
        return (technique: Technique.hiddenPair, row: null, col: null); 
      }
    }
    return null;
  }
  static TechniqueApplication? _applyHiddenTriple(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final unitCells in _allUnits()) {
      if (_eliminateHiddenSubsetInUnit(unitCells, workingGrid, candidates, 3)) {
        return (technique: Technique.hiddenTriple, row: null, col: null); 
      }
    }
    return null;
  }
  static TechniqueApplication? _applyHiddenQuad(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final unitCells in _allUnits()) {
      if (_eliminateHiddenSubsetInUnit(unitCells, workingGrid, candidates, 4)) {
        return (technique: Technique.hiddenQuad, row: null, col: null); 
      }
    }
    return null;
  }

// POINTING SUBSETS
  static bool _eliminatePointingInBox(List<(int, int)> boxCells, List<List<int?>> workingGrid, List<List<int>> candidates, int N) {
      bool changes = false;

      for (int d = 1; d <= 9; d++) {
        List<(int, int)> digitPositions = [];
        
        for (final (int row, int col) in boxCells) {
          if (workingGrid[row][col] == null && _hasCandidate(candidates[row][col], d) ) {
            digitPositions.add((row, col));
          }
        }

        if (digitPositions.length != N) {continue;} // Skip if Positions of Digit is != N

        bool sameRow = digitPositions.every((p) => p.$1 == digitPositions.first.$1);
        bool sameCol = digitPositions.every((p) => p.$2 == digitPositions.first.$2);

        if (!(sameCol || sameRow)) {continue;} // Skip if candidate values not aligned
        
        for (int i = 0; i < 9; i++) {
          if (sameRow && !digitPositions.contains((digitPositions.first.$1, i)) && workingGrid[digitPositions.first.$1][i] == null && _hasCandidate(candidates[digitPositions.first.$1][i], d)) {
            int oldValue = candidates[digitPositions.first.$1][i];
            candidates[digitPositions.first.$1][i] = _removeCandidate(candidates[digitPositions.first.$1][i], d);
            if (oldValue != candidates[digitPositions.first.$1][i]) {changes = true;}
          }
          if (sameCol && !digitPositions.contains((i, digitPositions.first.$2)) && workingGrid[i][digitPositions.first.$2] == null && _hasCandidate(candidates[i][digitPositions.first.$2], d)) {
            int oldValue = candidates[i][digitPositions.first.$2];
            candidates[i][digitPositions.first.$2] = _removeCandidate(candidates[i][digitPositions.first.$2], d);
            if (oldValue != candidates[i][digitPositions.first.$2]) {changes = true;}
          }
        }
        if ( changes ) return changes;
      }
      return false;
    }
  static TechniqueApplication? _applyPointingPair(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final box in _allBoxes()) {
      if (_eliminatePointingInBox(box, workingGrid, candidates, 2)) {
        return (technique: Technique.pointingPair, row: null, col: null);
      }
    }
    return null;
  }
  static TechniqueApplication? _applyPointingTriple(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final box in _allBoxes()) {
      if (_eliminatePointingInBox(box, workingGrid, candidates, 3)) {
        return (technique: Technique.pointingTriple, row: null, col: null);
      }
    }
    return null;
  }

// BOX-LINE REDUCTION
  static bool _eliminateBoxLineReductionInLine(List<(int, int)> lineCells, List<List<int?>> workingGrid, List<List<int>> candidates) {
    bool changes = false;

    for (int d = 1; d <= 9; d++) {
      List<(int, int)> digitPositions = [];
      for (final (int row, int col) in lineCells) {
        if (workingGrid[row][col] == null && _hasCandidate(candidates[row][col], d)) {
          digitPositions.add((row, col));
        }
      }
      if (digitPositions.length < 2) continue;

      bool sameBox = digitPositions.every((p) => (p.$1 ~/3 * 3 == digitPositions.first.$1 ~/3 * 3) && (p.$2 ~/3 * 3 == digitPositions.first.$2 ~/3 * 3));
      if (!sameBox) continue;

      (int, int) boxOrigin = (digitPositions.first.$1 ~/3 * 3, digitPositions.first.$2 ~/3 * 3);
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          int r = boxOrigin.$1 + i;
          int c = boxOrigin.$2 + j;

          if (lineCells.contains((r, c))) continue;
          if (workingGrid[r][c] == null && _hasCandidate(candidates[r][c], d)) {
            int oldValue = candidates[r][c];
            candidates[r][c] = _removeCandidate(candidates[r][c], d);
            if (oldValue != candidates[r][c]) {changes = true;}
          }
        }
      }

      if (changes) return changes;
    }
    return false;
  }
  static TechniqueApplication? _applyBoxLineReduction(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (final line in _allLines()) {
      if (_eliminateBoxLineReductionInLine(line, workingGrid, candidates)) {
        return (technique: Technique.boxLineReduction, row: null, col: null);
      }
    }
    return null;
  }

// FISH AND WING TECHNIQUES
  static Iterable<List<int>> _indicesCombination({required int n, required int size, int start = 0}) sync* {
    if (size == 0) {
      yield [];
      return;
    }

    for (int i = start; i <= n - size; i++) {
      for (final combination in _indicesCombination(
        n: n,
        size: size - 1,
        start: i + 1,
      )) {
        yield [i, ...combination];
      }
    }
  }
  static bool _fishInOrientation(List<List<int?>> workingGrid, List<List<int>> candidates, int N, bool primaryIsRow) {
    bool changes = false;
    (int, int) cellFor(int primary, int secondary) {
      return primaryIsRow ? (primary, secondary) : (secondary, primary);
    }

    Iterable<List<int>> primaryUnitIndices = _indicesCombination(n: 9, size: N);
    for ( final primaryIndices in primaryUnitIndices) {
      Digit:
      for ( int d = 1; d <= 9; d++ ) {
        Set<int> unionPos = {};
        for ( final primaryIndex in primaryIndices) {
          Set<int> setPos = {};
          for ( int secondaryIndex = 0; secondaryIndex < 9; secondaryIndex++) {
            (int, int) cell = cellFor(primaryIndex, secondaryIndex);
            if (workingGrid[cell.$1][cell.$2] == null && _hasCandidate(candidates[cell.$1][cell.$2], d)) {
              setPos.add(secondaryIndex);
            }
          }
          if (setPos.isEmpty) continue Digit;
          unionPos.addAll(setPos);
        }
        if (unionPos.length != N) continue Digit;

        for (final s in unionPos) {
          for (int p = 0; p < 9; p++) {
            (int, int) c = cellFor(p, s);
            if (primaryIndices.contains(p)) continue;
            if (workingGrid[c.$1][c.$2] == null && _hasCandidate(candidates[c.$1][c.$2], d)) {
              int oldValue = candidates[c.$1][c.$2];
              candidates[c.$1][c.$2] = _removeCandidate(candidates[c.$1][c.$2], d);
              if (oldValue != candidates[c.$1][c.$2]) {
                _recordElimination(N == 2 ? Technique.xWing : Technique.swordfish, c.$1, c.$2, d);
                changes = true;
              }
            }
          }
        }
        if (changes) return true;
      }
    }
    return false;
  }
  static bool _applyFish(List<List<int?>> workingGrid, List<List<int>> candidates, int N) {
    if (_fishInOrientation(workingGrid, candidates, N, true)) return true;
    return _fishInOrientation(workingGrid, candidates, N, false);
  }
  static TechniqueApplication? _applyXWing(List<List<int?>> workingGrid, List<List<int>> candidates) {
    if (_applyFish(workingGrid, candidates, 2)) {
      return (technique: Technique.xWing, row: null, col: null);
    }
    return null;
  }
  static TechniqueApplication? _applySwordfish(List<List<int?>> workingGrid, List<List<int>> candidates) {
    if (_applyFish(workingGrid, candidates, 3)) {
      return (technique: Technique.swordfish, row: null, col: null);
    }
    return null;
  }

// ADVANCED TECHNIQUES
// Y-WING
  static TechniqueApplication? _applyYWing(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for ( int row = 0; row < 9; row++ ) {
      for ( int col = 0; col < 9; col++ ) {
        if ( workingGrid[row][col] == null && _popCount(candidates[row][col])== 2 ) {
          (int, int) pivot = (row, col);
          Set<(int, int)> peers = _peersOf(pivot).where((cell) => workingGrid[cell.$1][cell.$2] == null && _popCount(candidates[cell.$1][cell.$2]) == 2 ).toSet();
          for ( final wingOne in peers.where((cell) => 
            //To have 1 shared digit ab & xc should yield a popcount of 1 if x is either a or b ( 1 being c )
            _popCount(candidates[cell.$1][cell.$2] & candidates[pivot.$1][pivot.$2]) == 1
          )) {
            for ( final wingTwo in peers.where((cell) =>
              cell != wingOne &&
              candidates[pivot.$1][pivot.$2] & candidates[wingOne.$1][wingOne.$2] != candidates[pivot.$1][pivot.$2] & candidates[cell.$1][cell.$2] &&
              _popCount(candidates[cell.$1][cell.$2] & candidates[pivot.$1][pivot.$2]) == 1 &&
              _popCount(candidates[cell.$1][cell.$2] & candidates[wingOne.$1][wingOne.$2]) == 1
            )) {
              int c = _candidatesOf(candidates[wingOne.$1][wingOne.$2] & candidates[wingTwo.$1][wingTwo.$2]).first;
              
              Set<(int, int)> peersWingTwo = _peersOf(wingTwo);
              for (final intersection in _peersOf(wingOne).where((cell) => 
                peersWingTwo.contains(cell)
              )) {
                if (workingGrid[intersection.$1][intersection.$2] == null && _hasCandidate(candidates[intersection.$1][intersection.$2], c)) {
                  int oldValue = candidates[intersection.$1][intersection.$2];
                  candidates[intersection.$1][intersection.$2] = _removeCandidate(candidates[intersection.$1][intersection.$2], c);
                  if (oldValue != candidates[intersection.$1][intersection.$2]) {
                    _recordElimination(Technique.yWing, intersection.$1, intersection.$2, c);
                    return (technique: Technique.yWing, col: null, row: null);
                  } 
                }
              }
            }
          }
        }
      }
    } 
    return null;
  }
// SINGLES CHAIN
  static TechniqueApplication? _applySinglesChain(List<List<int?>> workingGrid, List<List<int>> candidates) {
    for (int digit = 1; digit <= 9; digit++) {
      Set<(int, int)> candidateSet = {};
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (workingGrid[i][j] == null && _hasCandidate(candidates[i][j], digit)) {
            candidateSet.add((i, j));
          }
        }
      }
      
      if (candidateSet.length < 2) continue;

      Map<(int, int), Set<(int,int)>> conjugatePairGraph = {};
      for (final unit in _allUnits()) {
        List<(int, int)> candidateCells = [];
        for (final cell in unit) {
          if (workingGrid[cell.$1][cell.$2] == null && _hasCandidate(candidates[cell.$1][cell.$2], digit)) {
            candidateCells.add(cell);
          }
        }

        if (candidateCells.length == 2) {
          for (final cell in candidateCells) {
            conjugatePairGraph.putIfAbsent(cell, () => <(int,int)>{}).addAll(candidateCells.where((c) => c != cell));
          }
        }
      }

      Map<(int, int), int> colorMap = {}; // 0 = A, 1 = B — shared across all components
      List<(Set<(int, int)>, Set<(int, int)>)> components = [];

      for (final candidate in candidateSet) {
        if (colorMap.keys.contains(candidate)) continue;

        ListQueue<(int, int)> queue = ListQueue<(int, int)>()..add(candidate);
        colorMap.putIfAbsent(candidate, () => 0);
        Set<(int, int)> colorA = {candidate};
        Set<(int, int)> colorB = {}; 
        bool oddCycle = false;

        while (queue.isNotEmpty) {
          (int, int) node = queue.removeFirst();
          int nodeColor = colorMap[node]!;

          for (final nextNode in conjugatePairGraph[node] ?? const <(int, int)>{}) {
            if (!colorMap.keys.contains(nextNode)) {
              colorMap.putIfAbsent(nextNode, () => 1 - nodeColor);
              (nodeColor == 0 ? colorB : colorA).add(nextNode);
              queue.add(nextNode);
            } else if (colorMap[nextNode] == nodeColor) {
              oddCycle = true;
              break;
            }
          }
        }

        if (oddCycle) continue;
        if (colorA.length + colorB.length < 2) continue;
        components.add((colorA, colorB));
      }

      bool changes = false;
      for ( final (colorA, colorB) in components) {
        // RULE 1
        for (final cell in colorA) {
          if (_peersOf(cell).any((peer) => colorA.contains(peer))) {
            for (final (row, col) in colorA) {
              int oldValue = candidates[row][col];
              candidates[row][col] = _removeCandidate(candidates[row][col], digit);
              if (oldValue != candidates[row][col]) {
                _recordElimination(Technique.singlesChain, row, col, digit);
                changes = true;
              }
            }
            if (changes) {return (technique: Technique.singlesChain, row: null, col: null);}
          }
        }


        for (final cell in colorB) {
          if (_peersOf(cell).any((peer) => colorB.contains(peer))) {
            for (final (row, col) in colorB) {
              int oldValue = candidates[row][col];
              candidates[row][col] = _removeCandidate(candidates[row][col], digit);
              if (oldValue != candidates[row][col]) {
                _recordElimination(Technique.singlesChain, row, col, digit);
                changes = true;
              }
            }
            if (changes) {return (technique: Technique.singlesChain, row: null, col: null);}
          }
        }

        //RULE 2
        for (final (row, col) in candidateSet.where((cell) => !colorA.contains(cell) && !colorB.contains(cell))) {
          if (_hasCandidate(candidates[row][col], digit) && _peersOf((row, col)).any((peer) => colorA.contains(peer)) && _peersOf((row, col)).any((peer) => colorB.contains(peer))) {
            int oldValue = candidates[row][col];
            candidates[row][col] = _removeCandidate(candidates[row][col], digit);
            if (oldValue != candidates[row][col]) {
              _recordElimination(Technique.singlesChain, row, col, digit);
              return (technique: Technique.singlesChain, row: null, col: null);
            }
          }          
        }
      }
    }
    return null;
  }
// UNIQUE RECTANGLE
  static TechniqueApplication? _applyUniqueRectangle(List<List<int?>> workingGrid, List<List<int>> candidates) {
    List<List<int>> rowPairs = _indicesCombination(n: 9, size: 2).toList();
    List<List<int>> colPairs = _indicesCombination(n: 9, size: 2).toList();

    for (final rowPair in rowPairs) {
      NextColPair:
      for (final colPair in colPairs) {
        var (r1, r2, c1, c2) = (rowPair[0], rowPair[1], colPair[0], colPair[1]);
        bool sameBand = r1 ~/3 * 3 == r2 ~/3 * 3;
        bool sameStack = c1 ~/3 * 3 == c2 ~/3 * 3;
        
        if (!(sameBand ^ sameStack)) continue;


        int? digitCandidates;
        (int, int)? roof;
        for (final row in [r1, r2]) {
          for (final col in [c1, c2]) {
            if (workingGrid[row][col] != null)  continue NextColPair;
            if (_popCount(candidates[row][col]) < 2) continue NextColPair; 
            if (_popCount(candidates[row][col]) > 2) {
              if (roof == null) {
                 roof = (row, col);
              }
              else {continue NextColPair;}
            }
            digitCandidates ??= candidates[row][col];
            digitCandidates &= candidates[row][col];
          }
        }

        if (_popCount(digitCandidates!) != 2) continue;
        if (roof == null) continue;

        bool changes = false;
        for (final digit in _candidatesOf(digitCandidates)) {
          int oldValue = candidates[roof.$1][roof.$2];
          candidates[roof.$1][roof.$2] = _removeCandidate(candidates[roof.$1][roof.$2], digit);
          if (oldValue != candidates[roof.$1][roof.$2]) {
            _recordElimination(Technique.uniqueRectangle, roof.$1, roof.$2, digit);
            changes = true;
          }
        }
        if (changes) {return (technique: Technique.uniqueRectangle, row: null, col: null);}
      }
    }
    return null;
  }
}