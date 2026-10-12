# Roadmap

## Visión confirmada

EL GOAT es un juego de fútbol centrado, por ahora, exclusivamente en decisiones e intervenciones futbolísticas. La prioridad es validar un fútbol conectado antes de integración narrativa o sistemas accesorios.

## MVP confirmado

- El menú actual se conserva como laboratorio para probar situaciones individuales.
- Más adelante existirá un botón **Arrancar partido**.
- Un partido combinará situaciones controladas por el jugador con sucesos simulados de fondo.
- Los goles de intervenciones del jugador deben repercutir coherentemente en el marcador.
- El resultado parcial puede modificar contexto y valor de asumir riesgos.
- La decisión, la ejecución y el resultado deben poder evaluarse por separado.

El MVP no incluye posicionamiento ofensivo/defensivo completo ni gestión compleja de energía.

## Atributos

Confirmados como vocabulario de diseño: **Visión, Pase, Regate, Definición y Movimiento**.

Resistencia y Velocidad son posibilidades futuras; no hay compromiso de implementarlas.

## Próximos pasos recomendados

1. Playtest manual del loop actual de desmarque, pase y contacto.
2. Decidir qué representa cada nivel del selector actual y aplicar parámetros por nivel al laboratorio, o simplificar su rol hasta que exista ese contenido.
3. Definir una evaluación de situación reemplazable que separe calidad de decisión, ejecución del pase y resultado.
4. Añadir una primera situación adicional solo después de validar que el loop actual es entendible y divertido.
5. Diseñar la interfaz mínima de **Arrancar partido** y el contrato entre situaciones y marcador, sin implementar todavía la simulación completa.

## Propuestas, no decisiones

- Un recurso de configuración por nivel podría aportar duración, precisión del pase, velocidad rival, regiones iniciales y umbrales de evaluación al mismo `main.tscn`.
- El futuro partido puede llamar al mismo laboratorio de situaciones con contexto de marcador y tiempo, en vez de duplicar escenas.
- La integración narrativa y situacional permanece pospuesta hasta validar el fútbol conectado.

## Preguntas pendientes

- ¿El selector actual debe seguir siendo progresión de niveles o convertirse explícitamente en el laboratorio de situaciones?
- ¿Qué métrica mínima definirá una buena decisión antes de introducir atributos?
- ¿Qué sucesos de fondo puede simular un partido sin invalidar la agencia del jugador?
- ¿Cuándo una situación controlada debe aparecer según marcador, tiempo y contexto?
