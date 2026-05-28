import enemigos.*
import juego.*
import teclado.*
import wollok.game.*
import objetos.*

object personaje {

  var myPosition = game.at(6, 5)
  var property image = "pj_abj.png"

  var moviendose = false
  var atacando = false
  var frameActual = 0
  var tileA = null
  var tileB = null
  var dirActual = "abj"
  var posOrigenX = 0
  var posOrigenY = 0
  var posDestinoX = 0
  var posDestinoY = 0

  method position() = myPosition
  method position(p) { myPosition = p }

  method moviendose() = moviendose

  method moverDerecha() { self.iniciarMovimiento("der") }
  method moverIzquierda() { self.iniciarMovimiento("izq") }
  method moverArriba() { self.iniciarMovimiento("arr") }
  method moverAbajo() { self.iniciarMovimiento("abj") }
  method ataque() { self.atacar(dirActual) }

  method puedeAtacar() = !atacando && !moviendose

  method puedeMover(dir) {
    const deltas = self.deltasDe(dir)
    const nx = myPosition.x() + deltas.get(0)
    const ny = myPosition.y() + deltas.get(1)
    return !atacando && !moviendose && !mapaParedes.hayEn(nx, ny)
  }

  method deltasDe(dir) {
    if (dir == "der") { return [1, 0] }
    else if (dir == "izq") { return [-1, 0] }
    else if (dir == "arr") { return [0, 1] }
    else { return [0, -1] }
  }

  method atacar(dir) {
    if (self.puedeAtacar()) {
      const deltas = self.deltasDe(dir)
      atacando = true
      frameActual = 0
      dirActual = dir
      posOrigenX = myPosition.x()
      posOrigenY = myPosition.y()
      posDestinoX = posOrigenX + deltas.get(0)
      posDestinoY = posOrigenY + deltas.get(1)

      mapaEnemigos.enemigosEn(posDestinoX, posDestinoY).forEach({ e => e.matarSapo() })

      const sword = game.sound("sword" + (1..3).anyOne() + ".mp3")
      sword.volume(0.3)
      sword.play()

      tileA = new TileTransicion(position = game.at(posOrigenX, posOrigenY), image = "swrd_" + dir + "_a_1.png")
      tileB = new TileTransicion(position = game.at(posDestinoX, posDestinoY), image = "swrd_" + dir + "_b_1.png")
      game.addVisual(tileA)
      game.addVisual(tileB)

      game.onTick(5, "ataque", {
        frameActual = frameActual + 1
        if (frameActual <= 9) {
          tileA.image("swrd_" + dirActual + "_a_" + frameActual + ".png")
          tileB.image("swrd_" + dirActual + "_b_" + frameActual + ".png")
        } else {
          game.removeVisual(tileA)
          game.removeVisual(tileB)
          tileA = null
          tileB = null
          game.removeTickEvent("ataque")
          atacando = false
        }
      })
    }
  }

  method iniciarMovimiento(dir) {
    const deltas = self.deltasDe(dir)
    if (self.puedeMover(dir)) {
      moviendose = true
      frameActual = 0
      dirActual = dir
      posOrigenX = myPosition.x()
      posOrigenY = myPosition.y()
      posDestinoX = posOrigenX + deltas.get(0)
      posDestinoY = posOrigenY + deltas.get(1)

      tileA = new TileTransicion(position = game.at(posOrigenX, posOrigenY), image = "pj_" + dir + "_a_1.png")
      tileB = new TileTransicion(position = game.at(posDestinoX, posDestinoY), image = "pj_" + dir + "_b_1.png")
      game.addVisual(tileA)
      game.addVisual(tileB)
      image = "transparente.png"

      game.onTick(30, "movimiento", {
        frameActual = frameActual + 1
        if (frameActual <= 21) {
          tileA.image("pj_" + dirActual + "_a_" + frameActual + ".png")
          tileB.image("pj_" + dirActual + "_b_" + frameActual + ".png")
        } else {
          game.removeVisual(tileA)
          game.removeVisual(tileB)
          tileA = null
          tileB = null
          myPosition = game.at(posDestinoX, posDestinoY)
          image = "pj_" + dirActual + ".png"
          game.removeTickEvent("movimiento")
          moviendose = false
        }
      })
    } else if (!atacando && !moviendose) {
      dirActual = dir
      image = "pj_" + dirActual + ".png"
    }
  }
}

object mapaParedes {
  const objetos = []
  const claves = []
  
  method agregar(obj) {
    objetos.add(obj)
    claves.add("" + obj.position().x() + "," + obj.position().y())
  }
  
  method hayEn(x, y) = claves.contains("" + x + "," + y)
}

object mapaEnemigos {
  const objetos = []
  method agregar(obj) { objetos.add(obj) }
  method remover(obj) { objetos.remove(obj) }
  method contiene(obj) = objetos.contains(obj)
  method hayEn(x, y) = objetos.any({ o => o.position().x() == x && o.position().y() == y })
  method enemigosEn(x, y) = objetos.filter({ o => o.position().x() == x && o.position().y() == y })
}

class TileTransicion {
  var property position
  var property image

  method image(nuevaImagen) {
    image = nuevaImagen
  }
}