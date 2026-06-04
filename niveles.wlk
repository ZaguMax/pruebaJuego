import juego.*
import personaje.*
import enemigos.*
import objetos.*

/*
    *  Este archivo contiene los datos de los niveles del juego.
    *  Cada nivel es representado por una matriz de enteros, donde cada entero representa un objeto o elemento del juego:
    *  - 0: Celda vacía
    *  - 1: Pared
    *  - 2: Moneda
    *  - 3: Sapo (enemigo)
    *  - 4: Pinchos
    *
    *  Puedes agregar más niveles siguiendo el mismo formato.
*/

class Nivel {
    method mapaData() = []

    method background() = null

    method cargar() {
        var y = self.mapaData().size() - 1
        self.mapaData().forEach({ fila =>
            var x = 0
            fila.forEach({ celda =>
                if (celda == 1) { 
                    const pared = new Collision(position = game.at(x, y))
                    juego.mapaObjetos.paredes().add(pared)
                }
                if (celda == 2) {
                    const moneda = new Coins(position = game.at(x, y))
                    juego.mapaObjetos.monedas().add(moneda)
                    game.addVisual(moneda)
                    moneda.animar()
                }
                if (celda == 3) {
                    const sapo = new Sapo(position = game.at(x, y))
                    juego.mapaObjetos.enemigosActivos().add(sapo)
                    game.addVisual(sapo)
                    sapo.iniciarMovimiento()
                }
                if (celda == 4) {
                    const pincho = new Pinchos(position = game.at(x, y))
                    juego.mapaObjetos.pinchos().add(pincho)
                    game.addVisual(pincho)
                }
                x = x + 1
            })
            y = y - 1
        })
    }
}

object nivel_1 inherits Nivel {

    override method background() = "nivel_1.png"

    override method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 4, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]
}

object nivel_2 inherits Nivel {

}

object nivel_3 inherits Nivel {

}

