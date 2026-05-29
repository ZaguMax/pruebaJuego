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