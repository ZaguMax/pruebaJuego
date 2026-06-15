import personaje.*
import gestorAnimacion.*
import juego.mapaObjetos
import niveles.*
import enemigos.*

class Objeto {
    var property position 
    var property nombre = "" 
    var property frameActual = 0
    var property image = "default.png"

    method actualizarImagen() {
        self.image(nombre + "_" + frameActual + ".png")
    }

    method animar(totalFrames, ms, alTerminar) {
        frameActual = 0
        game.onTick(ms, "anim_adelante_" + self.identity().toString(), {
            frameActual += 1
            if (frameActual < totalFrames) {
                self.actualizarImagen()
            } else {
                game.removeTickEvent("anim_adelante_" + self.identity().toString())
                alTerminar.apply()
            }
        })
    }

    method animarReverse(totalFrames, ms, alTerminar) {
        frameActual = totalFrames - 1
        game.onTick(ms, "anim_atras_" + self.identity().toString(), {
            frameActual -= 1
            if (frameActual > 0) {
                self.actualizarImagen()
            } else {
                game.removeTickEvent("anim_atras_" + self.identity().toString())
                alTerminar.apply()
            }
        })
    }

    method animarLoop(totalFrames, ms) {
        frameActual = 0
        game.onTick(ms, "anim_loop_" + self.identity().toString(), {
            frameActual += 1
            if (frameActual > totalFrames) {
                frameActual = 1 
            }
            self.actualizarImagen()
        })
    }
}

class ObjetoAccionable inherits Objeto{

}

class Collision inherits Objeto {}

class AntorchaArr inherits Objeto(nombre = "AntorchaArr", image = "AntorchaArr_1.png") {
    method iniciar() {
        self.animarLoop(8, 100)
    }
}

class AntorchaAbj inherits Objeto(nombre = "AntorchaAbj", image = "AntorchaAbj_1.png") {
    method iniciar() {
        self.animarLoop(8, 100)
    }
}

class Pinchos inherits Objeto(nombre = "PinchosAbriendo", image = "PinchosCerrados.png") {
    var property modo = 1
    var property puedeCerrar = true
    const collision = new Collision(position = position)

    method actuar() {
        if (modo == 1) self.abrir() else self.cerrar()
    }

    method abrir() {
        if (modo == 1 && puedeCerrar) {
            puedeCerrar = false
            mapaObjetos.enemigosEn(position.x(), position.y()).forEach({ e => e.matar() })
            
            self.animar(7, 100, {
                modo = 0
                self.image("PinchosAbiertos.png")
                mapaObjetos.paredes().add(collision)
            })
        }
    }

    method cerrar() {
        if (modo == 0 && !puedeCerrar) {
            puedeCerrar = true 
            
            self.animarReverse(7, 100, {
                modo = 1
                self.image("PinchosCerrados.png")
                mapaObjetos.paredes().remove(collision)
            })
        }
    }
}

class Palanca inherits Objeto(nombre = "palanca", image = "PalancaCerrada.png") {
    var property listaObjetos 
    var property puedeCerrar = true
    var property modo = 1

    method actuar() {
        if (modo == 1) self.abrir() else self.cerrar()
    }

    method abrir() {
        if (modo == 1 && puedeCerrar) {
            puedeCerrar = false
            
            self.animar(9, 100, {
                modo = 0
                self.image("PalancaAbierta.png")
            })
            listaObjetos.forEach({ objeto => mapaObjetos.activables().get(objeto).actuar() })
        }
    }

    method cerrar() {
        if (modo == 0 && !puedeCerrar) {
            puedeCerrar = true
            
            self.animarReverse(9, 100, {
                modo = 1
                self.image("PalancaCerrada.png")
            })
            listaObjetos.forEach({ objeto => mapaObjetos.activables().get(objeto).actuar() })
        }
    }
}

class Moneda inherits Objeto(nombre = "coin") {
    var subReloj = 0

    override method image() = nombre + "_" + frameActual + ".png"

    method siguienteFrame() {
        subReloj += 1
        if (subReloj >= 3) {
            subReloj = 0
            frameActual += 1
            if (frameActual > 5) frameActual = 1
        }
    }

    method agarrar() {
        personaje.monedas(personaje.monedas() + 1)
        contadorMonedas.actualizar()

        const moneda = game.sound("agarrarMoneda.mp3")
        moneda.volume(0.4)
        moneda.play()

        mapaObjetos.monedas().remove(self)
        animadorGlobal.sacar(self)
        game.removeVisual(self) 
    }
}

object contadorMonedas {
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

    method actualizar() {
        unidades = unidades + 1
        if (unidades == 10) {
            unidades = 0
            decenas = decenas + 1
        }
        decenasVisual.image("" + decenas + ".png")
        unidadesVisual.image("" + unidades + ".png")
    }
}

class Portal inherits Objeto(nombre = "portal", image = "portal_1.png") {
    var property dirDestino
    
    method animar() {
        self.animarLoop(3, 500)
    }

    method pisar() {
        personaje.moviendose(true)
        const tp = game.sound("tp_" + (1..2).anyOne() + ".mp3")
        tp.volume(0.3)
        if (!personaje.tpeado()) {
            personaje.tpeado(true)
            tp.play()
            personaje.teletransportar(dirDestino.get(0), dirDestino.get(1))
        }
    }

    method soltar() {}
}

class Puerta inherits Objeto(nombre = "Puerta", image = "PuertaHorizontal_1.png"){
    const direccion
    var property modo = 1
    var property puedeCerrar = true
    const collision

    method collisionDir(){
        if (direccion == "Horizontal"){
            return (game.at(position.x()+1, position.y()))
        } 
        else {
            return (game.at(position.x(), position.y()+1))
        }
    }

    method cambiarNombre(){
        if (direccion == "Horizontal"){
            self.nombre("PuertaHorizontal")
        } 
        else {
            self.nombre("PuertaVertical")
            }
    }

    method actuar() {
        if (modo == 1) {
            if (puedeCerrar) {
                self.abrir()
            }
        }
        if (modo == 0) {
            if (puedeCerrar) {
                puedeCerrar = false
                self.cerrar()
            }
        }
    }

    method abrir() {
        if (modo == 1 && puedeCerrar) {
            mapaObjetos.paredes().remove(collision)
            puedeCerrar = false
            self.cambiarNombre()
            self.animar(9, 100, {
                modo = 0
                self.image("" + nombre + "_8.png")
                puedeCerrar = true 
            })
        }
    }

    method cerrar() {
        if (modo == 0 && !puedeCerrar) {
            puedeCerrar = true 
            mapaObjetos.enemigosEn(self.collisionDir().x(), self.collisionDir().y()).forEach({ e => e.matar() })
            self.cambiarNombre()
            self.animarReverse(9, 100, {
                modo = 1
                self.image("" + nombre + "_1.png")
                mapaObjetos.paredes().add(collision)
            })
        }
    }
}

class Bloque inherits Enemigo {
    const collision
    override method name() = "caja"

    override method mover() {
        self.actualizarRumbo(dirActual)

        if (self.puedeMoverseA(dirActual)) {

            const caja = game.sound("Empujar.mp3")
            caja.volume(0.4)
            caja.play()

            if (mapaObjetos.hayEn(position.x(), position.y(), mapaObjetos.pisables())) {
                mapaObjetos.pisables().find({ b => b.position() == position }).soltar()
            }

            mapaObjetos.paredes().remove(collision)
            self.inicializarAnimacion()
            animadorGlobal.enemigosMoviendose().add(self)
        }
    }

    override method alTerminarMovimiento() {
        collision.position(self.position())
        mapaObjetos.paredes().add(collision)

        if (mapaObjetos.hayEn(position.x(), position.y(), mapaObjetos.pisables())) {
            mapaObjetos.pisables().find({ b => b.position() == position }).pisar()
        }
    }
}

class Button inherits Objeto(nombre = "boton", image = "boton_1.png") {
    method puedeInteractuar() = mapaObjetos.cajas() + [personaje]
    var property listaObjetos 
    var property modo = 1
    var property puedeCerrar = true
    
    method pisar() {
        if (modo == 1 && puedeCerrar) {
            puedeCerrar = false
            
            self.animar(8, 100, {
                modo = 0
                self.image("boton_7.png")
                if(!self.puedeInteractuar().any({e => e.position() == position})){
                    self.soltar()
                }
                })
            listaObjetos.forEach({ objeto => mapaObjetos.activables().get(objeto).actuar() })
        }
    }

    method soltar() {
        if (modo == 0 && !puedeCerrar) {
            puedeCerrar = true
            
            self.animarReverse(8, 100, {
                modo = 1
                self.image("boton_1.png")
            })
            listaObjetos.forEach({ objeto => mapaObjetos.activables().get(objeto).actuar() })
        }
    }

    method animar() {}
}