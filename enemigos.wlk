import juego.mapaObjetos
import teclado.*
import wollok.game.*
import objetos.*
import personaje.*
import gestorAnimacion.*

object gestorDeEnemigos
{
    const property enemigosActivos = []
    var punteroEnemigo = 0

    method comenzarMovimiento()
    {
        game.onTick(200, "movimientoSecuencialEnemigos",
        {
            if (!enemigosActivos.isEmpty()) 
            {
                const enemigo = enemigosActivos.get(punteroEnemigo)
                enemigo.mover() 
                punteroEnemigo = (0..enemigosActivos.size() - 1).anyOne()
            }
        })
    }

    method detenerMovimiento() {
        game.removeTickEvent("movimientoSecuencialEnemigos")
    }

    method añadir(enemigo) { enemigosActivos.add(enemigo) }
    
    method sacar(enemigo)
    { 
        enemigosActivos.remove(enemigo)
        punteroEnemigo = 0 
    }

    method estaOcupadaOReservada(posicionDestino) {
        return enemigosActivos.any({ enemigo => 
            enemigo.position() == posicionDestino or enemigo.destinoTemporal() == posicionDestino
        })
    }
}


class Enemigo
{
    // Estados
    var estaVivo = true
    var property esperando = false

    var property position
    var property dirActual = "abj"

    var property frameActual = 0 
    var property imagenActual = ""
    var property destinoTemporal = null

    // Variables para animar
    const property tileA = new TileTransicion(position = game.at(0,0), image = "transparente.png")
    const property tileB = new TileTransicion(position = game.at(0,0), image = "transparente.png")

    var property poolActual = null

    method prepararVisuales()
    {
        game.addVisual(tileA)
        game.addVisual(tileB)
        self.actualizarRumbo("izq")
    }

    method actualizarRumbo(nuevaDir)
    {
        dirActual = nuevaDir
        poolActual = bancoDeImagenes.obtenerPool(self.name(), dirActual)
    }

    method name() = ""

    method image() = if (imagenActual == "") self.name() + "_" + dirActual + ".png" else imagenActual
    method image(nuevaImagen) { imagenActual = nuevaImagen }

    method deltaDir(dir)
    {
        if (dir == "der")       return [1,  0]
        else if (dir == "izq")  return [-1, 0]
        else if (dir == "arr")  return [0,  1]
        else                    return [0, -1]
    }

    method posicionDestino()
    {
        const delta = self.deltaDir(dirActual)
        const posX = position.x() + delta.get(0)
        const posY = position.y() + delta.get(1)

        return game.at(posX, posY)
    }

    method puedeMoverseA(dir)
{
    const deltas = self.deltaDir(dir)
    const nx = position.x() + deltas.get(0)
    const ny = position.y() + deltas.get(1)
    const posicionObjetivo = game.at(nx, ny)
    const sinPared = !mapaObjetos.hayEn(nx, ny, mapaObjetos.paredes())
    const sinEnemigos = !gestorDeEnemigos.estaOcupadaOReservada(posicionObjetivo)
    return sinPared and sinEnemigos
}

    method inicializarAnimacion()
    {
        frameActual = 0
        destinoTemporal = self.posicionDestino()
        
        tileA.position(game.at(position.x(), position.y()))
        tileA.image(self.name() + "_" + dirActual + "_a_1.png")

        tileB.position(destinoTemporal)
        tileB.image(self.name() + "_" + dirActual + "_b_1.png")
    
        self.image("transparente.png") 
    }

    method mover()
    {
        if (!estaVivo) return null
        if (self.esperando()) return null
        if(animadorGlobal.enemigosMoviendose().contains(self)) return null

        const dx = personaje.position().x() - position.x()
        const dy = personaje.position().y() - position.y()
        const dirX = if (dx > 0) "der" else "izq"
        const dirY = if (dy > 0) "arr" else "abj"

        const numeroAleatorio = (1..2).anyOne()

        if (numeroAleatorio == 1)
        {
            if (self.puedeMoverseA(dirX)) self.actualizarRumbo(dirX)
            else if (self.puedeMoverseA(dirY)) self.actualizarRumbo(dirY)
        }
        else
        {
            if (self.puedeMoverseA(dirY)) self.actualizarRumbo(dirY)
            else if (self.puedeMoverseA(dirX)) self.actualizarRumbo(dirX)
        }

    
        if (self.puedeMoverseA(dirActual))
        {
            self.inicializarAnimacion()
            animadorGlobal.enemigosMoviendose().add(self)
        }
        else {
            self.esperando(true)
            game.schedule(1500, { self.esperando(false) })
        }

        return null
    }

    method matar()
    {
        estaVivo = false
        gestorDeEnemigos.sacar(self)
        destinoTemporal = null
        animadorGlobal.enemigosMoviendose().remove(self)

        tileA.image("transparente.png")
        tileB.image("transparente.png")

        const enemigoMuerte = game.sound("enemigoMuerte.mp3")
        enemigoMuerte.volume(0.5)
        enemigoMuerte.play()  

        frameActual = 0
        animacionMovimiento.animacionMuerteEnemigo(self)
    }

    method actualizar() 
    {
        game.removeVisual(self)
        game.addVisual(self)
        game.removeVisual(tileA)
        game.addVisual(tileA)
        game.removeVisual(tileB)
        game.addVisual(tileB)
    }
}


class Sapo inherits Enemigo
{   
    override method name() = "sapo"
}

class Murcielago inherits Enemigo
{
    override method name() = "mur"
}