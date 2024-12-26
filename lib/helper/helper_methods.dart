import 'package:flutter/material.dart';

bool isWhite(int index) {
  int x = index ~/ 8;
  int y = index % 8;

// alternate colors for each square
  bool isWhite = (x + y) % 2 == 0;
  return isWhite;
}

bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}
