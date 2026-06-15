class TileTransicion
{
    var property position
    var property image
}

class PoolDireccion
{
    // El índice 0 vacío
    const property framesA = [""]
    const property framesB = [""]
}

object bancoDeImagenes
{
    const biblioteca = new Dictionary()

    method inicializar() {
        const enemigos = ["sapo", "mur", "caja", "gato"]
        const direcciones = ["arr", "abj", "der", "izq"]

        enemigos.forEach({ ene =>
            direcciones.forEach({ dir =>
                const pool = new PoolDireccion()
                
                (1 .. 21).forEach({ frame =>
                    pool.framesA().add(ene + "_" + dir + "_a_" + frame + ".png")
                    pool.framesB().add(ene + "_" + dir + "_b_" + frame + ".png")
                })

                biblioteca.put(ene + "_" + dir, pool)
            })
        })
    }

    method obtenerPool(enemigoName, direccion) {
        return biblioteca.get(enemigoName + "_" + direccion)
    }
}

object animacionMovimiento
{
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
    const property elementosSimples = []
    const property enemigosMoviendose = []

    method procesarMovimientoEnemigos()
    {
        const copiaEnemigos = [] + enemigosMoviendose

        copiaEnemigos.forEach(
        { 
            enemigo =>

            if (enemigo.poolActual() == null) {
                enemigosMoviendose.remove(enemigo)
                enemigo.frameActual(0)
            }
            else
            {
                enemigo.frameActual(enemigo.frameActual() + 1)
                const frame = enemigo.frameActual()
                const pool = enemigo.poolActual()

                if (frame == 10) {
                    enemigo.position(enemigo.destinoTemporal())
                }

                if (frame < pool.framesA().size()) {
                    enemigo.tileA().image( enemigo.poolActual().framesA().get(frame) )
                    enemigo.tileB().image( enemigo.poolActual().framesB().get(frame) )
                } 
                else
                {
                    enemigosMoviendose.remove(enemigo)
                    enemigo.tileA().image("transparente.png")
                    enemigo.tileB().image("transparente.png")
                    enemigo.image("")
                    enemigo.frameActual(0)
                    enemigo.destinoTemporal(null)
                    enemigo.alTerminarMovimiento()
                }
            }
        })
    }

    method iniciar()
    {
        game.onTick(50, "relojGlobal",
        {
            elementosSimples.forEach({ elemento => elemento.siguienteFrame() })

            if (!enemigosMoviendose.isEmpty()) self.procesarMovimientoEnemigos()
        })
    }

    method detener() {
        game.removeTickEvent("relojGlobal")
    }
    
    method añadir(elemento) {
        elementosSimples.add(elemento)
    }

    method sacar(elemento) {
        elementosSimples.remove(elemento)
    }
}