import juego.mapaObjetos
import juego.spawn
import enemigos.*
import teclado.*
import wollok.game.*
import objetos.*
import gestorAnimacion.*

object personaje {

  var myPosition = game.at(6, 5)
  var property image = "pj_abj.png"

  

  var property monedas = 0
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
  
  method puedeInteractuar(dir){
    const deltas = self.deltasDe(dir)
    const nx = myPosition.x() + deltas.get(0)
    const ny = myPosition.y() + deltas.get(1)
    return !atacando && !moviendose && mapaObjetos.hayEn(nx, ny, mapaObjetos.palancas())
  } 

  method puedeMover(dir) {
    const deltas = self.deltasDe(dir)
    const nx = myPosition.x() + deltas.get(0)
    const ny = myPosition.y() + deltas.get(1)
    return !atacando && !moviendose && !mapaObjetos.hayEn(nx, ny, mapaObjetos.paredes()) && !spawn.spawning()
  }

  method deltasDe(dir) {
    if (dir == "der") { return [1, 0] }
    else if (dir == "izq") { return [-1, 0] }
    else if (dir == "arr") { return [0, 1] }
    else { return [0, -1] }
  }

  method interact() {
    if (self.puedeInteractuar(dirActual)){
      const deltas = self.deltasDe(dirActual)
      const nx = myPosition.x() + deltas.get(0)
      const ny = myPosition.y() + deltas.get(1)
      mapaObjetos.palancas().find({palanca => palanca.position() == game.at(nx,ny)}).actuar()
    }
  }

  method atacar(dir) {
    const deltas = self.deltasDe(dir)
    posOrigenX = myPosition.x()
    posOrigenY = myPosition.y()
    posDestinoX = posOrigenX + deltas.get(0)
    posDestinoY = posOrigenY + deltas.get(1)
    if (self.puedeAtacar() && !mapaObjetos.hayEn(posDestinoX, posDestinoY, mapaObjetos.paredes())) {
      const deltas = self.deltasDe(dir)
      atacando = true
      frameActual = 0
      dirActual = dir
      posOrigenX = myPosition.x()
      posOrigenY = myPosition.y()
      posDestinoX = posOrigenX + deltas.get(0)
      posDestinoY = posOrigenY + deltas.get(1)

      mapaObjetos.enemigosEn(posDestinoX, posDestinoY).forEach({ e => e.matar() })

      const sword = game.sound("sword" + (1..3).anyOne() + ".mp3")
      sword.volume(0.3)
      sword.play()

      tileA = new TileTransicion(position = game.at(posOrigenX, posOrigenY), image = "swrd_" + dir + "_a_1.png")
      tileB = new TileTransicion(position = game.at(posDestinoX, posDestinoY), image = "swrd_" + dir + "_b_1.png")
      game.addVisual(tileA)
      game.addVisual(tileB)

      game.onTick(6, "ataque", {
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
    else if (self.puedeAtacar() && mapaObjetos.hayEn(posDestinoX, posDestinoY, mapaObjetos.paredes())) {
      const deltas = self.deltasDe(dir)
      atacando = true
      frameActual = 0
      dirActual = dir
      posOrigenX = myPosition.x()
      posOrigenY = myPosition.y()
      posDestinoX = posOrigenX + deltas.get(0)
      posDestinoY = posOrigenY + deltas.get(1)

      const sword = game.sound("swordMetal.mp3")
      sword.volume(0.3)
      sword.play()
    
      const sword2 = game.sound("sword" + (1..3).anyOne() + ".mp3")
      sword2.volume(0.3)
      sword2.play()

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
        } 
        else {
          if (mapaObjetos.hayEn(posDestinoX, posDestinoY, mapaObjetos.monedas())) {
            mapaObjetos.monedas().find({ m => m.position().x() == posDestinoX && m.position().y() == posDestinoY }).agarrar()
          }
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
  const claves = []
  
  method agregar(x, y) {
    claves.add("" + x + "," + y)
  }

  method quitar(x, y) {
    claves.remove("" + x + "," + y)
  }
  
  method hayEn(x, y) = claves.contains("" + x + "," + y)
}

object mapaPalancas {
  const property claves = []
  method agregar(palanca) {
    claves.add(palanca)
  }

  method hayEn(x, y){
    return claves.any({palanca => palanca.position() == game.at(x, y)})
  }
}

object mapaMonedas {
  const property monedas = []

  method agregar(moneda) {
    monedas.add(moneda)
  }

  method remover(moneda) {
    monedas.remove(moneda)
  }

  method monedaEn(x, y) = monedas.find({ m => m.position().x() == x && m.position().y() == y })

  method hayEn(x, y){
    return monedas.any({moneda => moneda.position() == game.at(x, y)})
  }
}

object mapaEnemigos {
  const property objetos = []
  method agregar(obj) { objetos.add(obj) }
  method remover(obj) { objetos.remove(obj) }
  method contiene(obj) = objetos.contains(obj)
  method hayEn(x, y) = objetos.any({ o => o.position().x() == x && o.position().y() == y })
  method enemigosEn(x, y) = objetos.filter({ o => o.position().x() == x && o.position().y() == y })
}

