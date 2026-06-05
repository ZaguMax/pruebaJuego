import juego.mapaObjetos
import teclado.*
import wollok.game.*
import objetos.*
import personaje.*
import gestorAnimacion.*

object gestorDeEnemigos
{
    const enemigosActivos = []

    method comenzarMovimiento()
    {
        game.onTick(1500, "movimientoEnemigos",
        {
            (0 .. enemigosActivos.size() - 1).forEach
            ({ 
                index =>
                const enemigo = enemigosActivos.get(index)
                
                game.schedule(index * 50, { 
                    enemigo.mover() 
                })
            })
        })
    }

    method detenerMovimiento() {
        game.removeTickEvent("movimientoEnemigos")
    }

    method añadir(enemigo) {
        enemigosActivos.add(enemigo)
    }

    method sacar(enemigo) {
        enemigosActivos.remove(enemigo)
    }
}


class Enemigo
{
    // Estados
    var estaVivo = true

    var property position
    var property dirActual = "abj"

    var property frameActual = 0 
    var property imagenActual = ""

    // Variables para animar
    const property tileA = new TileTransicion(position = game.at(0,0), image = "transparente.png")
    const property tileB = new TileTransicion(position = game.at(0,0), image = "transparente.png")

    method prepararVisuales()
    {
        game.addVisual(tileA)
        game.addVisual(tileB)
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
        return !mapaObjetos.hayEn(nx, ny, mapaObjetos.paredes())
    }

    method inicializarAnimacion()
    {
        frameActual = 0 
        
        tileA.position(game.at(position.x(), position.y()))
        tileA.image(self.name() + "_" + dirActual + "_a_1.png")

        tileB.position(game.at(self.posicionDestino().x(), self.posicionDestino().y()))
        tileB.image(self.name() + "_" + dirActual + "_b_1.png")
    
        self.image("transparente.png") 
    }

    method mover()
    {
        if (!estaVivo)
        {
            return
        }

        const dx = personaje.position().x() - position.x()
        const dy = personaje.position().y() - position.y()
        const dirX = if (dx > 0) "der" else "izq"
        const dirY = if (dy > 0) "arr" else "abj"

        const numeroAleatorio = (1..2).anyOne()

        if (numeroAleatorio == 1)
        {
            if (self.puedeMoverseA(dirX)) dirActual = dirX
            else if (self.puedeMoverseA(dirY)) dirActual = dirY 
        }
        else
        {
            if (self.puedeMoverseA(dirY)) dirActual = dirY
            else if (self.puedeMoverseA(dirX)) dirActual = dirX
        }

    
        if (self.puedeMoverseA(dirActual))
        {
            self.inicializarAnimacion()
            animacionMovimiento.movimientoEntreCasillas(self, 21)
        }

        return 
    }

    method matar()
    {
        estaVivo = false
        gestorDeEnemigos.sacar(self)

        tileA.image("transparente.png")
        tileB.image("transparente.png")

        const enemigoMuerte = game.sound("enemigoMuerte.mp3")
        enemigoMuerte.volume(0.5)
        enemigoMuerte.play()  

        frameActual = 0
        animacionMovimiento.animacionMuerteEnemigo(self)
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