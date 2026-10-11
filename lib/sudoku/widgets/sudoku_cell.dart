import 'package:flutter/material.dart';

typedef CellContent = ({int? value, bool isGiven, Set<int> notes});
typedef CellAppearance = ({bool isSelected, bool isInvalid, bool isPeer});

class SudokuCell extends StatelessWidget {
  const SudokuCell({
    super.key, 
    required this.content,
    required this.appearance,
    required this.onTap, 
    this.thickRightBorder = false, 
    this.thickBottomBorder = false
  });

  final CellContent content;
  final CellAppearance appearance;
  final VoidCallback onTap;
  final bool thickRightBorder;
  final bool thickBottomBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: appearance.isSelected
              ? Colors.lightBlue
              : appearance.isInvalid
                  ? Colors.red
                  : appearance.isPeer
                    ? Colors.grey
                    : Colors.white,
          border: Border(
            right: BorderSide(color: Colors.black, width: thickRightBorder ? 3.0 : 1.0),
            bottom: BorderSide(color: Colors.black, width: thickBottomBorder ? 3.0 : 1.0),
          )
        ),
        child: Center(
          child: content.value != null 
            ? Text(
              content.value?.toString() ?? '',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: content.isGiven ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              )
            )
            : content.notes.isNotEmpty 
            ? Column(
                children: List.generate(3, (col) =>
                  Expanded(
                    child: Row(
                      children: List.generate(3, (row) =>
                        Expanded(
                          child: Center(
                            child: Text(
                              content.notes.contains(row + (col * 3) + 1) ? (row + (col * 3) + 1).toString() : '',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.teal
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            : Text('')
        )
      )
    );
  }
}