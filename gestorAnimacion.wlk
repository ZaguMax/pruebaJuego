class TileTransicion
{
    var property position
    var property image
}

object animacionMovimiento
{
    method movimientoEntreCasillas(character, framesMaximos)
    {
        const nombreTick = "mov_casillas_" + character.identity().toString()
        const destinoFinal = character.posicionDestino()
        
        game.onTick(50, nombreTick, 
        {
            character.frameActual(character.frameActual() + 1)

            const frame = character.frameActual()

            if (frame <= framesMaximos)
            {
                character.tileA().image(character.name() + "_" + character.dirActual() + "_a_" + frame + ".png")
                character.tileB().image(character.name() + "_" + character.dirActual() + "_b_" + frame + ".png")
            } 
            else
            {
                game.removeTickEvent(nombreTick)
                character.position(destinoFinal)
                
                character.tileA().image("transparente.png")
                character.tileB().image("transparente.png")

                character.image("") 
            }
        })
    }

    method animacionMuerteEnemigo(character)
    {
        const nombreTick = "enemigoMuerte_" + character.identity().toString()

        game.onTick(100, nombreTick,
        {
            character.frameActual(character.frameActual() + 1)
            const frame = character.frameActual()

            if (frame < 7) {
                character.image("enemigoMuerte_" + frame + ".png")
            }
            else
            {
                game.removeTickEvent(nombreTick)
                game.removeVisual(character)
            }
        })
    }
}

object animadorGlobal
{
    const property elementosAAnimar = []

    method iniciar()
    {
        game.onTick(100, "animacionGeneral", {
            elementosAAnimar.forEach({ elemento => elemento.siguienteFrame() })
        })
    }

    method detener() {
        game.removeTickEvent("animacionGeneral")
    }
    
    method añadir(elemento) {
        elementosAAnimar.add(elemento)
    }

    method sacar(elemento) {
        elementosAAnimar.remove(elemento)
    }
}