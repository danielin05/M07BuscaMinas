import 'dart:convert';
import 'dart:io';
import 'dart:math';

List<List<dynamic>> matriu = [
  [" ", 0, 1, 2, 3, 4, 5, 6, 7],
  ["A", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["B", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["C", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["D", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["E", "·", "·", "·", "·", "·", "·", "·", "·"],
  ["F", "·", "·", "·", "·", "·", "·", "·", "·"]
];

List<List<dynamic>> matriuTresors = List.from(matriu);

Map<String, int> filaIndices = {"A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6};

const salto = '\n';

const menu = """
------ MENU ------
1: Ajuda
2: Carregar Partida
3: Guardar Partida
4: Trampa
5: Destapar
6: Puntuacio
0: Sortir
""";

const menuAjuda = """
------ MENU AJUDA ------
Les opcions: 1, ajuda, help. ----> Son per mostrar aquest menu d'ajuda
Les opcions: 2, carregar partida. ----> Carregaran la partida del arxiu que seleccionis.
Les opcions: 3, guardar partida. ----> Guardaran la partida per poder carregarla mes tard
Les opcions: 4, trampa, cheat. ----> Mostraran el taulell amb les caselles que tenen tressors destapades
Les opcions: 5, destapar. ----> Serviran per destapar una casella escribint x + y per exemple 'D7'
Les opcions: 6, puntuacio. ----> Serveixen per veure la puntuacio y les tirades restants
Les opcions: 0, sortir, exit. ----> Serveixen per sortir del joc. SI NO HAS GUARDAT AVANTS EL PROGRES ES PERDRA
""";

int tresorsRestants = 16;
int tiradas = 0;
int maxTiradas = 32;
bool trampas = false;

void enterraTresors() {
  Random random = Random();
  for (int i = 0; i < 16; i++) {
    int fila;
    int columna;
    do {
      fila = random.nextInt(6) + 1;
      columna = random.nextInt(8) + 1;
    } while (matriuTresors[fila][columna] == "#");
    matriuTresors[fila][columna] = "#";
  }
}

int distanciaTesoroMasCercano(int filaIndex, int columna) {
  int menorDistancia = 1000;
  for (int fila = 1; fila < matriuTresors.length; fila++) {
    for (int col = 1; col < matriuTresors[fila].length; col++) {
      if (matriuTresors[fila][col] == "#" && matriu[fila][col] != "O") {
        int distancia = (filaIndex - fila).abs() + (columna - col).abs();
        if (distancia < menorDistancia) {
          menorDistancia = distancia;
        }
      }
    }
  }
  return menorDistancia;
}

void printaTauler() {
  if (trampas) {
    printaTaulers();
  } else {
    print("\n------- TAULELL -------\n");
    for (var fila in matriu) {
      print(fila.join(" "));
    }
    print("");
  }
}

void printaTaulers() {
  print(
      "\n------- TAULELL -------           ------- TAULELL DESTAPAT -------\n");
  for (int i = 0; i < matriu.length; i++) {
    String filaMatriu = matriu[i].join(" ");
    String filaTresors = matriuTresors[i].join(" ");
    print("  \$filaMatriu                      \$filaTresors");
  }
  print("");
}

Future<void> main() async {
  enterraTresors();
  printaTauler();
  print(menu);

  while (tiradas != maxTiradas && tresorsRestants != 0) {
    stdout.write("Opcio: ");
    String? opcion = stdin.readLineSync()?.trim().toLowerCase();

    switch (opcion) {
      case "1":
      case "ajuda":
      case "help":
        print(menuAjuda);
        stdin.readLineSync();
        break;
      case "2":
      case "carregar partida":
        break;
      case "3":
      case "guardar partida":
        break;
      case "4":
      case "trampa":
      case "cheat":
        trampas = !trampas;
        printaTauler();
        break;
      case "5":
      case "destapar":
        stdout.write("Introdueix la casella (ex: A5): ");
        String? casella = stdin.readLineSync();
        if (casella != null && casella.length == 2) {
          String fila = casella[0].toUpperCase();
          int columna = int.tryParse(casella[1]) ?? -1;

          if (filaIndices.containsKey(fila) && columna > 0 && columna < 9) {
            int filaIndex = filaIndices[fila]!;
            if (matriu[filaIndex][columna] == "·") {
              tiradas++;
              if (matriuTresors[filaIndex][columna] == "#") {
                matriu[filaIndex][columna] = "O";
                tresorsRestants--;
                print("Tresor trobat!");
              } else {
                int distancia = distanciaTesoroMasCercano(filaIndex, columna);
                matriu[filaIndex][columna] = distancia.toString();
                print("Res trobat. Distància al tresor més proper: $distancia");
              }
            } else {
              print("Casella ja destapada!");
            }
          } else {
            print("Casella no vàlida.");
          }
        } else {
          print("Format incorrecte. Utilitza una lletra i un número (ex: A5).");
        }
        printaTauler();
        break;
      case "6":
      case "puntuacio":
        break;
      case "0":
      case "sortir":
      case "exit":
        print("Sortint del joc...");
        return;
      default:
        print("Opció no reconeguda.");
    }
  }

  if (tresorsRestants == 0) {
    print("Felicitats! Has trobat tots els tresors!");
  } else if (tiradas == maxTiradas) {
    print("Fi del joc. No tens més tirades.");
  }
}
