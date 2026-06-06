import gestorAnimacion.*
import juego.*
import personaje.*
import enemigos.*
import objetos.*

/*
    *  Este archivo contiene los datos de los niveles del juego.
    *  Cada nivel es representado por una matriz de enteros, donde cada entero representa un objeto o elemento del juego:
    *  - 0: Celda vacía
    *  - 0: Pared
    *  - 2: Moneda
    *  - 3: Sapo (enemigo)
    *  - 0: Pinchos
    *
    *  Puedes agregar más niveles siguiendo el mismo formato.
*/

object gestorNiveles
{
    var property nivelActual = 1
    const niveles = [nivel_1, nivel_2, nivel_3]

    method iniciarJuego()
    {
        nivelActual = 1
        self.cargarNivelActual()
    }

    method cargarNivelActual()
    {
        game.clear()
        juego.mapaObjetos.clear()
        game.addVisual(personaje)
        personaje.position(game.at(5, 4))

        const mapa = niveles.get(nivelActual-1).mapaData()
        const background = niveles.get(nivelActual-1).background()

        self.construirMapa(mapa)
        animadorGlobal.iniciar()
        gestorDeEnemigos.comenzarMovimiento()
    }

    method construirMapa(mapa)
    {
        const altoMatriz = mapa.size()
        // Recorrer los índices de las filas (Eje Y)
        (0 .. altoMatriz - 1).forEach
        ({
            indexFila => 
            const fila = mapa.get(indexFila)
            const anchoFila = fila.size()

            (0 .. anchoFila - 1).forEach
            ({ 
                indexColumna =>
                const celda = fila.get(indexColumna)

                const posX = indexColumna
                const posY = altoMatriz - 1 - indexFila
                const posicionActual = game.at(posX, posY)

                // Spawnear celda correspondiente

                if (celda == 1)
                { 
                    juego.mapaObjetos.paredes().add(new Collision(position = posicionActual))
                }
                
                if (celda == 2)
                {
                    const moneda = new Moneda(position = posicionActual)
                    juego.mapaObjetos.monedas().add(moneda)
                    game.addVisual(moneda)
                    animadorGlobal.añadir(moneda)
                }
                
                if (celda == 3)
                {
                    const sapo = new Sapo(position = posicionActual)
                    sapo.prepararVisuales()
                    game.addVisual(sapo)
                    gestorDeEnemigos.añadir(sapo)
                }
                
                if (celda == 4) {
                    const pincho = new Pinchos(position = posicionActual)
                    juego.mapaObjetos.pinchos().add(pincho)
                    game.addVisual(pincho)
                }

                if (celda == 5)
                {
                    juego.mapaObjetos.paredes().add(new Collision(position = posicionActual))
                    const antorcha = new AntorchaArr(position = posicionActual)
                    game.addVisual(antorcha)
                    animadorGlobal.añadir(antorcha)
                }
            })
        })
    }
}

class Nivel
{
    method mapaData() = []
    method background() = null
}

object nivel_1 inherits Nivel {

    override method background() = "nivel_2.png"

    override method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 5, 1, 1, 1, 1, 1, 1, 1],
        [0, 0, 1, 1, 5, 1, 1, 0, 0, 1, 0, 0, 3, 0, 0, 0, 1, 0, 0, 1],
        [0, 1, 1, 0, 0, 2, 1, 0, 0, 1, 1, 0, 3, 0, 0, 0, 1, 0, 0, 1],
        [1, 1, 0, 3, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 3, 3, 0, 0, 0, 0, 1],
        [1, 3, 3, 3, 0, 0, 1, 1, 0, 0, 0, 0, 1, 3, 3, 0, 1, 1, 1, 1],
        [1, 3, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 3, 3, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    ]
}

object nivel_2 inherits Nivel {

}

object nivel_3 inherits Nivel {

}

