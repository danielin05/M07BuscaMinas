import 'dart:io';
import 'dart:math';

List<List<dynamic>> matriu = [
  [" ", 0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  ["A", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["B", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["C", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["D", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["E", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["F", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"]
];

List<List<dynamic>> matriuMines = [
  [" ", 0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  ["A", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["B", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["C", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["D", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["E", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["F", "·", "·", "·", "·", "·", "·", "·", "·", "·", "·"]
];

List nums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
Map<String, int> filaIndices = {"A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6};

const menu = """
------ MENU ------
1: Escollir casella
2: Posar bandera
3: Trampa
4: Ajuda
0: Sortir
""";

const menuAjuda = """
------ MENU AJUDA ------
Les opcions: 1, escollir casella, casella. ----> Escribint una casella (D2, A8, etc) destapes una casella
Les opcions: 2, posar bandera, bandera, flag. ----> Escribint una casella (D2, A8, etc) poses una bandera.
Les opcions: 3, trampa, cheats. ----> Mostra el taulell amb les mines destapades.
Les opcions: 4, ajuda, help. ----> Son per mostrar aquest menu d'ajuda
Les opcions: 0, sortir, exit. ----> Serveixen per sortir del joc.
""";

int minesTotals = 8;
int minesRestants = 8;
int banderas = 0;
bool trampas = false;
bool esPrimeraJugada = true;

void enterraMines() {
  Random random = Random();

  // Map para rastrear el conteo de minas en cada cuadrante
  Map<String, int> contadorMinas = {
    "Q1": 0, // Cuadrante 1: columnas 0-4, filas A-C
    "Q2": 0, // Cuadrante 2: columnas 5-9, filas A-C
    "Q3": 0, // Cuadrante 3: columnas 0-4, filas D-F
    "Q4": 0 // Cuadrante 4: columnas 5-9, filas D-F
  };

  for (int i = 0; i < minesTotals; i++) {
    int fila, columna;
    String cuadrante;

    do {
      fila = random.nextInt(6) + 1; // Índices de 1 a 6 (filas A-F)
      columna = random.nextInt(10) + 1; // Índices de 1 a 10 (columnas 0-9)

      // Determinar a qué cuadrante pertenece la celda
      if (columna <= 5 && fila <= 3) {
        cuadrante = "Q1";
      } else if (columna > 5 && fila <= 3) {
        cuadrante = "Q2";
      } else if (columna <= 5 && fila > 3) {
        cuadrante = "Q3";
      } else {
        cuadrante = "Q4";
      }

      // Verificar que el cuadrante no tenga ya 2 minas y la celda no esté ocupada
    } while (
        contadorMinas[cuadrante]! >= 2 || matriuMines[fila][columna] == "#");

    // Colocar la mina y actualizar el conteo del cuadrante
    matriuMines[fila][columna] = "#";
    contadorMinas[cuadrante] = contadorMinas[cuadrante]! + 1;
  }
}

void printaTaulers() {
  if (trampas) {
    print(
        "\n------- TAULELL -------           ------- TAULELL DESTAPAT -------\n");
    for (int i = 0; i < matriu.length; i++) {
      String filaMatriu = matriu[i].join(" ");
      String filaTresors = matriuMines[i].join(" ");
      print(filaMatriu + "                  " + filaTresors);
    }
    print("");
  } else {
    print("\n------- TAULELL -------\n");
    for (var fila in matriu) {
      print(fila.join(" "));
    }
    print("");
  }
}

bool destapaCasellaRecursiva(
    int x, int y, bool esPrimeraJugada, bool esJugadaUsuari) {
  // Verifica si las coordenadas están fuera del tablero o si la casilla ya está descubierta
  if (x < 1 ||
      x >= matriu.length ||
      y < 1 ||
      y >= matriu[0].length ||
      matriu[x][y] != "·" ||
      matriu[x][y] == "F") {
    return false;
  }

  // Verifica si la casilla contiene una mina
  if (matriuMines[x][y] == "#") {
    if (esPrimeraJugada) {
      mouBomba(x, y);
      return destapaCasellaRecursiva(x, y, false, esJugadaUsuari);
    } else if (esJugadaUsuari) {
      return true; // Explosión
    } else {
      return false; // No explota durante la recursividad
    }
  }

  // Cuenta las minas adyacentes
  int numMines = comptaMinesAdjacents(x, y);
  matriu[x][y] = numMines == 0 ? " " : numMines;

  // Si no hay minas alrededor, destapa las casillas adyacentes
  if (numMines == 0) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx != 0 || dy != 0) {
          destapaCasellaRecursiva(x + dx, y + dy, false, false);
        }
      }
    }
  }

  return false; // No explota
}

void mouBomba(int x, int y) {
  matriuMines[x][y] = "·"; // Elimina la bomba de la casilla actual
  Random random = Random();

  // Encuentra una posición vacía aleatoria
  List<List<int>> posicionsBuides = [];
  for (int i = 1; i < matriuMines.length; i++) {
    for (int j = 1; j < matriuMines[i].length; j++) {
      if (matriuMines[i][j] != "#" && matriu[i][j] == "·") {
        posicionsBuides.add([i, j]);
      }
    }
  }

  if (posicionsBuides.isNotEmpty) {
    posicionsBuides.shuffle();
    List<int> novaPosicio = posicionsBuides.first;
    matriuMines[novaPosicio[0]][novaPosicio[1]] = "#";
  }
}

int comptaMinesAdjacents(int x, int y) {
  int count = 0;
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      int nx = x + dx;
      int ny = y + dy;
      if (nx >= 1 &&
          nx < matriuMines.length &&
          ny >= 1 &&
          ny < matriuMines[0].length &&
          matriuMines[nx][ny] == "#") {
        count++;
      }
    }
  }
  return count;
}

void posaBanderas() {
  stdout.write("Introdueix la casella (ex: A5): ");
  String? casella = stdin.readLineSync();
  bool banderaOk = false;
  while (!banderaOk) {
    while (casella!.length != 2 ||
        !filaIndices.keys.contains(casella[0].toUpperCase()) ||
        !nums.contains(casella[1])) {
      print("Coordenades invalides!");

      stdout.write("Introdueix la casella (ex: A5): ");
      casella = stdin.readLineSync();
    }
    // Convertir la fila y columna a índices
    int fila = filaIndices[casella[0].toUpperCase()]!;
    int columna = int.parse(casella[1]) + 1;

    print("ANTES DE WHILE");
    print("-${matriu[fila][columna]}-");

    if (matriu[fila][columna] == " ") {
      print("La casella no pot estar buida!");
    } else if (matriu[fila][columna] == "F") {
      matriu[fila][columna] = "·";
      banderaOk = true;
    } else {
      matriu[fila][columna] = "F";
      banderaOk = true;
    }
    casella = "";
  }
}

bool derrota = false;
bool victoria = false;
bool exit = false;

Future<void> main() async {
  enterraMines();

  while (!exit && !derrota && !victoria) {
    printaTaulers();
    print(menu);
    stdout.write("Opcio: ");
    String opcion = stdin.readLineSync()!.toLowerCase();

    switch (opcion) {
      case "1":
      case "escollir casella":
      case "casella":
        stdout.write("Introdueix la casella (ex: A5): ");
        String? casella = stdin.readLineSync();

        while (casella!.length != 2 ||
            !filaIndices.keys.contains(casella[0].toUpperCase()) ||
            !nums.contains(casella[1])) {
          print("Coordenades invalides!");

          stdout.write("Introdueix la casella (ex: A5): ");
          casella = stdin.readLineSync();
        }
        // Convertir la fila y columna a índices
        int fila = filaIndices[casella[0].toUpperCase()]!;
        int columna = int.parse(casella[1]) + 1;

        if (destapaCasellaRecursiva(fila, columna, esPrimeraJugada, true)) {
          print("Has destapat una mina! Has perdut.");
          derrota = true;
        }

        if (esPrimeraJugada) {
          esPrimeraJugada = false;
        }

        break;

      case "2":
      case "posar bandera":
      case "bandera":
      case "flag":
        posaBanderas();
        break;

      case "3":
      case "trampa":
      case "cheat":
        trampas = !trampas;
        break;

      case "4":
      case "ajuda":
      case "help":
        print(menuAjuda);
        stdout.write("Press Enter to continue");
        stdin.readLineSync();
        break;

      case "0":
      case "sortir":
      case "exit":
      case "salir":
        print("¡Hasta la próxima!");
        exit = true;
        break;
      default:
        print("¡Opción inválida!");
    }
  }
}
