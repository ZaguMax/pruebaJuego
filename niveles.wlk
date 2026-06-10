import gestorAnimacion.*
import juego.*
import personaje.*
import enemigos.*
import objetos.*
import teclado.*

/*
    *  Este archivo contiene los datos de los niveles del juego.
    *  Cada nivel es representado por una matriz de enteros, donde cada entero representa un objeto o elemento del juego:
    *  - 0: Celda vacía
    *  - 0: Pared
    *  - 2: Moneda
    *  - 3: Sapo (enemigo)
    *  - 4: Pinchos
    *  - 67: Personaje (punto de inicio)
    *  - 0: Pinchos
    *
    *  Puedes agregar más niveles siguiendo el mismo formato.
*/

object gestorNiveles
{
    var property nivelActual = 1
    const niveles = [null, nivel_1, nivel_2, nivel_3]
    var property musicaActual = null

    method pasarNivel() {
        nivelActual = nivelActual + 1 //niveles.indexOf(nivelActual)
        transition.active()
    }

    method iniciarJuego()
    {
        self.cargarNivelActual()
    }

    method descargarNivel()
    {   
        game.clear()
        juego.mapaObjetos.clear()
        gestorDeEnemigos.limpiarTodo()

        if(musicaActual != null) musicaActual.stop()
    }

    method cargarNivelActual()
    {
        // referencias
        const nivel = niveles.get(nivelActual)
        const mapa = nivel.mapaData()
        const background = nivel.background()

        // construccion del mapa
        game.addVisual(background)
        self.construirMapa(mapa, nivel)

        // Crear interfaz
        contadorMonedas.cargar()

        // inicializacion de animaciones y movimiento de enemigos
        animadorGlobal.iniciar()
        gestorDeEnemigos.comenzarMovimiento()

        //musica
        musicaActual = game.sound(nivel.musicaNivel())
        musicaActual.shouldLoop(true)
        musicaActual.volume(0.1)
        game.schedule(1000, { musicaActual.play() })

        // personaje
        //game.addVisual(personaje)
        //personaje.position(game.at(5, 4))


        personaje.moviendose(false)
        controles.configurar()
    }

    method construirMapa(mapa, nivel)
    {
        nivel.interactuables().forEach({lista => lista.forEach({ a => game.addVisual(a) juego.mapaObjetos.interactuables().add(a) a.modo(1) a.puedeCerrar(true) })})
        nivel.pisables().forEach({lista => lista.forEach({ a => game.addVisual(a) a.animar() juego.mapaObjetos.pisables().add(a) })})
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

                self.procesarCelda(celda, posX, posY)
            })
        })
        gestorDeEnemigos.enemigosActivos().forEach({e => e.actualizar()})
    }

    method procesarCelda(celda, x, y) {
        if (celda == 1)     { self.crearPared(x, y) }
        if (celda == 2)     { self.crearMoneda(x, y) }
        if (celda == 3)     { self.crearSapo(x, y) }
        if (celda == 4)     { self.crearPincho(x, y) }
        if (celda == 5)     { self.crearMurcielago(x, y)}         
        if (celda == 67)    { self.crearSpawnPersonaje(x, y) }
    }

    method crearPared(x, y) {
        juego.mapaObjetos.paredes().add(new Collision(position = game.at(x, y)))
    }

    method crearMoneda(x, y) {
        const moneda = new Moneda(position = game.at(x,y))
        juego.mapaObjetos.monedas().add(moneda)
        game.addVisual(moneda)
        animadorGlobal.añadir(moneda)
    }

    method crearSapo(x, y) {
        const sapo = new Sapo(position = game.at(x,y))
        sapo.prepararVisuales()
        game.addVisual(sapo)
        gestorDeEnemigos.añadir(sapo)
    }

    method crearPincho(x, y) {
        const pincho = new Pinchos(position = game.at(x, y))
        juego.mapaObjetos.pinchos().add(pincho)
        game.addVisual(pincho)
    }

    method crearSpawnPersonaje(x, y) {
        if (self.nivelActual() == 1) {
            spawn.position(game.at(x - 1, y))
            spawn.animar() 
        } else {
            game.addVisual(personaje)
            personaje.position(game.at(x, y))
        }
    }

    method crearAntorcha(x, y)
    {
        juego.mapaObjetos.paredes().add(new Collision(position = game.at(x,y)))
        const antorcha = new AntorchaArr(position = game.at(x,y))
        game.addVisual(antorcha)
        animadorGlobal.añadir(antorcha)
    }

    method crearMurcielago(x, y) {
        const mur = new Mur(position = game.at(x,y))
        mur.prepararVisuales()
        game.addVisual(mur)
        gestorDeEnemigos.añadir(mur)
    }
}

object transition {
    var property image = "transparente.png"
    var property position = game.at(0, 0)
    var frameActual = 0

    method active()
    {
        personaje.moviendose(true)
        game.addVisual(self)

        game.onTick(10, "transition",
        {
            frameActual = frameActual + 1

            if (frameActual < 26) {
                self.image("transition_" + frameActual + ".png")
            } 
            else {
                game.removeTickEvent("transition")
                gestorNiveles.descargarNivel()
                self.desactive()
            }
        })
    }

    
    method desactive()
    {
        
        gestorNiveles.cargarNivelActual()
        game.removeVisual(self)
        game.addVisual(self)
        personaje.moviendose(true)

        game.onTick(10, "transition", {
        frameActual = frameActual - 1
            if (frameActual > 0) {
                self.image("transition_" + frameActual + ".png")
            } 
            else
            {
                game.removeTickEvent("transition")
                game.removeVisual(self)
                personaje.moviendose(false)
            }
        })
    }
}

class Fondo {
    var property image = "mapa1.png"
    var property position = game.at(0, 0)
}

class Nivel
{
    method background() = new Fondo(image = self.toString() + ".png")
    method mapaData() = []
    var property musicasFondo = ["fondo1.mp3", "fondo2.mp3"]

    method interactuables() = [self.palancas()]
    method pisables() = [self.teletransportes()] 

    method palancas() = []
    method teletransportes() = []

    method musicaNivel() = musicasFondo.get( (0..musicasFondo.size()-1).anyOne() )
}

object nivel_1 inherits Nivel
{
    override method palancas()  =  [new Palanca(position = game.at(3,3), listaObjetos = [0, 1]),
                                    new Palanca(position = game.at(16,5), listaObjetos = [2, 3])]

    override method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 67, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 2, 1, 2, 0, 1],
        [1, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 1],
        [1, 0, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 0, 5, 0, 0, 0, 0, 1],
        [1, 0, 0, 2, 0, 0, 0, 0, 4, 2, 0, 0, 0, 3, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 4, 2, 0, 0, 0, 3, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]
}

object nivel_2 inherits Nivel
{
    override method palancas() = []
    override method teletransportes() =[new Portal(position = game.at(18,2), dirDestino = [6,4]),
                                        new Portal(position = game.at(6,4), dirDestino = [18,2])]

    override method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 0, 67, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 5, 0, 0, 3, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1],
        [0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    ]

}

object nivel_3 inherits Nivel {

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
