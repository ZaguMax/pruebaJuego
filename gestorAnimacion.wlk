class TileTransicion
{
    var property position
    var property image
}

object animacionMovimiento
{
    var frameActual = 0

    method movimientoEntreCasillas(character, frames)
    {
        const nombreTick = "movimiento_entre_casillas_" + character.identity().toString()
        game.onTick(30, nombreTick, 
        {
            frameActual = frameActual + 1

            if (frameActual <= frames)
            {
                character.tileA().image(character.name() + "_" + character.dirActual() + "_a_" + frameActual + ".png")
                character.tileB().image(character.name() + "_" + character.dirActual() + "_b_" + frameActual + ".png")

                if (frameActual == 10) character.position( character.posicionDestino() )
            } 
            else
            {
                game.removeTickEvent(nombreTick)
                game.removeVisual(character.tileA())
                game.removeVisual(character.tileB())

                character.tileA(null)
                character.tileB(null)

                character.image(character.name() + "_" + character.dirActual() + ".png")

                frameActual = 0
            }
        })
    }

    method animacionMuerteEnemigo(character)
    {
        const nombreTick = "enemigoMuerte_" + character.identity().toString()

        game.onTick(100, nombreTick,
        {
            frameActual = frameActual + 1

            if (frameActual < 7) character.image("enemigoMuerte_" + frameActual + ".png")
            else
            {
                game.removeTickEvent(nombreTick)
                game.removeVisual(self)  
            }
        })
        
    }
}