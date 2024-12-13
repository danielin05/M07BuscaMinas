import 'dart:io';
import 'dart:math';

const int rows = 6;
const int cols = 10;
const int minesCount = 8;

class Cell {
  bool isMine = false;
  bool isRevealed = false;
  bool hasFlag = false;
  int adjacentMines = 0;
}

List<List<Cell>> createBoard() {
  return List.generate(rows, (_) => List.generate(cols, (_) => Cell()));
}

void placeMines(List<List<Cell>> board) {
  int placedMines = 0;
  Random random = Random();

  while (placedMines < minesCount) {
    int quadrant = placedMines < minesCount / 2 ? 0 : 1; // Decide quadrant
    int row = quadrant == 0
        ? random.nextInt(rows ~/ 2)
        : rows ~/ 2 + random.nextInt(rows ~/ 2);
    int col = random.nextInt(cols ~/ 2) + (quadrant == 1 ? cols ~/ 2 : 0);

    if (!board[row][col].isMine) {
      board[row][col].isMine = true;
      placedMines++;
    }
  }
}

void calculateAdjacents(List<List<Cell>> board) {
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (board[r][c].isMine) continue;
      int count = 0;
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int nr = r + dr, nc = c + dc;
          if (nr >= 0 &&
              nr < rows &&
              nc >= 0 &&
              nc < cols &&
              board[nr][nc].isMine) {
            count++;
          }
        }
      }
      board[r][c].adjacentMines = count;
    }
  }
}

void printBoard(List<List<Cell>> board, {bool showMines = false}) {
  stdout.write('  ');
  for (int c = 0; c < cols; c++) stdout.write(c);
  stdout.writeln();

  for (int r = 0; r < rows; r++) {
    stdout.write(String.fromCharCode(65 + r) + ' ');
    for (int c = 0; c < cols; c++) {
      if (board[r][c].hasFlag) {
        stdout.write('#');
      } else if (!board[r][c].isRevealed) {
        stdout.write('·');
      } else if (board[r][c].isMine) {
        stdout.write(showMines ? '*' : '·');
      } else if (board[r][c].adjacentMines > 0) {
        stdout.write(board[r][c].adjacentMines);
      } else {
        stdout.write(' ');
      }
    }
    stdout.writeln();
  }
}

bool revealCell(List<List<Cell>> board, int row, int col) {
  // Condiciones base para detener la recursión
  if (row < 0 ||
      row >= rows ||
      col < 0 ||
      col >= cols ||
      board[row][col].isRevealed ||
      board[row][col].hasFlag) {
    return false;
  }

  // Revelar la casilla actual
  board[row][col].isRevealed = true;

  // Si la casilla es una mina, termina el proceso
  if (board[row][col].isMine) {
    return true; // Indica explosión
  }

  // Si no hay minas adyacentes, revela las casillas adyacentes
  if (board[row][col].adjacentMines == 0) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr != 0 || dc != 0) {
          // Evitar la casilla actual
          revealCell(board, row + dr, col + dc);
        }
      }
    }
  }

  return false; // No explota
}

void toggleFlag(List<List<Cell>> board, int row, int col) {
  if (row >= 0 &&
      row < rows &&
      col >= 0 &&
      col < cols &&
      !board[row][col].isRevealed) {
    board[row][col].hasFlag = !board[row][col].hasFlag;
  }
}

bool firstMove = true;

void handleFirstMove(List<List<Cell>> board, int row, int col) {
  if (board[row][col].isMine) {
    relocateMine(board, row, col);
  }
  revealCell(board, row, col);
  firstMove = false;
}

void relocateMine(List<List<Cell>> board, int row, int col) {
  Random random = Random();
  board[row][col].isMine = false;

  while (true) {
    int newRow = random.nextInt(rows);
    int newCol = random.nextInt(cols);

    if (!board[newRow][newCol].isMine && !board[newRow][newCol].isRevealed) {
      board[newRow][newCol].isMine = true;
      calculateAdjacents(board);
      break;
    }
  }
}

void main() {
  List<List<Cell>> board = createBoard();
  placeMines(board);
  calculateAdjacents(board);

  bool gameOver = false;
  int moves = 0;

  while (!gameOver) {
    printBoard(board);
    stdout.write('Escriu una comanda: ');
    String? input = stdin.readLineSync();

    if (input == null || input.isEmpty) continue;

    if (input.toLowerCase() == 'cheat' || input.toLowerCase() == 'trampes') {
      printBoard(board, showMines: true);
      continue;
    }

    if (input.toLowerCase() == 'help' || input.toLowerCase() == 'ajuda') {
      print('Comandes: [B2], [B2 flag], [trampes], [ajuda]');
      continue;
    }

    RegExp commandRegex = RegExp(r'([A-F])([0-9])(?:\s*(flag|bandera))?');
    Match? match = commandRegex.firstMatch(input);

    if (match != null) {
      int row = match.group(1)!.codeUnitAt(0) - 65;
      int col = int.parse(match.group(2)!);
      bool isFlag = match.group(3) != null;

      if (isFlag) {
        toggleFlag(board, row, col);
      } else {
        if (firstMove) {
          handleFirstMove(board, row, col);
        } else {
          if (revealCell(board, row, col)) {
            gameOver = true;
            printBoard(board, showMines: true);
            print('Has perdut!');
          } else {
            moves++;
          }
        }
      }
    } else {
      print('Comanda invàlida. Escriu "ajuda" per veure les opcions.');
    }
  }

  print('Número de tirades: $moves');
}
