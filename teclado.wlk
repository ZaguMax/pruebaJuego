import wollok.game.*
import personaje.*
import juego.*


object controles {
  method configurar() {
    keyboard.right().onPressDo({ personaje.moverDerecha() })
    keyboard.left().onPressDo({ personaje.moverIzquierda() })
    keyboard.up().onPressDo({ personaje.moverArriba() })
    keyboard.down().onPressDo({ personaje.moverAbajo() })
    keyboard.x().onPressDo({personaje.ataque()})
    keyboard.z().onPressDo({personaje.interact()})
  }
}