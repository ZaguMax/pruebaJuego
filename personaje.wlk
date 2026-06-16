import juego.mapaObjetos
import enemigos.*
import teclado.*
import wollok.game.*
import objetos.*
import gestorAnimacion.*

object personaje {
  

  var myPosition = game.at(6, 5)
  var property image = "pj_abj.png"

  var property movimiento = true
  var property tpeado = false
  var property monedas = 0
  var property moviendose = false
  var atacando = false
  var frameActual = 0
  var tileA = null
  var tileB = null
  var property dirActual = "abj"
  var posOrigenX = 0
  var posOrigenY = 0
  var posDestinoX = 0
  var posDestinoY = 0
  var property tpeando = false 

  method posicionDestino() {
    return game.at(posDestinoX, posDestinoY)
  }

  method añadirMoneda() {
    monedas +=1
  }

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
    return !atacando && !moviendose && mapaObjetos.hayEn(nx, ny, mapaObjetos.interactuables())
  } 

  method puedeMover(dir) {
    const deltas = self.deltasDe(dir)
    const nx = myPosition.x() + deltas.get(0)
    const ny = myPosition.y() + deltas.get(1)
    return !atacando && !moviendose && movimiento && !mapaObjetos.hayEn(nx, ny, mapaObjetos.paredes())
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
      mapaObjetos.interactuables().find({palanca => palanca.position() == game.at(nx,ny)}).actuar()
    }
  }

  method actualizar() {
    game.removeVisual(self)
    game.addVisual(self)
  }

  method atacar(dir) {
  if (self.puedeAtacar()) {
    const deltas = self.deltasDe(dir)
    posOrigenX = myPosition.x()
    posOrigenY = myPosition.y()
    posDestinoX = posOrigenX + deltas.get(0)
    posDestinoY = posOrigenY + deltas.get(1)
    atacando = true
    frameActual = 0
    dirActual = dir

    if (!mapaObjetos.hayEn(posDestinoX, posDestinoY, mapaObjetos.paredes())) {
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
    } else {
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
}

  method iniciarMovimiento(dir) {
    if (!moviendose && !atacando) {
        
        var velocidadMovimiento = 30
        const deltas = self.deltasDe(dir)
        const xSiguiente = myPosition.x() + deltas.get(0)
        const ySiguiente = myPosition.y() + deltas.get(1)
        var cajaPudoMoverse = true

        const hayCAjaMoviendoseAdelante = animadorGlobal.enemigosMoviendose()
            .filter({e => mapaObjetos.cajas().contains(e)})
            .any({caja => 
                caja.position() == game.at(xSiguiente, ySiguiente) || 
                caja.destinoTemporal() == game.at(xSiguiente, ySiguiente)
            })

        if (!hayCAjaMoviendoseAdelante) {
            if (mapaObjetos.cajas().any({caja => caja.position() == game.at(xSiguiente, ySiguiente) && caja.destinoTemporal() == null})) {
                const objetoAdelante = mapaObjetos.cajas().find({caja => caja.position() == game.at(xSiguiente, ySiguiente)})
                
                if (objetoAdelante.puedeMoverseA(dir)) {
                    velocidadMovimiento = 50
                    objetoAdelante.dirActual(dir)
                    objetoAdelante.mover()
                    cajaPudoMoverse = true
                } else {
                    cajaPudoMoverse = false 
                }
            }

            if (cajaPudoMoverse && self.puedeMover(dir)) {
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

                

                game.onTick(velocidadMovimiento, "movimiento", {
                    frameActual = frameActual + 1
                    if (frameActual <= 21) {
                        tileA.image("pj_" + dirActual + "_a_" + frameActual + ".png")
                        tileB.image("pj_" + dirActual + "_b_" + frameActual + ".png")
                      if (frameActual >= 10){
                        if (mapaObjetos.hayEn(posOrigenX, posOrigenY, mapaObjetos.pisables())) {
                            mapaObjetos.pisables().find({ m => m.position() == game.at(posOrigenX, posOrigenY) }).soltar()
                        }
                        myPosition = game.at(posDestinoX, posDestinoY)
                      }  
                    } 
                    else {
                        if (mapaObjetos.hayEn(posDestinoX, posDestinoY, mapaObjetos.monedas())) {
                            mapaObjetos.monedas().find({ m => m.position() == game.at(posDestinoX, posDestinoY) }).agarrar()
                        }
                        if (mapaObjetos.hayEn(posDestinoX, posDestinoY, mapaObjetos.pisables())) {
                            mapaObjetos.pisables().find({ m => m.position() == game.at(posDestinoX, posDestinoY) }).pisar()
                        }

                        if(mapaObjetos.activables()
                        .filter({ e => e.nombre() == "laser" })
                        .any({ e => e.estaEnLaser(game.at(posDestinoX, posDestinoY)) })){
                            //Aquí el personaje debe morir
                        }

                        game.removeVisual(tileA)
                        game.removeVisual(tileB)
                        tileA = null
                        tileB = null
                        
                        tpeado = false
                        
                        image = "pj_" + dirActual + ".png"
                        game.removeTickEvent("movimiento")
                        moviendose = false
                    }
                })
            } 
            else if (movimiento) {
                dirActual = dir
                image = "pj_" + dirActual + ".png"
            }
        }
        else {
            dirActual = dir
            image = "pj_" + dirActual + ".png"
        }
    } 
}

  method teletransportar(x, y) {
    const destino = new TileTransicion(position = game.at(x,y), image = "teleportPj_"+ dirActual + "_b_1.png")
    game.addVisual(destino)
    tpeando = true
    var frame = 0
    game.onTick(1, "teletransportePj", {
      frame = frame + 1
      if (frame < 7){
        moviendose = true
        image = "teleportPj_"+ dirActual + "_" + frame + ".png"
        destino.image("teleportPj_"+ dirActual + "_b_" + frame + ".png")
      }
      else{
        frame = 0
        game.removeTickEvent("teletransportePj")
        game.removeVisual(destino)
        self.position(game.at(x, y))
        image = "pj_" + dirActual + ".png"
        moviendose = false
      }   
    })
    
  }
}

object spawn {
    var property spawning = false
    var property position = game.at(0, 0) 
    var frameActual = 1
    var property image = "Spawn_1.png"

    method animar() {
        spawning = true
        personaje.dirActual("abj")
        personaje.image("pj" + personaje.dirActual() + ".png") 
        if (!game.allVisuals().contains(self)) {
            game.addVisual(self)
        }

        const audioSpawn = game.sound("spawn.mp3")
        audioSpawn.volume(0.3)
        audioSpawn.play()

        game.onTick(100, "eventoSpawn", {
            personaje.moviendose(true)
            self.image("Spawn_" + frameActual + ".png")
            frameActual = frameActual + 1

            if (frameActual > 14) {
                game.removeTickEvent("eventoSpawn")
                game.removeVisual(self)

                const posXPersonaje = self.position().x() + 1
                const posYPersonaje = self.position().y()

                game.addVisual(personaje)
                personaje.image("pj_abj.png")
                personaje.position(game.at(posXPersonaje, posYPersonaje))

                personaje.moviendose(false)
                spawning = false
                frameActual = 1 
            }
        })
    }
}