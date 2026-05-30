class AntorchaArr{
    var property position
    var frameActual = 0
    var property image = "AntorchaArr.png"
    method animar() {
        game.onTick(100, "AntorchaArr", {
        frameActual = frameActual + 1
            if (frameActual < 9) {
                self.image("AntorchaArr_" + frameActual + ".png")
            } 
            else {
                frameActual = 0
            }
        })
    }
}

class AntorchaAbj{
    var property position
    var frameActual = 0
    var property image = "AntorchaAbj.png"
    method animar() {
        game.onTick(100, "AntorchaAbj", {
        frameActual = frameActual + 1
            if (frameActual < 9) {
                self.image("AntorchaAbj_" + frameActual + ".png")
            } 
            else {
                frameActual = 0
            }
        })
    }
}

class Pinchos{
    var puedeCerrar = true
    var property position
    var property modo = 1
    var frameActual = 0
    var property image = "PinchosCerrados.png"
    method abrir() {
        if (modo == 1 && puedeCerrar){frameActual = 0
            game.onTick(100, "PinchoAbriendo", {
                frameActual = frameActual + 1
                if (frameActual < 7) {
                    self.image("PinchosAbriendo_" + frameActual + ".png")
                }
                else {
                    game.removeTickEvent("PinchoAbriendo")
                    modo = 0
                    self.image("PinchosAbiertos.png")
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
                }
            })
            puedeCerrar = true
        }
    }
}

class Palanca{
    var property position
    var property listaObjetos
    var puedeCerrar = true
    var property modo = 1
    var frameActual = 0
    var property image = "PalancaCerrada.png"
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
            listaObjetos.forEach({objeto => objeto.abrir()})
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
            
            listaObjetos.forEach({objeto => objeto.cerrar()})
            puedeCerrar = true
        }
    }
}