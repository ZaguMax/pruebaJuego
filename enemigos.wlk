import juego.mapaObjetos
import teclado.*
import wollok.game.*
import objetos.*
import personaje.*
import gestorAnimacion.*

object gestorDeEnemigos
{
    const property enemigosActivos = []

    method comenzarMovimiento()
    {
        game.onTick(800, "movimientoEnemigos", {
            enemigosActivos.forEach({ enemigo => enemigo.mover() })
        })
    }

    method detenerMovimiento() {
        game.removeTickEvent("movimientoEnemigos")
    }
}


class Enemigo
{
    var property position
    var property dirActual = "abj"

    // variables para animar
    var property tileA = null
    var property tileB = null

    // Estados
    var estaVivo = true

    method name() = ""
    method image() = ""
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
        return !mapaParedes.hayEn(nx, ny) //!mapaObjetos.hayEn(nx, ny, mapaObjetos.paredes())
    }

    method inicializarAnimacion()
    {
        tileA = new TileTransicion(position = game.at(position.x(), position.y()),                              image = self.name() + "_" + dirActual + "_a_1.png")
        tileB = new TileTransicion(position = game.at(self.posicionDestino().x(), self.posicionDestino().y()),  image = self.name() + "_" + dirActual + "_b_1.png")

        game.addVisual(tileA)
        game.addVisual(tileB)
        //image = "transparente.png"
    }

    method mover()
    {
        const dx = personaje.position().x() - position.x()
        const dy = personaje.position().y() - position.y()
        const dirX = if (dx > 0) "der" else "izq"
        const dirY = if (dy > 0) "arr" else "abj"

        const numeroAleatorio = (1..2).anyOne()

        if (numeroAleatorio == 1)
        {
            if (self.puedeMoverseA(dirX)) dirActual = dirX
        }
        else
        {
            if (self.puedeMoverseA(dirY)) dirActual = dirY
        }

        self.inicializarAnimacion()
        animacionMovimiento.movimientoEntreCasillas(self, 21)
    }

    method matar()
    {
        estaVivo = false
        //mapaObjetos.enemigosActivos().remove(self)

        if (tileA != null) { game.removeVisual(tileA) tileA = null}
        if (tileB != null) { game.removeVisual(tileB) tileB = null}

        // Sonido de muerte
        const enemigoMuerte = game.sound("enemigoMuerte.mp3")
        enemigoMuerte.volume(0.5)
        enemigoMuerte.play()  

        animacionMovimiento.animacionMuerteEnemigo(self)
    }
}


class Sapo inherits Enemigo
{   
    override method name() = "sapo"
    override method image() = "sapo_abj.png"
}

class Murcielago inherits Enemigo
{
    override method name() = "mur"
    override method image() = "mur_abj.png"
}