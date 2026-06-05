import wollok.game.*
import personaje.*
import juego.gestorNiveles
import niveles.*


object controles {
  method configurar() {
    keyboard.right().onPressDo({ personaje.moverDerecha() })
    keyboard.left().onPressDo({ personaje.moverIzquierda() })
    keyboard.up().onPressDo({ personaje.moverArriba() })
    keyboard.down().onPressDo({ personaje.moverAbajo() })
    keyboard.x().onPressDo({personaje.ataque()})
    keyboard.z().onPressDo({personaje.interact()})

    keyboard.q().onPressDo({nivel_1.limpiar()})
    keyboard.w().onPressDo({nivel_1.cargar()})
    keyboard.e().onPressDo({gestorNiveles.pasarNivel()})
  }
}