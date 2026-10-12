class_name Teammate
extends Node2D

## Teammate representa al compañero que tiene la pelota. Hoy es una entidad
## puramente posicional: Main decide dónde se coloca y cuándo se ejecuta el
## pase, y la pelota nace en su posición. El script existe para darle identidad
## propia reutilizable (igual que Rival y Ball) en vez de depender de un nodo
## anónimo de la escena Main, y para tener dónde alojar su comportamiento
## cuando necesite desplazarse antes de pasar.
