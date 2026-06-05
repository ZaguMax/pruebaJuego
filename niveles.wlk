import juego.*
import personaje.*
import enemigos.*
import objetos.*
import teclado.*

/*
    *  Este archivo contiene los datos de los niveles del juego.
    *  Cada nivel es representado por una matriz de enteros, donde cada entero representa un objeto o elemento del juego:
    *  - 0: Celda vacía
    *  - 1: Pared
    *  - 2: Moneda
    *  - 3: Sapo (enemigo)
    *  - 4: Pinchos
    *  - 5: Personaje (punto de inicio)
    *
    *  Puedes agregar más niveles siguiendo el mismo formato.
*/

class Nivel {
    var fondoMusic = null
    method siguienteNivel() = null
    method nivelActual() = null
    method mapaData() = []
    method interactuables() = [self.palancas()]
    method pisables() = [self.teletransportes()] 
    method palancas() = []
    method teletransportes() = []
    method background() = "" + self + ".png"

    method musica(){
        fondoMusic = game.sound("fondo" + (1..12).anyOne() +  ".mp3")
        fondoMusic.shouldLoop(true)
        fondoMusic.volume(0.2)
        game.schedule(1000, { fondoMusic.play()} )
    }

    method cargar() {
        controles.configurar()
        personaje.moviendose(false)
        self.musica()
        game.addVisual(fondo)
        self.interactuables().forEach({lista =>
            lista.forEach({ a => 
                game.addVisual(a)
                juego.mapaObjetos.interactuables().add(a)
                a.modo(1)
                a.puedeCerrar(true)
            })
        })

        self.pisables().forEach({lista =>
            lista.forEach({ a => 
                game.addVisual(a)
                a.animar()
                juego.mapaObjetos.pisables().add(a)
            })
        })
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
                if (celda == 5) {
                    if (self.nivelActual() == 1) {
                        spawn.position(game.at(x-1, y))
                        spawn.animar() 
                    } 
                    else {
                        game.addVisual(personaje)
                        personaje.position(game.at(x, y))
                    }
                }
                x = x + 1
            })
            y = y - 1
        })
    
        
    
        fondo.image(self.background())
        contadorMonedas.cargar()
    }

    method limpiar() {
        juego.mapaObjetos.paredes().clear()
        juego.mapaObjetos.enemigosActivos().clear()
        juego.mapaObjetos.monedas().clear()
        juego.mapaObjetos.pinchos().clear()
        juego.mapaObjetos.interactuables().clear()
        juego.mapaObjetos.pisables().clear()
        juego.mapaObjetos.destinoEnemigos().clear()
        try {
            fondoMusic.stop()
        }
        catch e : Exception {
            console.println("Se ignoró un error de música en la limpieza")
        }
        game.clear()
        //controles.configurar()
        personaje.moviendose(true)
    }

}

object nivel_1 inherits Nivel {

    override method nivelActual() = 1
    override method siguienteNivel() = nivel_2


    override method palancas()  =  [new Palanca(position = game.at(3,3), listaObjetos = [0, 1]),
                                    new Palanca(position = game.at(16,5), listaObjetos = [2, 3])]

    override method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 5, 0, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 2, 1, 2, 0, 1],
        [1, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 1],
        [1, 0, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 2, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]
}

object nivel_2 inherits Nivel {

    override method nivelActual() = 2
    override method siguienteNivel() = nivel_3

    override method palancas() = []

    override method teletransportes() =[new Portal(position = game.at(18,2), dirDestino = [6,4]),
                                        new Portal(position = game.at(6,4), dirDestino = [18,2])]

    override method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0],
        [1, 0, 0, 0, 0, 5, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        [0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    ]

}

object nivel_3 inherits Nivel {

    override method nivelActual() = 3
    override method siguienteNivel() = nivel_4


    override method palancas()  =  [new Palanca(position = game.at(3,3), listaObjetos = [0, 1]),
                                    new Palanca(position = game.at(16,5), listaObjetos = [2, 3])]

    override method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 5, 0, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 2, 1, 2, 0, 1],
        [1, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 1],
        [1, 0, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 2, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]

}

object nivel_4 {
  
}
