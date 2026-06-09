import personaje.*
import gestorAnimacion.*
import juego.mapaObjetos
import niveles.*
import enemigos.*

class Collision{
    var property position
}
class AntorchaArr{
    var property position
    var frameActual = 1

    const property frames = (0..7).map({ i => "AntorchaArr_" + i + ".png" })

    method image() = frames.get(frameActual)

    method siguienteFrame()
    {
        frameActual += 1
        if (frameActual > 7) frameActual = 1
    }
}

class AntorchaAbj inherits AntorchaArr
{
    override method image() = "AntorchaAbj_" + frameActual + ".png"
}

class Pinchos{
    var puedeCerrar = true
    var property position
    const collision = new Collision(position = position)
    var property modo = 1
    var frameActual = 0
    var property image = "PinchosCerrados.png"
    method abrir() {
        if (modo == 1 && puedeCerrar){frameActual = 0
        mapaObjetos.enemigosEn(position.x(),position.y() ).forEach({ e => e.matar() })
            game.onTick(100, "PinchoAbriendo", {
                frameActual = frameActual + 1
                if (frameActual < 7) {
                    self.image("PinchosAbriendo_" + frameActual + ".png")
                }
                else {
                    game.removeTickEvent("PinchoAbriendo")
                    modo = 0
                    self.image("PinchosAbiertos.png")
                    mapaObjetos.paredes().add(collision)
                }
            })
            puedeCerrar = false
        }
        
    }

    method cerrar() {
        if (modo == 0 && !puedeCerrar){frameActual = 6
            game.onTick(100, "PinchoCerrando", {
                frameActual = frameActual - 1
                if (frameActual > 0) {
                    self.image("PinchosAbriendo_" + frameActual + ".png")
                }
                else {
                    game.removeTickEvent("PinchoCerrando")
                    modo = 1
                    self.image("PinchosCerrados.png")
                    mapaObjetos.paredes().remove(collision)
                }
            })
            puedeCerrar = true
        }
    }
}

class Palanca{
    var property position
    var property listaObjetos 
    var property puedeCerrar = true
    method esPalanca() = true 
    var property modo = 1
    var frameActual = 0
    var property image = "PalancaCerrada.png"

    method actuar() {
        if (modo == 1){
            self.abrir()
        }
        else {
            self.cerrar()
        }
    }

    method abrir() {
        if (modo == 1 && puedeCerrar){frameActual = 0
            game.onTick(100, "PalancaAbriendo", {
                frameActual = frameActual + 1
                if (frameActual < 9) {
                    self.image("palanca_" + frameActual + ".png")
                }
                else {
                    game.removeTickEvent("PalancaAbriendo")
                    modo = 0
                    self.image("PalancaAbierta.png")
                }
            })
            listaObjetos.forEach({objeto => mapaObjetos.pinchos().get(objeto).abrir()})
            puedeCerrar = false
        }
        
    }

    method cerrar() {
        if (modo == 0 && !puedeCerrar){
            frameActual = 8
            game.onTick(100, "PalancaCerrando", {
                frameActual = frameActual - 1
                if (frameActual > 0) {
                    self.image("palanca_" + frameActual + ".png")
                }
                else {
                    game.removeTickEvent("PalancaCerrando")
                    modo = 1
                    self.image("PalancaCerrada.png")
                }
            })
            
            listaObjetos.forEach({objeto => mapaObjetos.pinchos().get(objeto).cerrar()})
            puedeCerrar = true
        }
    }
    
}

class Moneda
{
    var property position
    var frameActual = 1
    var subReloj = 0

    method image() = "coin_" + frameActual + ".png"

    method siguienteFrame()
    {
        subReloj += 1

        if(subReloj >= 3)
        {
            subReloj = 0
            frameActual += 1
            if (frameActual > 5) frameActual = 1
        }
    }

    method agarrar() {
        game.removeVisual(self)
        personaje.monedas(personaje.monedas() + 1)
        contadorMonedas.actualizar()

        mapaObjetos.monedas().remove(self)
        animadorGlobal.sacar(self)
        game.removeVisual(self)
    }
}

object contadorMonedas{
    var decenas = 0
    var unidades = 0   
    const decenasVisual = new TileTransicion(image = "0.png", position = game.at(16, 9))
    const unidadesVisual = new TileTransicion(image = "0.png", position = game.at(17, 9))
    const monedasVisual = new TileTransicion(image = "x.png", position = game.at(14, 9))

    method cargar() {
        game.addVisual(decenasVisual)
        game.addVisual(unidadesVisual)
        game.addVisual(monedasVisual)
        }

    method actualizar(){
        unidades = unidades + 1
        if (unidades == 10){
            unidades = 0
            decenas = decenas + 1
        }
        decenasVisual.image("" + decenas + ".png")
        unidadesVisual.image("" + unidades + ".png")
    }

}


class Portal{
    var property position
    var property dirDestino
    method esPalanca() = false 
    
    var frameActual = 0
    var property image = "portal_1.png"
    method animar() {
        game.onTick(500, "portal", {
        frameActual = frameActual + 1
            if (frameActual < 4) {
                self.image("portal_" + frameActual + ".png")
            } 
            else {
                frameActual = 0
            }
        })
    }
    method pisar() {
        personaje.moviendose(true)
        const tp = game.sound("tp_" + (1..2).anyOne() + ".mp3")
        tp.volume(0.3)
        if (!personaje.tpeado()){
            personaje.tpeado(true)
            tp.play()
            personaje.teletransportar(dirDestino.get(0), dirDestino.get(1))
            }
    }
}