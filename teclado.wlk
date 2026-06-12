import personaje.*
import niveles.*

object controles {
  method configurar() {
    keyboard.right().onPressDo({ personaje.moverDerecha() })
    keyboard.left().onPressDo({ personaje.moverIzquierda() })
    keyboard.up().onPressDo({ personaje.moverArriba() })
    keyboard.down().onPressDo({ personaje.moverAbajo() })
    keyboard.x().onPressDo({personaje.ataque()})
    keyboard.z().onPressDo({personaje.interact()})
    keyboard.l().onPressDo({gestorNiveles.pasarNivel() })
    keyboard.s().onPressDo({game.stop()})
  }
}

object controlesMenu {
  method configurar() {
    keyboard.right().onPressDo({pantallaDeTitulo.opcionSiguiente()})
    keyboard.left().onPressDo({pantallaDeTitulo.opcionAnterior()})
    keyboard.up().onPressDo({pantallaDeTitulo.opcionAnterior()})
    keyboard.down().onPressDo({pantallaDeTitulo.opcionSiguiente()})
    keyboard.enter().onPressDo({pantallaDeTitulo.aceptar()})
  }
}

