# Diseño futbolístico

## Laboratorio actual

La cancha representa la mitad ofensiva: arco rival arriba y línea de mitad abajo. El laboratorio actual presenta una situación de desmarque con compañero, rival y pelota.

Secuencia implementada leída en código:

```text
inicio aleatorio razonable
→ ventana de desmarque
→ zona probable de pase
→ pelota en movimiento + presión rival
→ contacto, pérdida o salida
→ resultado e reinicio
```

La zona de pase no apunta de forma directa a la posición actual del jugador. Considera dirección/velocidad, separación del compañero, espacio frente al rival, profundidad y precisión configurada. Esto es una regla de prototipo, no una evaluación táctica final.

## Decisiones confirmadas

- El fútbol es la prioridad actual.
- Calidad de decisión, ejecución y resultado deben ser conceptos separados.
- Un buen desmarque no debe reducirse a distancia al compañero ni a estar más cerca del arco.
- El partido futuro conectará intervenciones del jugador con sucesos simulados de fondo y marcador coherente.
- El MVP no abarcará sistemas completos de posicionamiento, defensa ni energía.

## Propuesta de modelo futuro

Una situación puede producir tres lecturas separadas:

| Lectura | Pregunta |
| --- | --- |
| Decisión | ¿La posición elegida ofrecía separación, profundidad, lateralidad, espacio y línea de pase? |
| Ejecución | ¿El compañero/pase y el control del jugador materializaron esa oportunidad? |
| Resultado | ¿Hubo recepción, pérdida, remate, gol o cambio de posesión? |

Este modelo es una propuesta; no está implementado ni fija una fórmula.

## Partido conectado: propuesta

El partido puede mantener marcador, tiempo y contexto mientras alterna entre:

- situaciones jugables presentadas al jugador;
- sucesos de fondo simulados de forma acotada;
- consecuencias coherentes de goles e intervenciones.

La situación elegida debería recibir contexto y devolver un resultado, sin requerir que cada escena conozca todo el partido.

## Preguntas de diseño

- ¿Qué condiciones hacen que una situación valga la pena jugar y no ser un evento automático?
- ¿Cómo se expresa el riesgo según el marcador sin que una mala racha se sienta injusta?
- ¿Qué atributos afectan decisión, ejecución y resultado, y cuáles solo modifican probabilidades?
- ¿Qué nivel de control tendrá el jugador durante un pase, recepción, regate o definición?
