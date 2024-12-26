import 'package:chessgame/components/dead_piece.dart';
import 'package:chessgame/components/piece.dart';
import 'package:chessgame/components/square.dart';
import 'package:chessgame/values/colors.dart';
import 'package:flutter/material.dart';

import 'components/piece.dart';
import 'helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  // A 2 dimensional list representing the chessboard,
  // with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  // the currently selected piece on the chess board,
  // if no piece is selected this is null
  ChessPiece? selectedPiece;

  // the row index of the selected piece
  // default value -1 indicated no piece is currently selected
  int selectedRow = -1;
  // the col index of the selected piece
  // default value -1 indicated no piece is currently selected
  int selectedCol = -1;

  // a list of valid moves for the currently selected piece
  // each move is represented as a list with 2 elements row and col
  List<List<int>> validMoves = [];

  // a list of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken = [];

  // a list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken = [];


  // a booleon to indicate whose turn it is
  bool isWhiteTurn = true;

  // initial position of kings (keep track of this to make it easier later to see if king is in check)
  List<int> whitekingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;


  void initState() {
    super.initState();
    _initializeBoard();
  }
  // Initialize Board
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
    List.generate(8, (index) => List.generate(8 , (index) => null));



    // place pawns
    for (int i =0; i<8; i++){
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'lib/chessimages/pawn.png',
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'lib/chessimages/pawn.png',
      );
    }

    // place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/chessimages/rook.png',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/chessimages/rook.png',
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/chessimages/rook.png',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/chessimages/rook.png',
    );

    // place knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/chessimages/horse.png',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/chessimages/horse.png',
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/chessimages/horse.png',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/chessimages/horse.png',
    );

    // place bishops

    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/chessimages/bishop.png',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/chessimages/bishop.png',
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/chessimages/bishop.png',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/chessimages/bishop.png',
    );

    // place queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/chessimages/queen.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/chessimages/queen.png',
    );

    // place kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/chessimages/king.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/chessimages/king.png',
    );
    board = newBoard;
  }

  // USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // no piece has been selected yet this is the first selection
      if (selectedPiece ==  null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn){
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      // there is a piece already selected , but user can select another one of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite ==  selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }


      // if there is a piece selected and user taps on a square that is a valid move, move there
      else if(selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)){
        movePiece(row, col);
      }

      // if a piece is selected calculate its valid moves
      validMoves = calculateRawValidMoves(selectedRow, selectedCol, selectedPiece);
    });
  }

  // Calculate raw valid moves
  List<List<int>>calculateRawValidMoves(int row, int col, ChessPiece? piece){
    List<List<int>> candidateMoves = [];

    if(piece == null) {
      return [];
    }
    // diferent directions based on their color
    int direction = piece.isWhite ? -1 : 1;
    switch (piece.type){
      case ChessPieceType.pawn:
      // pawns can move forwad if the square is not occupied
        if (isInBoard(row + direction,  col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }


        // pawns can move 2 squares forwad if they are at their initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row +  direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // pawns can kill diagonally
        if (isInBoard(row + direction, col-1)&&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite ) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1)&&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
      // horizontal and vertical directions
        var directions = [
          [-1, 0], // UP
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var direction in directions) {
          var i = 1;
          while(true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // kill
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
      // all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up  2 left 1
          [-2, 1], // up  2 right 1
          [-1, -2], // up  1 left 2
          [-1, 2], // up  1 right 2
          [1, -2], // DOWN  1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down  2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)){
            continue;
          }
          if (board[newRow][newCol] != null){
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
      // diagonal directions
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions ){
          var i = 1;
          while(true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:

      // all eight directions up down right left and  4 diagonals
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];
        for (var direction in directions ){
          var i = 1;
          while(true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:
      // all eight directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions ){


          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if(!isInBoard(newRow, newCol)){
            continue;
          }
          if(board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      default:
    }

    return candidateMoves;
  }


  // Move a piece
  void movePiece(int newRow, int newCol){
    // if the new spot has an enemy piece
    if (board[newRow][newCol]!= null) {
      // add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if(capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      }else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // check if the piece being moved in a king
    if (selectedPiece!.type == ChessPieceType.king) {
      // update the appropriate king pos
      if (selectedPiece!.isWhite) {
        whitekingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // see if any kings are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1 ;
      validMoves = [];
    });


    // change turn
    isWhiteTurn = !isWhiteTurn;
  }

  //IS KING IN CHECK?
  bool isKingInCheck(bool isWhiteKing){
    // get the position of the king
    List<int> KingPosition =
    isWhiteKing ? whitekingPosition : blackKingPosition;

    // check if any enemoy piece can attack the king
    for(int i = 0; i < 8; i++) {
      for(int j = 0; j < 8; j++) {
        // skip empty squares and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue;
        }
        List<List<int>> pieceValidMoves =
        calculateRawValidMoves(i, j, board[i][j]);

        // check if the kings position is in this pieces valid moves
        if(pieceValidMoves.any((move) =>
        move[0] == KingPosition[0] && move[1] == KingPosition[1])){
          return true;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // white Pieces Taken
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics:const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          // Game Status
          Text(checkStatus ? "CHECK!" : ""),

          // chess board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics:  NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:8),
              itemBuilder: (context, index) {
                // get the row and col position of this square

                int row = index ~/ 8;
                int col = index % 8;

                // check if this square is selected
                bool isSelected = selectedRow == row && selectedCol == col;

                // check if this square is a valid move
                bool isValidMove = false;
                for (var position in validMoves) {
                  // compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }
                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),

          // black pieces Taken
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ) ,
    );
  }
}

