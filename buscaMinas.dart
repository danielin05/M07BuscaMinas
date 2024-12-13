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
Les opcions: 1, escollir casella. ----> Escribint una casella (D2, A8, etc) destapes una casella
Les opcions: 2, posar bandera. ----> Escribint una casella (D2, A8, etc) poses una bandera.
Les opcions: 3, trampa, cheats. ----> Mostra el taulell amb les mines destapades.
Les opcions: 4, ajuda, help. ----> Son per mostrar aquest menu d'ajuda
Les opcions: 0, sortir, exit. ----> Serveixen per sortir del joc.
""";

int minesTotals = 8;
int minesRestants = 8;
int banderas = 0;
bool trampas = false;
List lletres = ["A", "B", "C", "D", "E", "F"];
List nums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

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
  print(
      "\n------- TAULELL -------           ------- TAULELL DESTAPAT -------\n");
  for (int i = 0; i < matriu.length; i++) {
    String filaMatriu = matriu[i].join(" ");
    String filaTresors = matriuMines[i].join(" ");
    print(filaMatriu + "                  " + filaTresors);
  }
  print("");
}

bool destapaCasella() {
  bool destapa = false;

  stdout.write("Introdueix la casella (ex: A5): ");
  String? casella = stdin.readLineSync();

  while (casella!.length != 2 ||
      !lletres.contains(casella[0].toUpperCase()) ||
      !nums.contains(casella[1])) {
    print("Coordenades invalides!");

    stdout.write("Introdueix la casella (ex: A5): ");
    casella = stdin.readLineSync();
  }

  print("X: " + casella[0] + " Y: " + casella[1]);

  return destapa;
}

Future<void> main() async {
  printaTaulers();
  enterraMines();
  printaTaulers();
  destapaCasella();
}
