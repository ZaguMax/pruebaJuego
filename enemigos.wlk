import juego.*
import teclado.*
import wollok.game.*
import objetos.*
import personaje.*

class Sapo{

    var myPosition = game.at(6, 5)
    var property image = "sapo_abj.png"

    var frameActual = 0
    var moviendose = false
    var espera = (0..60).anyOne()
    var tileA = null
    var tileB = null
    var property dirActual = "abj"
    var posOrigenX = 0
    var posOrigenY = 0
    var posDestinoX = 0
    var posDestinoY = 0
    var vivo = true

    method position() = myPosition
    method position(p) { myPosition = p }

    method matar() {
    vivo = false
    moviendose = false
    frameActual = 0
    if (tileA != null) { game.removeVisual(tileA) }
    if (tileB != null) { game.removeVisual(tileB) }
    tileA = null
    tileB = null
    const enemigoMuerte = game.sound("enemigoMuerte.mp3")
    enemigoMuerte.volume(0.3)
    enemigoMuerte.play()

    image = "enemigoMuerte_1.png"   

    game.onTick(50, "enemigoMuerte", {
        frameActual = frameActual + 1
        if (frameActual < 7) {
            self.image("enemigoMuerte_" + frameActual + ".png")
        } else {
            game.removeTickEvent("enemigoMuerte")
            mapaEnemigos.remover(self)
            if (mapaEnemigos.objetos().isEmpty()) {
                game.removeTickEvent("movimientoSapo")
            }
            game.removeVisual(self)  
            if (posicionesDestino.hayEn(posDestinoX, posDestinoY)) {
                posicionesDestino.quitar(posDestinoX, posDestinoY)
} 
        }
    })
}

    method puedeMover(dir) {
        const deltas = self.deltasDe(dir)
        const nx = myPosition.x() + deltas.get(0)
        const ny = myPosition.y() + deltas.get(1)
        return !mapaParedes.hayEn(nx, ny) && !posicionesDestino.hayEn(nx, ny)
    }

    method dondeMover() {
        const numeroAleatorio = (1..2).anyOne()
        const dx = personaje.position().x() - myPosition.x()
        const dy = personaje.position().y() - myPosition.y()
        const dirX = if (dx > 0) "der" else "izq"
        const dirY = if (dy > 0) "arr" else "abj"

        if (numeroAleatorio == 1) {
            if (dx != 0 && self.puedeMover(dirX)) { dirActual = dirX }
            else if (dy != 0 && self.puedeMover(dirY)) { dirActual = dirY }
        } else {
            if (dy != 0 && self.puedeMover(dirY)) { dirActual = dirY }
            else if (dx != 0 && self.puedeMover(dirX)) { dirActual = dirX }
        }
    }

    method deltasDe(dir) {
        if (dir == "der") { return [1, 0] }
        else if (dir == "izq") { return [-1, 0] }
        else if (dir == "arr") { return [0, 1] }
        else { return [0, -1] }
    }

    method iniciarMovimiento() {
    game.onTick(30, "movimientoSapo", {
        if (vivo) {
            if (moviendose) {
                frameActual = frameActual + 1
                if (frameActual <= 21) {
                    tileA.image("sapo_" + dirActual + "_a_" + frameActual + ".png")
                    tileB.image("sapo_" + dirActual + "_b_" + frameActual + ".png")
                    if (frameActual == 10) {
                        myPosition = game.at(posDestinoX, posDestinoY)
                    }
                } 
                else {
                    game.removeVisual(tileA)
                    game.removeVisual(tileB)
                    tileA = null
                    tileB = null
                    image = "sapo_" + dirActual + ".png"
                    moviendose = false
                    espera = 20
                    posicionesDestino.quitar(posDestinoX, posDestinoY)  
                }
            } else if (espera > 0) {
                espera = espera - 1
            } else {
                self.dondeMover()
                if (self.puedeMover(dirActual)) {
                    const deltas = self.deltasDe(dirActual)
                    posOrigenX = myPosition.x()
                    posOrigenY = myPosition.y()
                    posDestinoX = posOrigenX + deltas.get(0)
                    posDestinoY = posOrigenY + deltas.get(1)
                    posicionesDestino.agregar(posDestinoX, posDestinoY)  
                    frameActual = 0
                    moviendose = true
                    tileA = new TileTransicion(position = game.at(posOrigenX, posOrigenY), image = "sapo_" + dirActual + "_a_1.png")
                    tileB = new TileTransicion(position = game.at(posDestinoX, posDestinoY), image = "sapo_" + dirActual + "_b_1.png")
                    game.addVisual(tileA)
                    game.addVisual(tileB)
                    image = "transparente.png"
                }
                else {
                    espera = 60
                }
            }
        }
    })
}
}

class Murcielago{
    var myPosition = game.at(6, 5)
    var property image = "mur_abj.png"

    var frameActual = 0
    var moviendose = false
    var tileA = null
    var tileB = null
    var property dirActual = "abj"
    var posOrigenX = 0
    var posOrigenY = 0
    var posDestinoX = 0
    var posDestinoY = 0

    method position() = myPosition
    method position(p) { myPosition = p }

    method matar() {
    game.removeTickEvent("movimientoMurcielago")
    frameActual = 0

    const enemigoMuerte = game.sound("enemigoMuerte.mp3")
    enemigoMuerte.volume(0.3)
    enemigoMuerte.play()
    
    if (tileA != null) { game.removeVisual(tileA) }
    if (tileB != null) { game.removeVisual(tileB) }
    
    game.onTick(50, "enemigoMuerte", {

        frameActual = frameActual + 1
        if (frameActual < 7) {
            self.image("enemigoMuerte_" + frameActual + ".png")
        } else {
            game.removeTickEvent("enemigoMuerte")
            mapaEnemigos.remover(self)
            game.removeVisual(self)
        }
    })
}

    method puedeMover(dir) {
        const deltas = self.deltasDe(dir)
        const nx = myPosition.x() + deltas.get(0)
        const ny = myPosition.y() + deltas.get(1)
        return !mapaParedes.hayEn(nx, ny)
    }

    method deltasDe(dir) {
        if (dir == "arr") { return [0, 1] }
        else { return [0, -1] }
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

        tileA = new TileTransicion(position = game.at(posOrigenX, posOrigenY), image = "mur_" + dir + "_a_1.png")
        tileB = new TileTransicion(position = game.at(posDestinoX, posDestinoY), image = "mur_" + dir + "_b_1.png")
        game.addVisual(tileA)
        game.addVisual(tileB)
        image = "transparente.png"

        game.onTick(30, "movimientoMurcielago", {
        frameActual = frameActual + 1
        if (frameActual <= 21) {
            tileA.image("mur_" + dirActual + "_a_" + frameActual + ".png")
            tileB.image("mur_" + dirActual + "_b_" + frameActual + ".png")
        } 
        else {
            game.removeVisual(tileA)
            game.removeVisual(tileB)
            tileA = null
            tileB = null
            myPosition = game.at(posDestinoX, posDestinoY)
            image = "mur_" + dirActual + ".png"
            moviendose = false
        }
        })
    } 
    else if (!moviendose) {
        if(dir == "abj"){
            dirActual = "arr"
        }
        else {
            dirActual = "abj"
        }
        image = "mur_" + dirActual + ".png"
    }
    }
}