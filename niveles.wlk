import gestorAnimacion.*
import juego.mapaObjetos
import personaje.*
import enemigos.*
import objetos.*
import teclado.*

/*
 * Este archivo contiene los datos de los niveles del juego.
 * Cada nivel es representado por una matriz de enteros, donde cada entero representa un objeto o elemento del juego:
 * - 0: Celda vacía
 * - 1: Pared
 * - 2: Moneda
 * - 3: Sapo (enemigo)
 * - 4: Pinchos (Abierto)
 * - 5: Pinchos (Cerrado)
 * - 6: Murciélago (enemigo)
 * - 7: Puerta Horizontal (Abierto)
 * - 8: Puerta Horizontal (Cerrado)
 * - 9: Puerta Vertical (Abierto)
 * - 10: Puerta Vertical (Cerrado)
 * - 11: Caja
 * - 67: Personaje (punto de inicio)
 *
 * Puedes agregar más niveles siguiendo el mismo formato.
 */

object gestorNiveles
{
    var property nivelActual = 1
    const niveles = [null, pantallaDeTitulo, nivel_1, nivel_2, nivel_3, nivel_4]
    var property musicaActual = null

    method pasarNivel() {
        nivelActual = nivelActual + 1 
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
        if (nivelActual != 1){
            contadorMonedas.cargar()  
        }
        

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
        if (nivelActual != 1){
            controles.configurar()
        }
        else {
            controlesMenu.configurar()
        }
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

        if (nivelActual > 2){
            personaje.actualizar()
        }
        
        gestorDeEnemigos.enemigosActivos().forEach({e => e.actualizar()})
        mapaObjetos.activables().filter({ e => e.nombre() == "laser" }).forEach({ e => e.iniciarLaser() })
        mapaObjetos.cajas().forEach({c => c.actualizar()})
    }

    method procesarCelda(celda, x, y) {
        if (celda == 1)     { self.crearPared(x, y) }
        if (celda == 2)     { self.crearMoneda(x, y) }
        if (celda == 3)     { self.crearSapo(x, y) }
        if (celda == 4)     { self.crearPincho(x, y, "Abierto") }
        if (celda == 5)     { self.crearPincho(x, y, "Cerrado") }
        if (celda == 6)     { self.crearMurcielago(x, y)}
        if (celda == 7)     { self.crearPuerta(x, y, "Horizontal", "Abierto") }
        if (celda == 8)     { self.crearPuerta(x, y, "Horizontal", "Cerrado") }
        if (celda == 9)     { self.crearPuerta(x, y, "Vertical", "Abierto") }  
        if (celda == 10)    { self.crearPuerta(x, y, "Vertical", "Cerrado") }  
        if (celda == 11)    { self.crearCaja(x,y)} 
        if (celda == 12)    { self.crearGato(x,y)}
        if (celda == 13)    { self.crearLaser(x, y, "izq", "Abierto")}
        if (celda == 14)    { self.crearLaser(x, y, "der", "Abierto")}
        if (celda == 15)    { self.crearLaser(x, y, "arr", "Abierto")}
        if (celda == 16)    { self.crearLaser(x, y, "abj", "Abierto")}
        if (celda == 17)    { self.crearLaser(x, y, "izq", "Cerrado")}
        if (celda == 18)    { self.crearLaser(x, y, "der", "Cerrado")}
        if (celda == 19)    { self.crearLaser(x, y, "arr", "Cerrado")}
        if (celda == 20)    { self.crearLaser(x, y, "abj", "Cerrado")}
        if (celda == 21)    { self.crearSalida(x, y, "izq")}
        if (celda == 22)    { self.crearSalida(x, y, "der")}
        if (celda == 23)    { self.crearAntorcha(x, y, "izq")}
        if (celda == 24)    { self.crearAntorcha(x, y, "der")}
        if (celda == 25)    { self.crearAntorcha(x, y, "arr")}
        if (celda == 26)    { self.crearAntorcha(x, y, "abj")}
        if (celda == 67)    { self.crearSpawnPersonaje(x, y) }
    }

    method crearAntorcha(x, y, dir) {
        const antorcha = new Antorcha(position = game.at(x,y), direccion = dir)
        game.addVisual(antorcha)
        antorcha.iniciarAntorcha()
        mapaObjetos.paredes().add(antorcha)
    }

    method crearSalida(x, y, dir) {
        const salida = new Salida(position = game.at(x, y), direccion = dir)
        game.addVisual(salida)
        mapaObjetos.pisables().add(salida)
        salida.actualizarDireccion()
    }

    method crearLaser(x, y, dir, estado) {
        const laser = new Laser(position = game.at(x, y), direccion = dir)
        game.addVisual(laser)
        if (estado == "Cerrado"){
            laser.abrir()
        }
        mapaObjetos.paredes().add(laser)
        mapaObjetos.activables().add(laser)
    }

    method crearGato(x,y) {
        const gato = new Gato(position = game.at(x,y))
        gato.prepararVisuales()
        game.addVisual(gato)
        gestorDeEnemigos.añadir(gato)
        gato.actualizarRumbo("der")
    }

    method crearCaja(x,y) {
        const collision = new Collision(position = game.at(x, y))
        const caja = new Bloque(position = game.at(x,y), collision = collision)
        caja.prepararVisuales()
        mapaObjetos.cajas().add(caja)
        game.addVisual(caja)
    }

    method crearPared(x, y) {
        juego.mapaObjetos.paredes().add(new Collision(position = game.at(x, y)))
    }

    method crearPuerta(x, y, dir, estado) {
        var posDir = null
        var imagenPredeterminada = null
        const collision = new Collision(position = game.at(x, y))
        if (dir == "Horizontal"){
            posDir = game.at(x-1, y)
            imagenPredeterminada = "PuertaHorizontal_1.png"
            mapaObjetos.paredes().add(collision)
        }
        else { 
            posDir = game.at(x, y-1)
            imagenPredeterminada = "PuertaVertical_1.png"
            mapaObjetos.paredes().add(collision) 
        }
        const puerta = new Puerta(position = posDir, direccion = dir, image = imagenPredeterminada, collision = collision)
            juego.mapaObjetos.activables().add(puerta)
            if (estado == "Abierto"){
                puerta.abrir()
            }
            game.addVisual(puerta)
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

    method crearPincho(x, y, estado) {
        const pincho = new Pinchos(position = game.at(x, y))
        juego.mapaObjetos.activables().add(pincho)
        if (estado == "Abierto"){
                pincho.abrir()
            }
        game.addVisual(pincho)
    }

    method crearSpawnPersonaje(x, y) {
        if (self.nivelActual() == 2) {
            spawn.position(game.at(x - 1, y))
            game.schedule(1000, {spawn.animar() })
        } 
        else {
            game.addVisual(personaje)
            personaje.position(game.at(x, y))
        }
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

            if (frameActual < 29) {
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
                personaje.movimiento(true)
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
    var property background = new Fondo(image = self.toString() + ".png")
    method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
        [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ]]
    method musicasFondo() = ["fondo1.mp3", "fondo2.mp3"]

    method interactuables() = [self.palancas()]
    method pisables() = [self.teletransportes(), self.botones()] 

    method palancas() = []
    method teletransportes() = []
    method botones() = []

    method musicaNivel() = self.musicasFondo().get( (0..self.musicasFondo().size()-1).anyOne() )
}

object nivel_1 inherits Nivel
{
    override method musicasFondo() = ["fondo1.mp3","fondo2.mp3","fondo3.mp3"]

    override method botones() =    [new Button(position = game.at(12,1), listaObjetos = [3]),
                                    new Button(position = game.at(8,1), listaObjetos = [4])]

    override method teletransportes() =[new Portal(position = game.at(13,7), dirDestino = [18,8]),
                                        new Portal(position = game.at(18,8), dirDestino = [13,7])]

    override method mapaData() = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
        [1 ,1 ,23,24,25,26,1 ,1 ,1 ,1 ,1 ,16,1 ,1 ,0 ,0 ,0 ,1 ,1 ,1 ,0 ],
        [1 ,0 ,0 ,3 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,1 ,0 ,0 ,1 ,0 ,1 ,0 ],
        [1 ,0 ,2 ,0 ,0 ,2 ,11,0 ,2 ,0 ,0 ,2 ,0 ,0 ,1 ,0 ,0 ,1 ,0 ,1 ,0 ],
        [1 ,0 ,0 ,11,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,13,1 ,0 ,0 ,1 ,2 ,1 ,0 ],
        [1 ,67,0 ,0 ,0 ,0 ,0 ,0 ,11,1 ,15,1 ,1 ,1 ,0 ,0 ,0 ,1 ,6 ,1 ,0 ],
        [1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,8 ,1 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,1 ,2 ,1 ,0 ],
        [1 ,0 ,0 ,10,0 ,0 ,12,0 ,0 ,1 ,0 ,1 ,1 ,1 ,1 ,1 ,0 ,0 ,0 ,1 ,0 ],
        [1 ,0 ,0 ,1 ,0 ,2 ,0 ,2 ,0 ,1 ,0 ,1 ,0 ,0 ,6 ,0 ,11,0 ,2 ,1 ,0 ],
        [1 ,0 ,21,1 ,1 ,0 ,0 ,0 ,0 ,1 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,0 ],
        [1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,0 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,0 ]]
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
        [1, 0, 6, 0, 0, 3, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0],
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

object nivel_4 inherits Nivel {
    override method musicasFondo() = ["fondo1.mp3","fondo2.mp3","fondo3.mp3"]
    override method palancas()  =  [new Palanca(position = game.at(3,2), listaObjetos = [0, 3, 4]),
                                    new Palanca(position = game.at(3,4), listaObjetos = [1, 2, 4]),
                                    new Palanca(position = game.at(3,6), listaObjetos = [0, 1])]

    override method mapaData() = [
        [0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
        [0 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
        [0 , 1 , 1 , 0 , 0 , 0 , 0 , 1 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
        [0 , 1 , 0 , 1 , 0 , 0 , 0 , 67 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
        [0 , 1 , 0 , 0 , 6 , 2 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 1 , 1 , 1 , 1 , 1 , 0 ],
        [0 , 1 , 0 , 1 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 1 , 0 ],
        [0 , 1 , 0 , 0 , 0 , 2 , 0 , 0 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 0 , 0 , 0 , 1 , 0 ],
        [0 , 1 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 10, 10, 10, 10, 9 , 11, 0 , 0 , 1 , 1 , 0 ],
        [0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 0 ],
        [0 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ]]
}

object pantallaDeTitulo inherits Nivel {

    var opcionActual = 0
    var canPress = true
    const menuButtons = ["menu_NewGame.png", "menu_Continue.png", "menu_Options.png", "menu_Exit.png"]
    const fondo = new Fondo(image = "menu_NewGame.png")
    
    override method musicasFondo() = ["menuMusic.mp3"]
    override method background() = fondo

    method opcionSiguiente() {
        opcionActual = opcionActual + 1
        if (opcionActual > 3) {
            opcionActual = 0
        }
        
        fondo.image(menuButtons.get(opcionActual))
    }

    method opcionAnterior() {
        opcionActual = opcionActual - 1
        if (opcionActual < 0) {
            opcionActual = 3
        }
        fondo.image(menuButtons.get(opcionActual))
    }

    method aceptar() {
        if (canPress){
            if(opcionActual == 0){
                gestorNiveles.pasarNivel()
                canPress = false
            }
            if (opcionActual == 3){
                game.stop()
            }
        }
    }
}
